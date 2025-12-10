#!/bin/bash
# Script der overvåger åbne netværksforbindelser og logger nye

STATE_FILE="/tmp/network_connections.state"
LOG_FILE="/tmp/network_connections.log"
INTERVAL=5

echo "=== Network Connection Monitor ==="
echo "Logger til: $LOG_FILE"
echo "Tjek interval: ${INTERVAL} sekunder"
echo "Tryk Ctrl+C for at stoppe"
echo ""

# Init log fil
if [ ! -f "$LOG_FILE" ]; then
    echo "=== Network Connection Monitor Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi

# Funktion til at hente aktive forbindelser
get_connections() {
    # Brug ss (moderne) eller netstat (fallback)
    if command -v ss &> /dev/null; then
        ss -tunp 2>/dev/null | grep ESTAB
    elif command -v netstat &> /dev/null; then
        netstat -tunp 2>/dev/null | grep ESTABLISHED
    else
        echo "Fejl: Hverken ss eller netstat er tilgængelig!"
        exit 1
    fi
}

# Funktion til at parse forbindelse til hash
connection_hash() {
    echo "$1" | md5sum | awk '{print $1}'
}

# Init state fil
get_connections > "$STATE_FILE"

echo "Initial state gemt. Starter overvågning..."
echo ""

new_connections=0

# Monitor loop
while true; do
    # Hent nuværende forbindelser
    current_connections=$(get_connections)
    
    # Sammenlign med forrige state
    while IFS= read -r conn; do
        # Skip tomme linjer
        [ -z "$conn" ] && continue
        
        # Tjek om forbindelsen er ny
        if ! grep -qF "$conn" "$STATE_FILE" 2>/dev/null; then
            ((new_connections++))
            
            # Parse forbindelses-info
            if command -v ss &> /dev/null; then
                # ss format
                protocol=$(echo "$conn" | awk '{print $1}')
                local_addr=$(echo "$conn" | awk '{print $5}')
                remote_addr=$(echo "$conn" | awk '{print $6}')
                process=$(echo "$conn" | awk '{print $7}')
            else
                # netstat format
                protocol=$(echo "$conn" | awk '{print $1}')
                local_addr=$(echo "$conn" | awk '{print $4}')
                remote_addr=$(echo "$conn" | awk '{print $5}')
                process=$(echo "$conn" | awk '{print $7}')
            fi
            
            timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            
            # Log ny forbindelse
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🔵 NY FORBINDELSE DETEKTERET"
            echo "Time: $timestamp"
            echo "Protocol: $protocol"
            echo "Local: $local_addr"
            echo "Remote: $remote_addr"
            echo "Process: $process"
            echo ""
            
            # Log til fil
            {
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "Time: $timestamp"
                echo "Protocol: $protocol"
                echo "Local: $local_addr"
                echo "Remote: $remote_addr"
                echo "Process: $process"
                echo ""
            } >> "$LOG_FILE"
            
            # Ekstra info om remote IP
            remote_ip=$(echo "$remote_addr" | cut -d':' -f1)
            
            # Tjek om det er en lokal IP
            if [[ "$remote_ip" =~ ^127\. ]] || [[ "$remote_ip" =~ ^192\.168\. ]] || [[ "$remote_ip" =~ ^10\. ]]; then
                echo "  ℹ️  Local/Private IP"
            else
                echo "  🌐 External IP: $remote_ip"
                
                # Reverse DNS lookup
                if command -v dig &> /dev/null; then
                    hostname=$(dig +short -x "$remote_ip" 2>/dev/null | head -1)
                    if [ -n "$hostname" ]; then
                        echo "  🏷️  Hostname: $hostname"
                    fi
                fi
                
                # GeoIP lookup hvis tilgængelig
                if command -v geoiplookup &> /dev/null; then
                    geo=$(geoiplookup "$remote_ip" 2>/dev/null | awk -F': ' '{print $2}')
                    if [ -n "$geo" ]; then
                        echo "  🌍 Location: $geo"
                    fi
                fi
                
                # Whois info (kun første linje)
                if command -v whois &> /dev/null; then
                    org=$(whois "$remote_ip" 2>/dev/null | grep -i "orgname\|netname" | head -1)
                    if [ -n "$org" ]; then
                        echo "  🏢 Org: $org"
                    fi
                fi
            fi
            
            echo ""
            
            # Send notifikation hvis muligt
            if command -v notify-send &> /dev/null; then
                notify-send "New Network Connection" "Remote: $remote_addr"
            fi
        fi
    done <<< "$current_connections"
    
    # Opdater state
    echo "$current_connections" > "$STATE_FILE"
    
    # Status linje
    total_connections=$(echo "$current_connections" | grep -c .)
    echo -ne "\r$(date '+%H:%M:%S') | Aktive: $total_connections | Nye fundet: $new_connections"
    
    sleep "$INTERVAL"
done

# Cleanup ved exit
trap 'echo ""; echo ""; echo "Afslutter..."; echo "Total nye forbindelser logget: $new_connections"; echo "Log: $LOG_FILE"; exit 0' SIGINT SIGTERM