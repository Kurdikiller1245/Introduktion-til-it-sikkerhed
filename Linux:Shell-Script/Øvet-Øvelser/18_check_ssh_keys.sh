#!/bin/bash
# Script der tjekker alle brugeres hjemmemapper for .ssh/authorized_keys

echo "=== SSH Authorized Keys Checker ==="
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "⚠️  ADVARSEL: Dette script bør køres som root for fuld adgang"
    echo ""
fi

found_keys=0
total_users=0

echo "Scanner alle brugere for SSH nøgler..."
echo ""

# Gennemgå alle brugere i /etc/passwd
while IFS=: read -r username _ uid _ _ homedir shell; do
    # Skip system brugere (uid < 1000) og brugere uden shell
    if [ "$uid" -lt 1000 ] && [ "$username" != "root" ]; then
        continue
    fi
    
    # Skip brugere med nologin/false shell (valgfrit)
    if [[ "$shell" == *"nologin"* ]] || [[ "$shell" == *"false"* ]]; then
        continue
    fi
    
    ((total_users++))
    
    # Tjek om .ssh/authorized_keys findes
    auth_keys="$homedir/.ssh/authorized_keys"
    
    if [ -f "$auth_keys" ]; then
        ((found_keys++))
        
        echo "┌─────────────────────────────────────────"
        echo "│ User: $username (UID: $uid)"
        echo "│ Home: $homedir"
        echo "│ Keys File: $auth_keys"
        
        # Tjek fil rettigheder
        perms=$(stat -c "%a" "$auth_keys" 2>/dev/null)
        owner=$(stat -c "%U:%G" "$auth_keys" 2>/dev/null)
        
        echo "│ Permissions: $perms | Owner: $owner"
        
        # Advarsel om usikre rettigheder
        if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
            echo "│ ⚠️  SIKKERHEDSADVARSEL: Usikre rettigheder! Burde være 600"
        fi
        
        # Tæl antal nøgler
        key_count=$(grep -c "^ssh-" "$auth_keys" 2>/dev/null || echo "0")
        echo "│ Antal SSH nøgler: $key_count"
        
        # Vis nøglerne (hvis læsbar)
        if [ -r "$auth_keys" ]; then
            echo "│"
            echo "│ --- SSH Nøgler ---"
            
            grep "^ssh-" "$auth_keys" 2>/dev/null | while read -r key; do
                key_type=$(echo "$key" | awk '{print $1}')
                key_comment=$(echo "$key" | awk '{print $NF}')
                key_fp=$(echo "$key" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}')
                
                echo "│   Type: $key_type"
                echo "│   Comment: $key_comment"
                if [ -n "$key_fp" ]; then
                    echo "│   Fingerprint: $key_fp"
                fi
                echo "│"
            done
        else
            echo "│ ⚠️  Kan ikke læse filen (manglende rettigheder)"
        fi
        
        echo "└─────────────────────────────────────────"
        echo ""
    fi
    
    # Tjek også for .ssh/id_rsa (private nøgler)
    if [ -f "$homedir/.ssh/id_rsa" ]; then
        echo "  ℹ️  Private key fundet: $homedir/.ssh/id_rsa"
        
        priv_perms=$(stat -c "%a" "$homedir/.ssh/id_rsa" 2>/dev/null)
        if [ "$priv_perms" != "600" ] && [ "$priv_perms" != "400" ]; then
            echo "     ⚠️  KRITISK: Private key har usikre rettigheder ($priv_perms)!"
        fi
        echo ""
    fi
    
done < /etc/passwd

echo "=== Oversigt ==="
echo "Total brugere scannet: $total_users"
echo "Brugere med authorized_keys: $found_keys"

# Ekstra sikkerhedschecks
echo ""
echo "=== Sikkerhedschecks ==="

# Tjek for world-writable .ssh directories
echo ""
echo "World-writable .ssh directories (FARLIGT!):"
find /home -name ".ssh" -type d -perm -o+w 2>/dev/null
writable_ssh=$(find /home -name ".ssh" -type d -perm -o+w 2>/dev/null | wc -l)
if [ $writable_ssh -eq 0 ]; then
    echo "✓ Ingen fundet"
fi

# Tjek for .ssh directories med forkerte rettigheder
echo ""
echo ".ssh directories med rettigheder != 700:"
find /home -name ".ssh" -type d 2>/dev/null | while read -r sshdir; do
    perms=$(stat -c "%a" "$sshdir")
    if [ "$perms" != "700" ]; then
        echo "⚠️  $sshdir (permissions: $perms)"
    fi
done

# Tjek for authorized_keys med forkerte rettigheder
echo ""
echo "authorized_keys filer med rettigheder != 600:"
find /home -name "authorized_keys" -type f 2>/dev/null | while read -r keyfile; do
    perms=$(stat -c "%a" "$keyfile")
    if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
        echo "⚠️  $keyfile (permissions: $perms)"
    fi
done

# Tjek for suspicious keys (keys uden kommentar eller med verdensrettigheder)
echo ""
echo "=== Mistænkelige Nøgler ==="
find /home -name "authorized_keys" -type f 2>/dev/null | while read -r keyfile; do
    # Keys uden kommentar
    if grep -q "^ssh-.*[^@]$" "$keyfile" 2>/dev/null; then
        echo "⚠️  Nøgle uden kommentar i: $keyfile"
    fi
done