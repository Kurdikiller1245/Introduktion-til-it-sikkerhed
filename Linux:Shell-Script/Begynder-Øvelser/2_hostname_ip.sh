#!/bin/bash
# Script der viser systemets hostname og IP-adresse

echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo ""
echo "IP-adresser:"

# Hent IP-adresser med ip command
if command -v ip &> /dev/null; then
    ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1'
else
    # Fallback til ifconfig
    ifconfig | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1'
fi