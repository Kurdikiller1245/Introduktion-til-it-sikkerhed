#!/bin/bash
# Script der viser alle setuid-binaries på systemet

START_DIR="${1:-/}"
OUTPUT_FILE="setuid_binaries_$(date +%Y%m%d_%H%M%S).txt"

echo "=== SETUID Binary Scanner ==="
echo "Scanner fra: $START_DIR"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "⚠️  ADVARSEL: Ikke kørende som root - nogle filer kan blive sprunget over"
    echo ""
fi

echo "Søger efter SETUID binaries..."
echo "Dette kan tage noget tid..."
echo ""

# Find SETUID filer
echo "--- SETUID Binaries (setuid root = farlige!) ---"
echo ""

{
    echo "=== SETUID Binary Report ==="
    echo "Generated: $(date)"
    echo "Scanned: $START_DIR"
    echo ""
    echo "SETUID binaries fundet:"
    echo ""
} > "$OUTPUT_FILE"

# Find og analyser SETUID filer
find "$START_DIR" -type f -perm -4000 2>/dev/null | while read -r file; do
    # Hent file info
    perms=$(stat -c "%a" "$file")
    owner=$(stat -c "%U:%G" "$file")
    size=$(stat -c "%s" "$file")
    
    # Tjek om det er owned by root (mest kritisk)
    owner_uid=$(stat -c "%u" "$file")
    
    if [ "$owner_uid" -eq 0 ]; then
        marker="🔴 CRITICAL"
    else
        marker="🟡 WARNING"
    fi
    
    echo "$marker $file"
    echo "    Permissions: $perms | Owner: $owner | Size: $size bytes"
    
    # Tjek om det er et kendt binary
    basename=$(basename "$file")
    case "$basename" in
        passwd|sudo|su|mount|umount|ping|chsh|chfn)
            echo "    ✓ Standard system binary (normalt)"
            ;;
        *)
            echo "    ⚠️  Ukendt/usædvanligt SETUID binary!"
            ;;
    esac
    
    # File type og MD5 hash
    if command -v file &> /dev/null; then
        filetype=$(file -b "$file")
        echo "    Type: $filetype"
    fi
    
    if command -v md5sum &> /dev/null; then
        md5=$(md5sum "$file" | awk '{print $1}')
        echo "    MD5: $md5"
    fi
    
    echo ""
    
    # Log til fil
    {
        echo "File: $file"
        echo "  Permissions: $perms"
        echo "  Owner: $owner"
        echo "  Size: $size bytes"
        echo "  MD5: $md5"
        echo ""
    } >> "$OUTPUT_FILE"
done

# Find også SETGID filer
echo ""
echo "--- SETGID Binaries ---"
echo ""

find "$START_DIR" -type f -perm -2000 2>/dev/null | while read -r file; do
    perms=$(stat -c "%a" "$file")
    owner=$(stat -c "%U:%G" "$file")
    
    echo "🟢 $file"
    echo "    Permissions: $perms | Owner: $owner"
    echo ""
done

# Statistik
echo "=== Statistik ==="
setuid_count=$(find "$START_DIR" -type f -perm -4000 2>/dev/null | wc -l)
setgid_count=$(find "$START_DIR" -type f -perm -2000 2>/dev/null | wc -l)
setuid_root_count=$(find "$START_DIR" -type f -perm -4000 -user root 2>/dev/null | wc -l)

echo "Total SETUID binaries: $setuid_count"
echo "SETUID root binaries: $setuid_root_count"
echo "Total SETGID binaries: $setgid_count"

# Sikkerhedsvurdering
echo ""
echo "=== Sikkerhedsvurdering ==="

# Tjek for usædvanlige SETUID binaries
echo ""
echo "Potentielt mistænkelige SETUID binaries:"
suspicious=0

find "$START_DIR" -type f -perm -4000 2>/dev/null | while read -r file; do
    basename=$(basename "$file")
    
    # Liste af kendte/acceptable SETUID binaries
    case "$basename" in
        passwd|sudo|su|mount|umount|ping|ping6|chsh|chfn|fusermount|pkexec|newgrp|gpasswd|unix_chkpwd)
            # Disse er normale
            ;;
        *)
            echo "  ⚠️  $file"
            ((suspicious++))
            ;;
    esac
done

# Tjek for world-writable SETUID (MEGET farligt!)
echo ""
echo "World-writable SETUID binaries (KRITISK!):"
dangerous=$(find "$START_DIR" -type f -perm -4000 -perm -o+w 2>/dev/null | wc -l)

if [ $dangerous -gt 0 ]; then
    echo "🔴 KRITISK SIKKERHEDSPROBLEM!"
    find "$START_DIR" -type f -perm -4000 -perm -o+w 2>/dev/null | while read -r file; do
        echo "  🔴 $file"
    done
else
    echo "  ✓ Ingen fundet (godt!)"
fi

# Tjek for SETUID binaries i usædvanlige lokationer
echo ""
echo "SETUID binaries uden for standard directories:"
find "$START_DIR" -type f -perm -4000 2>/dev/null | while read -r file; do
    # Tjek om filen er i standard directories
    if [[ ! "$file" =~ ^/bin/|^/sbin/|^/usr/bin/|^/usr/sbin/|^/usr/lib/ ]]; then
        echo "  ⚠️  $file (usædvanlig lokation)"
    fi
done

# Privilege escalation check
echo ""
echo "💡 Tips til privilege escalation audit:"
echo "   - Kør: ./$(basename $0) | grep -v 'Standard system binary'"
echo "   - Tjek GTFOBins for exploit methods: https://gtfobins.github.io/"
echo "   - Kør Linux Exploit Suggester"

# Gem rapport
echo ""
echo "✓ Detaljeret rapport gemt til: $OUTPUT_FILE"

# Sammenlign med known good state (hvis tilgængelig)
KNOWN_GOOD="/tmp/setuid_known_good.txt"
if [ -f "$KNOWN_GOOD" ]; then
    echo ""
    echo "=== Ændringer siden sidste scan ==="
    
    # Find nye SETUID binaries
    new_files=$(comm -13 <(sort "$KNOWN_GOOD") <(find "$START_DIR" -type f -perm -4000 2>/dev/null | sort))
    
    if [ -n "$new_files" ]; then
        echo "🔴 NYE SETUID binaries fundet:"
        echo "$new_files"
    else
        echo "✓ Ingen nye SETUID binaries"
    fi
else
    echo ""
    echo "💡 Gem denne scan som baseline:"
    echo "   find / -type f -perm -4000 2>/dev/null | sort > $KNOWN_GOOD"
fi