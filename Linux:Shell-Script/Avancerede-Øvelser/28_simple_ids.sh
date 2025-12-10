#!/bin/bash
# Simpel Intrusion Detection System (IDS) med fil-checksums

CONFIG_FILE="/etc/simple_ids/config"
DB_FILE="/var/lib/simple_ids/checksums.db"
LOG_FILE="/var/log/simple_ids.log"
ALERT_FILE="/var/log/simple_ids_alerts.log"

echo "=== Simple IDS - File Integrity Monitor ==="
echo ""

# Tjek root rettigheder
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  ADVARSEL: Kører ikke som root - nogle filer kan ikke tilgås"
    echo ""
fi

# Opret directories
mkdir -p "$(dirname "$DB_FILE")" "$(dirname "$CONFIG_FILE")"

# Init log
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" | tee -a "$LOG_FILE"
}

# Default config hvis den ikke findes
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default configuration..."
    
    cat > "$CONFIG_FILE" <<EOF
# Simple IDS Configuration
# Directories and files to monitor (one per line)

# Critical system files
/etc/passwd
/etc/shadow
/etc/group
/etc/sudoers
/etc/hosts
/etc/ssh/sshd_config
/etc/crontab

# System binaries
/bin
/sbin
/usr/bin
/usr/sbin

# Boot files
/boot

# Important configs
/etc/apt
/etc/systemd

# Web server (uncomment if applicable)
# /var/www
# /etc/apache2
# /etc/nginx
EOF
    
    echo "✓ Default config created: $CONFIG_FILE"
    echo "Edit this file to customize monitoring."
    echo ""
fi

# Menu
case "${1:-menu}" in
    init|baseline)
        echo "=== Creating Baseline ==="
        echo ""
        echo "This will create checksums for all monitored files."
        echo "This should be done on a clean, trusted system."
        echo ""
        read -p "Continue? (y/n): " confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
        
        # Clear existing database
        > "$DB_FILE"
        
        total_files=0
        
        # Process config file
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            
            target="$line"
            
            if [ -f "$target" ]; then
                # Single file
                hash=$(sha256sum "$target" 2>/dev/null | awk '{print $1}')
                perms=$(stat -c "%a" "$target" 2>/dev/null)
                owner=$(stat -c "%U:%G" "$target" 2>/dev/null)
                
                echo "$target|$hash|$perms|$owner" >> "$DB_FILE"
                echo "  ✓ $target"
                ((total_files++))
                
            elif [ -d "$target" ]; then
                # Directory - find all files
                echo "  Scanning directory: $target"
                
                find "$target" -type f 2>/dev/null | while read -r file; do
                    hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
                    perms=$(stat -c "%a" "$file" 2>/dev/null)
                    owner=$(stat -c "%U:%G" "$file" 2>/dev/null)
                    
                    echo "$file|$hash|$perms|$owner" >> "$DB_FILE"
                    ((total_files++))
                done
            fi
        done < "$CONFIG_FILE"
        
        log_event "Baseline created with $total_files files"
        echo ""
        echo "✓ Baseline created: $DB_FILE"
        echo "  Total files: $total_files"
        ;;
        
    check|scan)
        echo "=== Running Integrity Check ==="
        echo ""
        
        if [ ! -f "$DB_FILE" ]; then
            echo "Error: No baseline database found!"
            echo "Run: $0 init"
            exit 1
        fi
        
        alerts=0
        modified=0
        deleted=0
        new_files=0
        perm_changed=0
        
        # Check each file in database
        while IFS='|' read -r file stored_hash stored_perms stored_owner; do
            if [ ! -f "$file" ]; then
                # File deleted
                echo "🔴 DELETED: $file"
                log_event "ALERT: File deleted - $file"
                echo "$(date) | DELETED | $file" >> "$ALERT_FILE"
                ((deleted++))
                ((alerts++))
                continue
            fi
            
            # Calculate current hash
            current_hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
            current_perms=$(stat -c "%a" "$file" 2>/dev/null)
            current_owner=$(stat -c "%U:%G" "$file" 2>/dev/null)
            
            # Check for modifications
            if [ "$current_hash" != "$stored_hash" ]; then
                echo "🔴 MODIFIED: $file"
                echo "   Old hash: $stored_hash"
                echo "   New hash: $current_hash"
                log_event "ALERT: File modified - $file"
                echo "$(date) | MODIFIED | $file | $stored_hash -> $current_hash" >> "$ALERT_FILE"
                ((modified++))
                ((alerts++))
            fi
            
            # Check permissions
            if [ "$current_perms" != "$stored_perms" ]; then
                echo "⚠️  PERMISSIONS: $file"
                echo "   Old: $stored_perms | New: $current_perms"
                log_event "ALERT: Permissions changed - $file"
                echo "$(date) | PERMISSIONS | $file | $stored_perms -> $current_perms" >> "$ALERT_FILE"
                ((perm_changed++))
                ((alerts++))
            fi
            
            # Check ownership
            if [ "$current_owner" != "$stored_owner" ]; then
                echo "⚠️  OWNERSHIP: $file"
                echo "   Old: $stored_owner | New: $current_owner"
                log_event "ALERT: Ownership changed - $file"
                echo "$(date) | OWNERSHIP | $file | $stored_owner -> $current_owner" >> "$ALERT_FILE"
                ((alerts++))
            fi
            
        done < "$DB_FILE"
        
        # Check for new files
        while IFS= read -r line; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            
            target="$line"
            
            if [ -d "$target" ]; then
                find "$target" -type f 2>/dev/null | while read -r file; do
                    if ! grep -q "^$file|" "$DB_FILE"; then
                        echo "🟡 NEW FILE: $file"
                        log_event "INFO: New file detected - $file"
                        ((new_files++))
                    fi
                done
            fi
        done < "$CONFIG_FILE"
        
        # Summary
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "SCAN SUMMARY"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Total alerts: $alerts"
        echo "  Modified files: $modified"
        echo "  Deleted files: $deleted"
        echo "  Permission changes: $perm_changed"
        echo "  New files: $new_files"
        
        log_event "Scan completed - $alerts alerts"
        
        if [ $alerts -gt 0 ]; then
            echo ""
            echo "⚠️  INTRUSION DETECTED!"
            echo "Review alerts in: $ALERT_FILE"
            
            # Send notification
            if command -v notify-send &> /dev/null; then
                notify-send -u critical "IDS Alert" "$alerts integrity violations detected!"
            fi
            
            exit 1
        else
            echo ""
            echo "✓ No integrity violations detected"
            exit 0
        fi
        ;;
        
    monitor)
        echo "=== Continuous Monitoring Mode ==="
        echo ""
        
        interval="${2:-300}"  # Default 5 minutes
        
        echo "Monitoring interval: ${interval}s"
        echo "Press Ctrl+C to stop"
        echo ""
        
        checks=0
        while true; do
            ((checks++))
            echo "$(date '+%H:%M:%S') - Check #$checks"
            
            $0 check
            
            sleep "$interval"
        done
        ;;
        
    update)
        echo "=== Update Baseline ==="
        echo ""
        echo "This will update the baseline with current file states."
        echo "Only do this if you trust the current system state!"
        echo ""
        read -p "Continue? (y/n): " confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
        
        $0 init
        ;;
        
    report)
        echo "=== IDS Report ==="
        echo ""
        
        if [ -f "$ALERT_FILE" ]; then
            echo "Recent alerts:"
            tail -50 "$ALERT_FILE"
            echo ""
            echo "Alert summary:"
            echo "  Total alerts: $(wc -l < "$ALERT_FILE")"
            echo "  Modified: $(grep -c "MODIFIED" "$ALERT_FILE")"
            echo "  Deleted: $(grep -c "DELETED" "$ALERT_FILE")"
            echo "  Permissions: $(grep -c "PERMISSIONS" "$ALERT_FILE")"
        else
            echo "No alerts found."
        fi
        ;;
        
    *)
        echo "Simple IDS - File Integrity Monitor"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  init       - Create baseline (first time setup)"
        echo "  check      - Check for integrity violations"
        echo "  monitor    - Continuous monitoring mode"
        echo "  update     - Update baseline with current state"
        echo "  report     - Show alert summary"
        echo ""
        echo "Configuration: $CONFIG_FILE"
        echo "Database: $DB_FILE"
        echo "Alerts: $ALERT_FILE"
        ;;
esac