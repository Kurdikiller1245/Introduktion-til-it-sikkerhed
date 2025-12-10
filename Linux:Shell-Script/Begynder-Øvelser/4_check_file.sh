#!/bin/bash
# Script der tjekker om en fil findes

# Tjek om der er givet et argument
if [ $# -eq 0 ]; then
    echo "Brug: $0 <filnavn>"
    echo "Eksempel: $0 /etc/passwd"
    exit 1
fi

fil="$1"

# Tjek om filen findes
if [ -e "$fil" ]; then
    echo "✓ Filen '$fil' findes!"
    
    # Vis ekstra information
    if [ -f "$fil" ]; then
        echo "  Type: Almindelig fil"
        echo "  Størrelse: $(stat -c%s "$fil") bytes"
    elif [ -d "$fil" ]; then
        echo "  Type: Directory"
    elif [ -L "$fil" ]; then
        echo "  Type: Symbolsk link"
    fi
else
    echo "✗ Filen '$fil' findes IKKE!"
    exit 1
fi