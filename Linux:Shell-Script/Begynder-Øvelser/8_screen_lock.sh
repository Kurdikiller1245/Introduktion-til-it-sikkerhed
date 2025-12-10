#!/bin/bash
# Script der låser skærmen efter 5 minutters inaktivitet

echo "Starter skærmlås-overvågning..."
echo "Skærmen låses efter 5 minutters inaktivitet"
echo "Tryk Ctrl+C for at stoppe"
echo ""

# Inaktivitetstid i millisekunder (5 minutter = 300000 ms)
TIMEOUT=300000

while true; do
    # Hent idle tid fra X11
    if command -v xprintidle &> /dev/null; then
        idle=$(xprintidle)
        
        if [ $idle -ge $TIMEOUT ]; then
            echo "$(date '+%H:%M:%S') - Inaktivitet detekteret! Låser skærm..."
            
            # Prøv forskellige screen lockers
            if command -v gnome-screensaver-command &> /dev/null; then
                gnome-screensaver-command -l
            elif command -v xdg-screensaver &> /dev/null; then
                xdg-screensaver lock
            elif command -v i3lock &> /dev/null; then
                i3lock -c 000000
            else
                echo "Ingen screen locker fundet!"
            fi
            
            # Vent 30 sekunder før næste tjek
            sleep 30
        fi
    else
        echo "Fejl: xprintidle er ikke installeret!"
        echo "Installer med: sudo apt install xprintidle"
        exit 1
    fi
    
    # Tjek hvert 10. sekund
    sleep 10
done