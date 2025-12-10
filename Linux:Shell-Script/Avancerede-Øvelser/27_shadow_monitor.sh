#!/bin/bash
# Script der overvåger rettigheder på /etc/shadow og advarer ved ændringer

SHADOW_FILE="/etc/shadow"
BACKUP_FILE="/tmp/shadow.backup"
CHECKSUM_FILE="/tmp/shadow.checksum"
LOG_FILE="/var/log/shadow_monitor.log"
CHECK_INTERVAL=30

echo "=== /etc/shadow Monitor ==="
echo ""

# Tjek om vi kører som root
if [ "$EUID" -ne 0 ]; then
    echo "Fejl: Dette script skal køres som root!"
    echo "Kør med: sudo $0"
    exit 1
fi

# Tjek om shadow fil findes
if [ ! -f "$SHADOW_FILE" ]; then
    echo "Fejl: $SHADOW_FILE findes ikke!"
    exit 1
fi

echo "Overvåger: $SHADOW_FILE"
echo "Logger til: $LOG_FILE"
echo "Tjek interval: ${CHECK_INTERVAL}s"
echo ""

# Funktion til at logge events
log_event() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $message" | tee -a "$LOG_FILE"
}

# Funktion til at sende alert
send_alert() {
    local subject="$1"
    local message="$2"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔴 SECURITY ALERT: $subject"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$message"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    log_event "ALERT: $subject - $message"
    
    # Send notification hvis muligt
    if command -v notify-send &> /dev/null; then
        notify-send -u critical "Shadow File Alert" "$subject"
    fi
    
    # Send email hvis configureret
    if command -v mail &> /dev/null; then
        echo "$message" | mail -s "SECURITY ALERT: $subject" root 2>/dev/null
    fi
}

# Funktion til at tjekke rettigheder
check_permissions() {
    local perms=$(stat -c "%a" "$SHADOW_FILE")
    local owner=$(stat -c "%U:%G" "$SHADOW_FILE")
    
    # Shadow skal være 640 eller 000
    if [ "$perms" != "640" ] && [ "$perms" != "000" ]; then
        send_alert "Incorrect Permissions" \
"Shadow file has incorrect permissions!

File: $SHADOW_FILE
Current: $perms
Expected: 640 or 000
Owner: $owner

This is a CRITICAL security issue!
Recommended action: chmod 640 $SHADOW_FILE"
        return 1
    fi
    
    # Tjek owner (skal være root:shadow eller root:root)
    if [ "$owner" != "root:shadow" ] && [ "$owner" != "root:root" ]; then
        send_alert "Incorrect Owner" \
"Shadow file has incorrect ownership!

File: $SHADOW_FILE
Current: $owner
Expected: root:shadow or root:root

This is a CRITICAL security issue!
Recommended action: chown root:shadow $SHADOW_FILE"
        return 1
    fi
    
    return 0
}

# Funktion til at tjekke for content ændringer
check_content() {
    local current_checksum=$(sha256sum "$SHADOW_FILE" | awk '{print $1}')
    
    if [ -f "$CHECKSUM_FILE" ]; then
        local stored_checksum=$(cat "$CHECKSUM_FILE")
        
        if [ "$current_checksum" != "$stored_checksum" ]; then
            # Content er ændret
            if [ -f "$BACKUP_FILE" ]; then
                # Sammenlign med backup for at se hvad der er ændret
                local diff_output=$(diff "$BACKUP_FILE" "$SHADOW_FILE")
                
                send_alert "Content Modified" \
"Shadow file content has been modified!

File: $SHADOW_FILE
Old checksum: $stored_checksum
New checksum: $current_checksum

Changes detected:
$diff_output

Possible reasons:
- User password changed
- New user created
- User deleted
- Unauthorized modification"
            else
                send_alert "Content Modified" \
"Shadow file content has been modified!

File: $SHADOW_FILE
Old checksum: $stored_checksum
New checksum: $current_checksum"
            fi
            
            # Opdater backup og checksum
            cp "$SHADOW_FILE" "$BACKUP_FILE"
            echo "$current_checksum" > "$CHECKSUM_FILE"
            
            return 1
        fi
    else
        # First run - create initial checksum
        echo "$current_checksum" > "$CHECKSUM_FILE"
        cp "$SHADOW_FILE" "$BACKUP_FILE"
        log_event "Initial checksum created: $current_checksum"
    fi
    
    return 0
}

# Funktion til at tjekke for suspicious accounts
check_suspicious_accounts() {
    # Tjek for accounts uden password
    local no_pass_accounts=$(awk -F: '$2 == "" {print $1}' "$SHADOW_FILE")
    
    if [ -n "$no_pass_accounts" ]; then
        send_alert "Accounts Without Password" \
"Found user accounts without passwords!

Accounts:
$no_pass_accounts

This is a security risk!"
    fi
    
    # Tjek for accounts med UID 0 (ud over root)
    local uid_zero=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd)
    
    if [ -n "$uid_zero" ]; then
        send_alert "Non-Root UID 0 Accounts" \
"Found non-root accounts with UID 0!

Accounts:
$uid_zero

This could indicate a backdoor!"
    fi
    
    # Tjek for accounts med weak hashes (DES, MD5)
    local weak_hashes=$(awk -F: '$2 ~ /^\$1\$/ || length($2) == 13 {print $1}' "$SHADOW_FILE")
    
    if [ -n "$weak_hashes" ]; then
        send_alert "Weak Password Hashes" \
"Found accounts with weak password hashes!

Accounts:
$weak_hashes

Recommendation: Force password change to use stronger hashing."
    fi
}

# Initial checks
log_event "Shadow monitor started"
echo "Performing initial checks..."
echo ""

check_permissions
check_content
check_suspicious_accounts

echo ""
echo "Initial checks complete. Starting continuous monitoring..."
echo "Press Ctrl+C to stop."
echo ""

# Monitor loop
checks=0
while true; do
    ((checks++))
    
    # Status update hver 10. check
    if [ $((checks % 10)) -eq 0 ]; then
        echo "$(date '+%H:%M:%S') - Check #$checks - Status OK"
    fi
    
    # Tjek rettigheder
    if ! check_permissions; then
        # Critical issue - fix automatically hvis muligt
        echo "Attempting to fix permissions..."
        chmod 640 "$SHADOW_FILE"
        chown root:shadow "$SHADOW_FILE"
        
        if check_permissions; then
            log_event "Permissions automatically corrected"
            echo "✓ Permissions fixed"
        fi
    fi
    
    # Tjek content
    check_content
    
    # Tjek for suspicious accounts hver time
    if [ $((checks % 120)) -eq 0 ]; then
        check_suspicious_accounts
    fi
    
    # Vent før næste check
    sleep "$CHECK_INTERVAL"
done

# Cleanup ved exit
trap 'log_event "Shadow monitor stopped"; echo ""; echo "Monitor stopped. Total checks: $checks"; exit 0' SIGINT SIGTERM