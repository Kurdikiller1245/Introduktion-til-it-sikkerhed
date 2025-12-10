#!/bin/bash
# Script der tjekker om en port er åben

# Standard port er 22 (SSH)
port="${1:-22}"

echo "=== Tjekker port $port ==="
echo ""

# Prøv først med ss (moderne)
if command -v ss &> /dev/null; then
    if ss -tuln | grep -q ":$port "; then
        echo "✓ Port $port er ÅBEN"
        echo ""
        echo "Detaljer:"
        ss -tulnp | grep ":$port "
        exit 0
    else
        echo "✗ Port $port er LUKKET"
        exit 1
    fi
# Fallback til netstat
elif command -v netstat &> /dev/null; then
    if netstat -tuln | grep -q ":$port "; then
        echo "✓ Port $port er ÅBEN"
        echo ""
        echo "Detaljer:"
        netstat -tulnp | grep ":$port "
        exit 0
    else
        echo "✗ Port $port er LUKKET"
        exit 1
    fi
else
    echo "Fejl: Hverken 'ss' eller 'netstat' er tilgængelig!"
    exit 2
fi