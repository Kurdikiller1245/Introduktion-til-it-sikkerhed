#!/bin/bash
# Script der overvåger /var/log/auth.log og sender mail ved mistænkelig aktivitet

AUTH_LOG="/var/log/auth.log"
STATE_FILE="/tmp/auth_monitor.state"
ALERT_FILE="/tmp/auth_alerts.txt"
EMAIL="${1:-admin@example.com}"
THRESHOLD_FAILED=5
THRESHOLD_TIME=300  # 5 minutter

echo "=== Auth Log Monitor ==="
echo ""

# Tjek om auth.log findes
if [ ! -f "$AUTH_LOG" ]; then
    echo "Fejl: $AUTH_LOG findes ikke!"
    exit 1
fi

# Tjek læserettigheder
if [ ! -r "$AUTH_LOG" ]; then
    echo "Fejl: Kan ikke læse $AUTH_LOG"
    echo "Kør med sudo: sudo $0"
    exit 1
fi

# Tjek om mail er konfigureret
if ! command -v mail &> /dev/null && ! command -v sendmail &> /dev/null; then
    echo "⚠️  ADVARSEL: Hverken 'mail' eller 'sendmail' er installeret!"
    echo "Installer med: sudo apt install mailutils"
    echo ""
    echo "Fortsætter uden email notifikationer..."
    SEND_EMAIL=0
else
    SEND_EMAIL=1
    echo "Email notifikationer: Aktiveret"
    echo "Email adresse: $EMAIL"
fi

echo ""
echo "Overvåger: $AUTH_LOG"
echo "Tærskel: $THRESHOLD_FAILED fejlede forsøg på $THRESHOLD_TIME sekunder"
echo ""

# Init state file
if [ ! -f "$STATE_FILE" ]; then
    wc -l < "$AUTH_LOG" > "$STATE_FILE"
fi

# Funktion til at sende email
send_alert_email() {
    local subject="$1"
    local body="$2"
    
    if [ $SEND_EMAIL -eq 1 ]; then
        echo "$body" | mail -s "$subject" "$EMAIL" 2>/dev/null
        echo "📧 Email sendt til $EMAIL"
    fi
}

# Funktion til at tjekke for brute force
check_brute_force() {
    local timeframe=$(($(date +%s) - THRESHOLD_TIME))
    local timestamp=$(date -d "@$timeframe" '+%b %e %H:%M')
    
    # Find mislykkede login forsøg i tidsrammen
    failed_attempts=$(grep "Failed password" "$AUTH_LOG" | \
                     awk -v ts="$timestamp" '$0 > ts' | \
                     awk '{print $(NF-5)}' | sort | uniq -c | sort -rn)
    
    echo "$failed_attempts" | while read -r count ip; do
        if [ "$count" -ge "$THRESHOLD_FAILED" ]; then
            echo "⚠️  BRUTE FORCE DETEKTERET!"
            echo "   IP: $ip"
            echo "   Forsøg: $count i de sidste 5 minutter"
            
            alert_msg="BRUTE FORCE ATTACK DETECTED

IP Address: $ip
Failed Attempts: $count
Time Window: Last 5 minutes
Server: $(hostname)
Time: $(date)

Recent attempts:
$(grep "$ip" "$AUTH_LOG" | grep "Failed password" | tail -5)
"
            
            echo "$alert_msg" >> "$ALERT_FILE"
            send_alert_email "SECURITY ALERT: Brute Force Attack" "$alert_msg"
            
            return 0
        fi
    done
}

# Funktion til at detektere mistænkelige aktiviteter
detect_suspicious() {
    local new_lines="$1"
    
    # Tjek for root login
    if echo "$new_lines" | grep -q "Accepted.*root"; then
        local login_info=$(echo "$new_lines" | grep "Accepted.*root")
        
        alert_msg="ROOT LOGIN DETECTED

$(echo "$login_info")

Server: $(hostname)
Time: $(date)
"
        
        echo "🔴 ROOT LOGIN detekteret!"
        echo "$alert_msg" >> "$ALERT_FILE"
        send_alert_email "SECURITY ALERT: Root Login" "$alert_msg"
    fi
    
    # Tjek for sudo usage
    if echo "$new_lines" | grep -q "sudo.*COMMAND"; then
        local sudo_count=$(echo "$new_lines" | grep -c "sudo.*COMMAND")
        
        if [ "$sudo_count" -gt 10 ]; then
            alert_msg="EXCESSIVE SUDO USAGE

$sudo_count sudo commands executed recently

Recent commands:
$(echo "$new_lines" | grep "sudo.*COMMAND" | tail -5)

Server: $(hostname)
Time: $(date)
"
            
            echo "⚠️  Unormal sudo aktivitet ($sudo_count kommandoer)"
            echo "$alert_msg" >> "$ALERT_FILE"
            send_alert_email "SECURITY ALERT: Excessive Sudo Usage" "$alert_msg"
        fi
    fi
    
    # Tjek for nye brugere
    if echo "$new_lines" | grep -q "new user"; then
        local user_info=$(echo "$new_lines" | grep "new user")
        
        alert_msg="NEW USER CREATED

$user_info

Server: $(hostname)
Time: $(date)
"
        
        echo "👤 Ny bruger oprettet!"
        echo "$alert_msg" >> "$ALERT_FILE"
        send_alert_email "SECURITY ALERT: New User Created" "$alert_msg"
    fi
    
    # Tjek for session opened fra usædvanlige IP'er
    if echo "$new_lines" | grep -q "session opened"; then
        local sessions=$(echo "$new_lines" | grep "session opened")
        
        # Udtræk IP'er
        echo "$sessions" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u | while read -r ip; do
            # Tjek om det er en lokal IP
            if [[ ! "$ip" =~ ^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01])\.) ]]; then
                alert_msg="EXTERNAL IP LOGIN

External IP detected: $ip
Session info:
$(echo "$sessions" | grep "$ip")

Server: $(hostname)
Time: $(date)
"
                
                echo "🌐 Login fra ekstern IP: $ip"
                echo "$alert_msg" >> "$ALERT_FILE"
                send_alert_email "SECURITY ALERT: External IP Login" "$alert_msg"
            fi
        done
    fi
    
    # Tjek for authentication failures
    local auth_failures=$(echo "$new_lines" | grep -c "authentication failure")
    if [ "$auth_failures" -gt 3 ]; then
        echo "⚠️  $auth_failures authentication failures detekteret"
    fi
}

echo "Monitor startet. Tryk Ctrl+C for at stoppe."
echo ""

# Main monitoring loop
while true; do
    # Hent nuværende antal linjer
    current_lines=$(wc -l < "$AUTH_LOG")
    previous_lines=$(cat "$STATE_FILE")
    
    # Tjek for nye linjer
    if [ "$current_lines" -gt "$previous_lines" ]; then
        new_line_count=$((current_lines - previous_lines))
        
        # Hent de nye linjer
        new_lines=$(tail -n "$new_line_count" "$AUTH_LOG")
        
        echo "$(date '+%H:%M:%S') - $new_line_count nye log entries"
        
        # Analyser nye linjer
        detect_suspicious "$new_lines"
        
        # Tjek for brute force
        check_brute_force
        
        # Opdater state
        echo "$current_lines" > "$STATE_FILE"
    fi
    
    # Vent 10 sekunder
    sleep 10
done

# Cleanup
trap 'echo ""; echo "Monitor stoppet."; echo "Alerts gemt til: $ALERT_FILE"; exit 0' SIGINT SIGTERM