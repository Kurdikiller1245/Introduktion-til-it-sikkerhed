#!/bin/bash
# Script der overvåger og dræber processer baseret på nøgleord

KEYWORD="${1}"
INTERVAL=5
LOG_FILE="/tmp/process_killer.log"

echo "=== Process Killer Monitor ==="
echo ""

# Tjek om nøgleord er angivet
if [ -z "$KEYWORD" ]; then
    echo "Brug: $0 <nøgleord> [interval]"
    echo ""
    echo "Eksempler:"
    echo "  $0 firefox           - Dræb alle firefox processer"
    echo "  $0 chrome 10         - Tjek hvert 10. sekund"
    echo "  $0 'python.*test'    - Brug regex patterns"
    exit 1
fi

# Valgfrit interval argument
if [ -n "$2" ]; then
    INTERVAL="$2"
fi

echo "Overvåger processer der matcher: '$KEYWORD'"
echo "Tjek interval: ${INTERVAL} sekunder"
echo "Logger til: $LOG_FILE"
echo ""
echo "⚠️  ADVARSEL: Dette script vil dræbe matchende processer!"
echo ""
read -p "Fortsæt? (y/n): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Afbrudt."
    exit 0
fi

echo ""
echo "Monitor kører... Tryk Ctrl+C for at stoppe"
echo ""

# Init log
echo "=== Process Killer Log ===" > "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
echo "Keyword: $KEYWORD" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

killed_count=0

# Monitor loop
while true; do
    # Find matchende processer
    pids=$(pgrep -f "$KEYWORD")
    
    if [ -n "$pids" ]; then
        echo "$(date '+%H:%M:%S') - Matchende processer fundet!"
        
        for pid in $pids; do
            # Hent process info
            if [ -d "/proc/$pid" ]; then
                cmd=$(ps -p "$pid" -o cmd --no-headers 2>/dev/null)
                user=$(ps -p "$pid" -o user --no-headers 2>/dev/null)
                
                echo "  PID: $pid | User: $user | CMD: $cmd"
                
                # Log før vi dræber
                echo "$(date '+%Y-%m-%d %H:%M:%S') | PID: $pid | User: $user | CMD: $cmd" >> "$LOG_FILE"
                
                # Forsøg at dræbe processen
                if kill "$pid" 2>/dev/null; then
                    echo "    ✓ Killed med SIGTERM"
                    ((killed_count++))
                    sleep 1
                    
                    # Tjek om processen stadig kører
                    if kill -0 "$pid" 2>/dev/null; then
                        echo "    ! Processen kører stadig, bruger SIGKILL"
                        kill -9 "$pid" 2>/dev/null
                        echo "    ✓ Force killed med SIGKILL"
                    fi
                else
                    echo "    ✗ Kunne ikke dræbe (manglende rettigheder?)"
                fi
            fi
        done
        
        echo ""
    fi
    
    # Vis status
    echo -ne "\r$(date '+%H:%M:%S') | Overvåger... | Dræbt: $killed_count processer"
    
    sleep "$INTERVAL"
done

# Cleanup på exit (ved Ctrl+C)
trap 'echo ""; echo ""; echo "=== Afsluttet ==="; echo "Total processer dræbt: $killed_count"; echo "Log: $LOG_FILE"; exit 0' SIGINT SIGTERM