#!/bin/bash
# Script der genererer firewall-regler ud fra en whitelist af IP-adresser

WHITELIST_FILE="${1:-ip_whitelist.txt}"
OUTPUT_SCRIPT="firewall_rules.sh"
FW_TYPE="${2:-iptables}"

echo "=== Firewall Rule Generator ==="
echo ""

# Tjek om whitelist findes
if [ ! -f "$WHITELIST_FILE" ]; then
    echo "Whitelist fil ikke fundet. Opretter eksempel..."
    
    cat > "$WHITELIST_FILE" <<EOF
# IP Whitelist - Et IP eller subnet per linje
# Format: IP/CIDR [kommentar]

# Lokale netværk
192.168.1.0/24        # Lokalt LAN
10.0.0.0/8            # Private network

# Trusted servers
203.0.113.10          # Web server
198.51.100.25         # Database server
192.0.2.50            # Backup server

# Remote offices
172.16.0.0/12         # Office VPN

# Cloud services
8.8.8.8               # Google DNS
1.1.1.1               # Cloudflare DNS
EOF
    
    echo "✓ Eksempel whitelist oprettet: $WHITELIST_FILE"
    echo "Rediger filen og kør scriptet igen."
    exit 0
fi

echo "Whitelist: $WHITELIST_FILE"
echo "Firewall type: $FW_TYPE"
echo "Output: $OUTPUT_SCRIPT"
echo ""

# Læs whitelist
whitelist_ips=()
while IFS= read -r line; do
    # Skip kommentarer og tomme linjer
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # Udtræk IP (første del før kommentar)
    ip=$(echo "$line" | awk '{print $1}')
    whitelist_ips+=("$ip")
done < "$WHITELIST_FILE"

echo "Loaded ${#whitelist_ips[@]} IP'er/subnets fra whitelist"
echo ""

# Generer firewall script
case "$FW_TYPE" in
    iptables)
        echo "Genererer iptables regler..."
        
        cat > "$OUTPUT_SCRIPT" <<'EOF'
#!/bin/bash
# Auto-generated firewall rules
# Generated: $(date)

echo "=== Applying Firewall Rules ==="
echo ""

# Flush eksisterende regler
echo "Flushing existing rules..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Default policies - DROP alt
echo "Setting default policies to DROP..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Tillad loopback
echo "Allowing loopback..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Tillad established/related connections
echo "Allowing established connections..."
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Tillad udgående DNS
echo "Allowing DNS..."
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Tillad udgående HTTP/HTTPS
echo "Allowing HTTP/HTTPS output..."
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

EOF
        
        # Tilføj whitelist regler
        echo "" >> "$OUTPUT_SCRIPT"
        echo "# Whitelist IP addresses" >> "$OUTPUT_SCRIPT"
        echo "echo \"Applying whitelist rules...\"" >> "$OUTPUT_SCRIPT"
        
        for ip in "${whitelist_ips[@]}"; do
            echo "iptables -A INPUT -s $ip -j ACCEPT" >> "$OUTPUT_SCRIPT"
            echo "iptables -A OUTPUT -d $ip -j ACCEPT" >> "$OUTPUT_SCRIPT"
        done
        
        cat >> "$OUTPUT_SCRIPT" <<'EOF'

# Tillad SSH fra whitelist (optional - kommenter ind hvis nødvendigt)
# for ip in "${whitelist_ips[@]}"; do
#     iptables -A INPUT -p tcp -s $ip --dport 22 -j ACCEPT
# done

# Log dropped packets
echo "Setting up logging..."
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

# Save rules
echo ""
echo "Saving rules..."
if command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /tmp/iptables.rules
    echo "✓ Rules saved"
fi

echo ""
echo "=== Firewall Rules Applied ==="
echo ""
echo "Current rules:"
iptables -L -n -v
EOF
        ;;
        
    ufw)
        echo "Generering ufw regler..."
        
        cat > "$OUTPUT_SCRIPT" <<'EOF'
#!/bin/bash
# Auto-generated UFW firewall rules

echo "=== Applying UFW Rules ==="
echo ""

# Reset UFW
echo "Resetting UFW..."
ufw --force reset

# Default policies
echo "Setting default policies..."
ufw default deny incoming
ufw default deny outgoing

# Tillad loopback
ufw allow in on lo
ufw allow out on lo

# Tillad udgående DNS
ufw allow out 53/tcp
ufw allow out 53/udp

# Tillad udgående HTTP/HTTPS
ufw allow out 80/tcp
ufw allow out 443/tcp

EOF
        
        echo "" >> "$OUTPUT_SCRIPT"
        echo "# Whitelist IP addresses" >> "$OUTPUT_SCRIPT"
        echo "echo \"Applying whitelist rules...\"" >> "$OUTPUT_SCRIPT"
        
        for ip in "${whitelist_ips[@]}"; do
            echo "ufw allow from $ip" >> "$OUTPUT_SCRIPT"
            echo "ufw allow out to $ip" >> "$OUTPUT_SCRIPT"
        done
        
        cat >> "$OUTPUT_SCRIPT" <<'EOF'

# Enable UFW
echo ""
echo "Enabling UFW..."
ufw --force enable

echo ""
echo "=== UFW Rules Applied ==="
ufw status verbose
EOF
        ;;
        
    firewalld)
        echo "Genererer firewalld regler..."
        
        cat > "$OUTPUT_SCRIPT" <<'EOF'
#!/bin/bash
# Auto-generated firewalld rules

echo "=== Applying firewalld Rules ==="
echo ""

# Start firewalld
systemctl start firewalld

# Set default zone
firewall-cmd --set-default-zone=drop

# Tillad loopback
firewall-cmd --permanent --zone=trusted --add-interface=lo

EOF
        
        echo "" >> "$OUTPUT_SCRIPT"
        echo "# Whitelist IP addresses" >> "$OUTPUT_SCRIPT"
        echo "echo \"Adding whitelist IPs...\"" >> "$OUTPUT_SCRIPT"
        
        for ip in "${whitelist_ips[@]}"; do
            echo "firewall-cmd --permanent --zone=trusted --add-source=$ip" >> "$OUTPUT_SCRIPT"
        done
        
        cat >> "$OUTPUT_SCRIPT" <<'EOF'

# Reload rules
firewall-cmd --reload

echo ""
echo "=== firewalld Rules Applied ==="
firewall-cmd --list-all
EOF
        ;;
        
    *)
        echo "Ukendt firewall type: $FW_TYPE"
        echo "Understøttede typer: iptables, ufw, firewalld"
        exit 1
        ;;
esac

# Gør scriptet eksekverbart
chmod +x "$OUTPUT_SCRIPT"

echo "✓ Firewall script genereret: $OUTPUT_SCRIPT"
echo ""
echo "Whitelist IP'er:"
printf "  - %s\n" "${whitelist_ips[@]}"
echo ""
echo "⚠️  ADVARSEL: Test reglerne omhyggeligt før deployment!"
echo ""
echo "For at anvende reglerne:"
echo "  sudo ./$OUTPUT_SCRIPT"
echo ""
echo "💡 TIP: Test først i en VM eller test-miljø!"