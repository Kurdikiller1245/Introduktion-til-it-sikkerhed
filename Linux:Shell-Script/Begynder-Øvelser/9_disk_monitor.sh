#!/bin/bash
# Script der overvåger ledig diskplads og advarer hvis den er under 10%

echo "=== Diskplads Monitor ==="
echo ""

# Grænse for advarsel (10%)
THRESHOLD=10

# Flag til at tracke om der er advarsler
has_warning=0

# Tjek alle mountede filesystemer
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | while read -r line; do
    # Udtræk information
    filesystem=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    use_pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mountpoint=$(echo "$line" | awk '{print $6}')
    
    # Beregn ledig procent
    free_pct=$((100 - use_pct))
    
    # Tjek om der er under grænsen
    if [ $free_pct -lt $THRESHOLD ]; then
        echo "⚠️  ADVARSEL! Lav diskplads på $mountpoint"
        echo "   Filesystem: $filesystem"
        echo "   Størrelse: $size"
        echo "   Brugt: $used ($use_pct%)"
        echo "   Ledigt: $avail ($free_pct%)"
        echo ""
        has_warning=1
    else
        echo "✓ $mountpoint: $free_pct% ledigt ($avail)"
    fi
done

# Hvis ingen advarsler
if [ $has_warning -eq 0 ]; then
    echo ""
    echo "Alt ser godt ud! Alle diske har mere end $THRESHOLD% ledig plads."
fi