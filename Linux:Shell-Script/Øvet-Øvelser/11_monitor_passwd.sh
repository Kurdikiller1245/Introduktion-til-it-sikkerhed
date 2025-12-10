#!/bin/bash
# Script der overvåger ændringer i /etc/passwd

PASSWD_FILE="/etc/passwd"
BACKUP_FILE="/tmp/passwd.backup"
LOG_FILE="/tmp/passwd_changes.log"

echo "=== /etc/passwd Monitor ==="
echo "Logger til: $LOG_FILE"
echo "Tryk Ctrl+C for at stoppe"
echo ""

# Lav initial backup hvis den ikke findes
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Laver initial backup..."
    cp "$PASSWD_FILE" "$BACKUP_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Initial backup oprettet" >> "$LOG_FILE"
fi

# Monitor loop
while true; do
    # Sammenlign filer
    if ! diff -q "$PASSWD_FILE" "$BACKUP_FILE" > /dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ÆNDRING DETEKTERET!"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - ÆNDRING DETEKTERET!" >> "$LOG_FILE"
        
        # Log forskelle
        echo "" >> "$LOG_FILE"
        echo "--- Forskelle ---" >> "$LOG_FILE"
        diff "$BACKUP_FILE" "$PASSWD_FILE" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        
        # Vis forskelle på skærmen
        echo "Forskelle:"
        diff --color=always "$BACKUP_FILE" "$PASSWD_FILE"
        echo ""
        
        # Opdater backup
        cp "$PASSWD_FILE" "$BACKUP_FILE"
        
        # Send notifikation hvis muligt
        if command -v notify-send &> /dev/null; then
            notify-send "Password File Changed" "/etc/passwd er blevet ændret!"
        fi
    fi
    
    # Vent 5 sekunder før næste tjek
    sleep 5
done