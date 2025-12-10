#!/bin/bash
# Script der viser de sidste 10 mislykkede loginforsøg

LOG_FILE="/var/log/auth.log"

echo "=== De sidste 10 mislykkede loginforsøg ==="
echo ""

# Tjek om logfilen findes
if [ ! -f "$LOG_FILE" ]; then
    echo "Fejl: $LOG_FILE findes ikke!"
    echo "Du skal måske køre scriptet med sudo."
    exit 1
fi

# Tjek om vi har læserettigheder
if [ ! -r "$LOG_FILE" ]; then
    echo "Fejl: Ingen læserettigheder til $LOG_FILE"
    echo "Kør scriptet med sudo: sudo $0"
    exit 1
fi

# Find mislykkede loginforsøg
# Søger efter "Failed password", "authentication failure", etc.
failed=$(grep -E "Failed password|authentication failure|Invalid user" "$LOG_FILE" | tail -10)

if [ -z "$failed" ]; then
    echo "Ingen mislykkede loginforsøg fundet i loggen."
else
    echo "$failed"
    echo ""
    echo "---"
    
    # Tæl total antal mislykkede forsøg i loggen
    total=$(grep -c -E "Failed password|authentication failure|Invalid user" "$LOG_FILE")
    echo "Total antal mislykkede forsøg i denne log: $total"
fi