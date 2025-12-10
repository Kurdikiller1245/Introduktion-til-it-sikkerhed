#!/bin/bash
# Script til at oprette honeyfiles og logge adgangsforsøg

HONEY_DIR="/var/honeypot"
LOG_FILE="/var/log/honeyfiles.log"
ALERT_FILE="/var/log/honeyfiles_alerts.log"
MONITOR_SCRIPT="/usr/local/bin/honeyfile_monitor.sh"

echo "=== Honeyfiles - Intrusion Detection ==="
echo ""

# Tjek root rettigheder for setup
if [ "$EUID" -ne 0 ] && [ "${1}" != "status" ]; then
    echo "Dette script kræver root rettigheder for setup"
    echo "Kør med: sudo $0"
    exit 1
fi

# Log funktion
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

# Alert funktion
send_alert() {
    local file="$1"
    local action="$2"
    local user="$3"
    local process="$4"
    
    alert_msg="HONEYFILE ACCESSED!

File: $file
Action: $action
User: $user
Process: $process
Time: $(date)
Host: $(hostname)
"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚨 INTRUSION DETECTED!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$alert_msg"
    
    log_event "ALERT: $file accessed by $user ($action)"
    echo "$alert_msg" >> "$ALERT_FILE"
    
    # Send notification
    if command -v notify-send &> /dev/null; then
        notify-send -u critical "Honeyfile Accessed" "File: $file by $user"
    fi
    
    # Send email hvis configureret
    if command -v mail &> /dev/null; then
        echo "$alert_msg" | mail -s "SECURITY ALERT: Honeyfile Accessed" root 2>/dev/null
    fi
}

# Opret honeyfiles
create_honeyfiles() {
    echo "Creating honeyfiles..."
    
    mkdir -p "$HONEY_DIR"
    
    # 1. Fake passwords file
    cat > "$HONEY_DIR/passwords.txt" <<EOF
# IMPORTANT PASSWORDS - DO NOT SHARE

Production Database:
Server: db.production.local
User: admin
Password: Pr0d_DB_P@ssw0rd_2024

AWS Root Account:
Email: admin@company.com
Password: AWS_R00t_Acc3ss_K3y

SSH Root:
Server: 192.168.1.100
User: root
Password: R00t_SSH_K3y_2024

Backup System:
FTP: backup.company.local
User: backup_admin
Password: B@ckup_Adm1n_P@ss
EOF
    
    # 2. Fake financial data
    cat > "$HONEY_DIR/financial_report_Q4.xlsx" <<EOF
Q4 Financial Report 2024
[This would be a real Excel file in production]

Revenue: $5,234,000
Expenses: $3,890,000
Net Profit: $1,344,000

Account Numbers:
Primary: 4532-8765-1234-9876
Secondary: 6789-4321-8765-5432
EOF
    
    # 3. Fake SSH keys
    mkdir -p "$HONEY_DIR/.ssh"
    cat > "$HONEY_DIR/.ssh/id_rsa" <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEA0bHoneyF5nYKGxCGk8H9fake_key_do_not_use
[Fake SSH private key - truncated]
-----END OPENSSH PRIVATE KEY-----
EOF
    
    # 4. Fake customer database
    cat > "$HONEY_DIR/customer_database.sql" <<EOF
-- Customer Database Export
-- Date: $(date)
-- CONFIDENTIAL

INSERT INTO customers VALUES
(1, 'John Doe', 'john@email.com', '555-1234', '123 Main St'),
(2, 'Jane Smith', 'jane@email.com', '555-5678', '456 Oak Ave'),
(3, 'Bob Johnson', 'bob@email.com', '555-9012', '789 Pine Rd');

-- Credit Card Information (ENCRYPTED)
INSERT INTO payments VALUES
(1, '4111111111111111', '12/25', '123'),
(2, '5500000000000004', '03/26', '456');
EOF
    
    # 5. Fake API keys
    cat > "$HONEY_DIR/.env" <<EOF
# Environment Variables - PRODUCTION

DATABASE_URL=postgresql://admin:secret123@db.internal:5432/prod
API_KEY=sk_live_fake_api_key_12345678
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
STRIPE_SECRET_KEY=sk_live_fake_stripe_key_90123
JWT_SECRET=super_secret_jwt_key_do_not_share
EOF
    
    # 6. Fake employee list
    cat > "$HONEY_DIR/employees_salary.csv" <<EOF
Name,Position,Salary,SSN
John Smith,CEO,250000,123-45-6789
Jane Doe,CTO,180000,987-65-4321
Bob Wilson,CFO,190000,456-78-9012
Alice Brown,VP Engineering,150000,789-01-2345
EOF
    
    # Set attractive but secure permissions
    chmod 600 "$HONEY_DIR"/*
    chmod 700 "$HONEY_DIR/.ssh"
    chmod 600 "$HONEY_DIR/.ssh/id_rsa"
    chown -R root:root "$HONEY_DIR"
    
    # Make files look old (last modified 30-90 days ago)
    for file in "$HONEY_DIR"/*; do
        days_old=$((30 + RANDOM % 60))
        touch -d "$days_old days ago" "$file"
    done
    
    log_event "Honeyfiles created in $HONEY_DIR"
    
    echo "✓ Honeyfiles created:"
    ls -lh "$HONEY_DIR"
    echo ""
    echo "✓ Hidden SSH directory:"
    ls -lha "$HONEY_DIR/.ssh"
}

# Setup monitoring med inotify
setup_monitoring() {
    echo "Setting up monitoring..."
    
    # Tjek om inotify-tools er installeret
    if ! command -v inotifywait &> /dev/null; then
        echo "Installing inotify-tools..."
        apt-get update && apt-get install -y inotify-tools
    fi
    
    # Opret monitor script
    cat > "$MONITOR_SCRIPT" <<'MONITOR_EOF'
#!/bin/bash

HONEY_DIR="/var/honeypot"
LOG_FILE="/var/log/honeyfiles.log"
ALERT_FILE="/var/log/honeyfiles_alerts.log"

log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

send_alert() {
    local file="$1"
    local event="$2"
    
    # Hent process info
    user=$(who | awk '{print $1}' | head -1)
    process=$(lsof "$file" 2>/dev/null | tail -1 | awk '{print $1,$2}')
    
    alert_msg="HONEYFILE ACCESSED!

File: $file
Event: $event
User: ${user:-unknown}
Process: ${process:-unknown}
Time: $(date)
Host: $(hostname)

This indicates potential unauthorized access!
"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚨 INTRUSION DETECTED!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$alert_msg"
    
    log_event "ALERT: $file - $event by ${user:-unknown}"
    echo "$alert_msg" >> "$ALERT_FILE"
    
    if command -v notify-send &> /dev/null; then
        notify-send -u critical "Honeyfile Accessed" "$file"
    fi
}

log_event "Honeyfile monitoring started"

inotifywait -m -r -e access,modify,open,close_write,move,delete "$HONEY_DIR" |
while read -r directory event filename; do
    full_path="${directory}${filename}"
    
    log_event "Event: $event on $full_path"
    
    case "$event" in
        ACCESS|OPEN|CLOSE_WRITE|MODIFY)
            send_alert "$full_path" "$event"
            ;;
    esac
done
MONITOR_EOF
    
    chmod +x "$MONITOR_SCRIPT"
    
    # Opret systemd service
    cat > /etc/systemd/system/honeyfiles.service <<EOF
[Unit]
Description=Honeyfiles Monitor
After=network.target

[Service]
Type=simple
ExecStart=$MONITOR_SCRIPT
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable honeyfiles.service
    systemctl start honeyfiles.service
    
    log_event "Monitoring service enabled"
    echo "✓ Monitor service created and started"
}

# Status
show_status() {
    echo "=== Honeyfiles Status ==="
    echo ""
    
    if [ -d "$HONEY_DIR" ]; then
        echo "Honeyfiles directory: $HONEY_DIR"
        echo "Files:"
        ls -lh "$HONEY_DIR" 2>/dev/null | tail -n +2
        echo ""
    else
        echo "Honeyfiles not deployed"
    fi
    
    if systemctl is-active --quiet honeyfiles.service 2>/dev/null; then
        echo "Monitoring: ✓ Active"
    else
        echo "Monitoring: ✗ Inactive"
    fi
    
    echo ""
    echo "Recent alerts:"
    if [ -f "$ALERT_FILE" ]; then
        tail -10 "$ALERT_FILE"
        echo ""
        echo "Total alerts: $(grep -c "HONEYFILE ACCESSED" "$ALERT_FILE" 2>/dev/null || echo 0)"
    else
        echo "No alerts"
    fi
}

# Main menu
case "${1:-menu}" in
    deploy)
        echo "Deploying honeyfiles..."
        create_honeyfiles
        setup_monitoring
        echo ""
        echo "✓ Honeyfiles deployed successfully!"
        echo ""
        echo "Monitor status: systemctl status honeyfiles"
        echo "View logs: tail -f $LOG_FILE"
        echo "View alerts: tail -f $ALERT_FILE"
        ;;
        
    status)
        show_status
        ;;
        
    stop)
        echo "Stopping monitoring..."
        systemctl stop honeyfiles.service
        echo "✓ Monitoring stopped"
        ;;
        
    start)
        echo "Starting monitoring..."
        systemctl start honeyfiles.service
        echo "✓ Monitoring started"
        ;;
        
    remove)
        echo "Removing honeyfiles..."
        systemctl stop honeyfiles.service 2>/dev/null
        systemctl disable honeyfiles.service 2>/dev/null
        rm -rf "$HONEY_DIR"
        rm -f "$MONITOR_SCRIPT"
        rm -f /etc/systemd/system/honeyfiles.service
        systemctl daemon-reload
        echo "✓ Honeyfiles removed"
        ;;
        
    *)
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  deploy  - Create honeyfiles and start monitoring"
        echo "  status  - Show current status and alerts"
        echo "  start   - Start monitoring"
        echo "  stop    - Stop monitoring"
        echo "  remove  - Remove all honeyfiles"
        echo ""
        echo "Honeyfiles are fake sensitive files that alert when accessed."
        echo "They help detect unauthorized access and intrusions."
        ;;
esac