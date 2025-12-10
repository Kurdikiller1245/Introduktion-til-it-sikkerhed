#!/bin/bash
# Script der scanner et subnet for aktive værter

SUBNET="${1:-192.168.1.0/24}"
TIMEOUT=1
OUTPUT_FILE="active_hosts.txt"

echo "=== Subnet Scanner ==="
echo "Scanner subnet: $SUBNET"
echo "Timeout: ${TIMEOUT}s per host"
echo ""

# Parse subnet
IFS='/' read -r base_ip cidr <<< "$SUBNET"
IFS='.' read -r o1 o2 o3 o4 <<< "$base_ip"

# Beregn range baseret på CIDR
case $cidr in
    24)
        start=1
        end=254
        network="$o1.$o2.$o3"
        ;;
    16)
        echo "Scanner /16 subnet (dette tager lang tid)..."
        start=1
        end=254
        network="$o1.$o2"
        ;;
    *)
        echo "Denne scanner understøtter primært /24 subnets"
        echo "Fortsætter med /24..."
        start=1
        end=254
        network="$o1.$o2.$o3"
        ;;
esac

echo "Starter scan..."
echo "Dette kan tage et par minutter..."
echo ""

# Ryd output fil
> "$OUTPUT_FILE"

active_count=0

# Scan loop
for i in $(seq $start $end); do
    if [ "$cidr" == "24" ]; then
        ip="$network.$i"
    else
        # For /16 scan begge sidste oktetter (simpel version)
        for j in $(seq 1 254); do
            ip="$network.$i.$j"
        done
    fi
    
    # Ping host (i baggrund for hastighed)
    (
        if ping -c 1 -W $TIMEOUT "$ip" &>/dev/null; then
            echo "✓ $ip er aktiv"
            echo "$ip" >> "$OUTPUT_FILE"
            
            # Prøv at få hostname
            hostname=$(nslookup "$ip" 2>/dev/null | grep "name =" | awk '{print $NF}' | sed 's/\.$//')
            if [ -n "$hostname" ]; then
                echo "  Hostname: $hostname"
            fi
            
            # Prøv at få MAC adresse (kræver root)
            if [ "$EUID" -eq 0 ]; then
                mac=$(arp -n "$ip" 2>/dev/null | grep "$ip" | awk '{print $3}')
                if [ -n "$mac" ] && [ "$mac" != "<incomplete>" ]; then
                    echo "  MAC: $mac"
                fi
            fi
        fi
    ) &
    
    # Begræns antal samtidige processer
    if [ $((i % 50)) -eq 0 ]; then
        wait
    fi
done

# Vent på alle baggrunds-jobs færdiggør
wait

echo ""
echo "--- Scan Komplet ---"

active_count=$(wc -l < "$OUTPUT_FILE")
echo "Aktive værter fundet: $active_count"
echo ""

if [ $active_count -gt 0 ]; then
    echo "Liste over aktive værter:"
    cat "$OUTPUT_FILE"
    echo ""
    echo "Resultat gemt i: $OUTPUT_FILE"
    
    # Ekstra info hvis nmap er tilgængelig
    if command -v nmap &> /dev/null; then
        echo ""
        echo "💡 TIP: For mere detaljeret scan, brug nmap:"
        echo "nmap -sn $SUBNET"
        echo "nmap -A -T4 $SUBNET  (aggressiv scan)"
    fi
    
    # Port scanning option
    echo ""
    read -p "Vil du porte-scanne de aktive værter? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo ""
        echo "Scanner almindelige porte på aktive værter..."
        
        while read -r ip; do
            echo ""
            echo "=== Scanning $ip ==="
            
            # Scan almindelige porte
            for port in 21 22 23 25 80 443 3306 3389 8080; do
                if timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null; then
                    echo "  Port $port: ÅBEN"
                fi
            done
        done < "$OUTPUT_FILE"
    fi
else
    echo "Ingen aktive værter fundet i subnet $SUBNET"
fi