#!/bin/bash
# Script der automatiserer nmap-scanninger og viser kun åbne porte

TARGET="${1}"
OUTPUT_DIR="nmap_scans"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Automated Nmap Scanner ==="
echo ""

# Tjek om nmap er installeret
if ! command -v nmap &> /dev/null; then
    echo "Fejl: nmap er ikke installeret!"
    echo "Installer med: sudo apt install nmap"
    exit 1
fi

# Tjek om target er angivet
if [ -z "$TARGET" ]; then
    echo "Brug: $0 <target>"
    echo ""
    echo "Eksempler:"
    echo "  $0 192.168.1.1"
    echo "  $0 192.168.1.0/24"
    echo "  $0 example.com"
    exit 1
fi

# Opret output directory
mkdir -p "$OUTPUT_DIR"

echo "Target: $TARGET"
echo "Output: $OUTPUT_DIR/"
echo ""

# Menu for scan type
echo "=== Scan Type ==="
echo "1) Quick Scan (Top 100 porte)"
echo "2) Standard Scan (Top 1000 porte)"
echo "3) Full Scan (Alle 65535 porte)"
echo "4) Service/Version Detection"
echo "5) OS Detection"
echo "6) Aggressive Scan (All features)"
echo "7) Vulnerability Scan (NSE scripts)"
echo "8) Custom Scan"
echo ""
read -p "Vælg scan type (1-8): " scan_choice

case $scan_choice in
    1) 
        echo ""
        echo "🔍 Quick Scan - Top 100 porte..."
        nmap -T4 --top-ports 100 "$TARGET" -oN "$OUTPUT_DIR/quick_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/quick_${TIMESTAMP}.txt"
        ;;
    2)
        echo ""
        echo "🔍 Standard Scan - Top 1000 porte..."
        nmap -T4 "$TARGET" -oN "$OUTPUT_DIR/standard_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/standard_${TIMESTAMP}.txt"
        ;;
    3)
        echo ""
        echo "🔍 Full Port Scan - Dette tager lang tid..."
        nmap -T4 -p- "$TARGET" -oN "$OUTPUT_DIR/full_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/full_${TIMESTAMP}.txt"
        ;;
    4)
        echo ""
        echo "🔍 Service/Version Detection..."
        nmap -sV -T4 "$TARGET" -oN "$OUTPUT_DIR/service_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/service_${TIMESTAMP}.txt"
        ;;
    5)
        echo ""
        echo "🔍 OS Detection (kræver root)..."
        if [ "$EUID" -ne 0 ]; then
            echo "⚠️  ADVARSEL: OS detection kræver root rettigheder"
        fi
        sudo nmap -O -T4 "$TARGET" -oN "$OUTPUT_DIR/os_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/os_${TIMESTAMP}.txt"
        ;;
    6)
        echo ""
        echo "🔍 Aggressive Scan..."
        if [ "$EUID" -ne 0 ]; then
            echo "⚠️  ADVARSEL: Aggressive scan fungerer bedst med root"
        fi
        sudo nmap -A -T4 "$TARGET" -oN "$OUTPUT_DIR/aggressive_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/aggressive_${TIMESTAMP}.txt"
        ;;
    7)
        echo ""
        echo "🔍 Vulnerability Scan med NSE scripts..."
        nmap --script vuln -T4 "$TARGET" -oN "$OUTPUT_DIR/vuln_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/vuln_${TIMESTAMP}.txt"
        ;;
    8)
        echo ""
        read -p "Indtast custom nmap options: " custom_opts
        nmap $custom_opts "$TARGET" -oN "$OUTPUT_DIR/custom_${TIMESTAMP}.txt"
        scan_file="$OUTPUT_DIR/custom_${TIMESTAMP}.txt"
        ;;
    *)
        echo "Ugyldig valg!"
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Scan komplet!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse og vis kun åbne porte
echo "=== ÅBNE PORTE ==="
echo ""

open_ports=$(grep "^[0-9]*/.*open" "$scan_file" 2>/dev/null)

if [ -z "$open_ports" ]; then
    echo "Ingen åbne porte fundet."
else
    echo "Port     State    Service              Version"
    echo "-------  -------  -------------------  --------------------------"
    
    grep "^[0-9]*/.*open" "$scan_file" | while read -r line; do
        port=$(echo "$line" | awk '{print $1}')
        state=$(echo "$line" | awk '{print $2}')
        service=$(echo "$line" | awk '{print $3}')
        version=$(echo "$line" | cut -d' ' -f4- | cut -c1-25)
        
        printf "%-8s %-8s %-20s %s\n" "$port" "$state" "$service" "$version"
    done
    
    # Tæl åbne porte
    port_count=$(grep -c "^[0-9]*/.*open" "$scan_file")
    echo ""
    echo "Total åbne porte: $port_count"
fi

# Vis OS info hvis tilgængelig
if grep -q "OS details:" "$scan_file" 2>/dev/null; then
    echo ""
    echo "=== OS DETECTION ==="
    grep "OS details:" "$scan_file" | cut -d':' -f2-
fi

# Vis hostname hvis fundet
if grep -q "Host script results:" "$scan_file" 2>/dev/null; then
    echo ""
    echo "=== HOST INFO ==="
    sed -n '/Host script results:/,/^$/p' "$scan_file"
fi

# Vulnerability summary
if [ "$scan_choice" -eq 7 ]; then
    echo ""
    echo "=== VULNERABILITY SUMMARY ==="
    
    vuln_count=$(grep -c "VULNERABLE" "$scan_file" 2>/dev/null || echo "0")
    if [ "$vuln_count" -gt 0 ]; then
        echo "⚠️  $vuln_count potentielle sårbarheder fundet!"
        echo ""
        grep -A2 "VULNERABLE" "$scan_file" | head -20
    else
        echo "✓ Ingen sårbarheder fundet af NSE scripts"
    fi
fi

# Generate CSV export
echo ""
echo "=== EKSPORT ==="

csv_file="$OUTPUT_DIR/ports_${TIMESTAMP}.csv"
echo "Port,State,Service,Version" > "$csv_file"

grep "^[0-9]*/.*open" "$scan_file" 2>/dev/null | while read -r line; do
    port=$(echo "$line" | awk '{print $1}')
    state=$(echo "$line" | awk '{print $2}')
    service=$(echo "$line" | awk '{print $3}')
    version=$(echo "$line" | cut -d' ' -f4-)
    
    echo "$port,$state,$service,$version" >> "$csv_file"
done

echo "✓ Fuld scan gemt til: $scan_file"
echo "✓ CSV eksporteret til: $csv_file"

# Generate simple HTML report
html_file="$OUTPUT_DIR/report_${TIMESTAMP}.html"
{
    echo "<html><head><title>Nmap Scan Report</title></head><body>"
    echo "<h1>Nmap Scan Report</h1>"
    echo "<p><strong>Target:</strong> $TARGET</p>"
    echo "<p><strong>Scan Date:</strong> $(date)</p>"
    echo "<h2>Open Ports</h2><pre>"
    grep "^[0-9]*/.*open" "$scan_file" 2>/dev/null
    echo "</pre></body></html>"
} > "$html_file"

echo "✓ HTML rapport: $html_file"

echo ""
echo "💡 Næste skridt:"
echo "   - Undersøg services på åbne porte"
echo "   - Kør vulnerability scans på specifikke porte"
echo "   - Test for default credentials"