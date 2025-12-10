#!/bin/bash
# Script der roterer og krypterer logs automatisk

LOG_DIRS=("/var/log/apache2" "/var/log/nginx" "/var/log/auth.log" "/var/log/syslog")
ARCHIVE_DIR="/var/log/archives"
ENCRYPTION_KEY="/etc/log_encryption.key"
RETENTION_DAYS=90
COMPRESS_TOOL="gzip"  # eller xz, bzip2

echo "=== Log Rotation & Encryption System ==="
echo ""

# Tjek root rettigheder
if [ "$EUID" -ne 0 ]; then
    echo "Dette script kræver root rettigheder"
    echo "Kør med: sudo $0"
    exit 1
fi

# Setup funktion
setup() {
    echo "=== Initial Setup ==="
    echo ""
    
    # Opret archive directory
    mkdir -p "$ARCHIVE_DIR"
    chmod 700 "$ARCHIVE_DIR"
    
    # Generer encryption key hvis den ikke findes
    if [ ! -f "$ENCRYPTION_KEY" ]; then
        echo "Generating encryption key..."
        openssl rand -base64 32 > "$ENCRYPTION_KEY"
        chmod 600 "$ENCRYPTION_KEY"
        echo "✓ Encryption key created: $ENCRYPTION_KEY"
        echo "⚠️  BACKUP THIS KEY! Without it, logs cannot be decrypted!"
    fi
    
    # Opret cron job
    CRON_JOB="0 2 * * * $0 rotate"
    
    if ! crontab -l 2>/dev/null | grep -q "$0 rotate"; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "✓ Cron job installed (daily at 2 AM)"
    fi
    
    echo ""
    echo "Setup complete!"
}

# Rotate funktion
rotate_logs() {
    echo "=== Starting Log Rotation ==="
    echo "Time: $(date)"
    echo ""
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    rotated_count=0
    
    # Custom log directories fra argument eller default
    if [ -n "$1" ]; then
        LOG_DIRS=("$1")
    fi
    
    for log_location in "${LOG_DIRS[@]}"; do
        if [ ! -e "$log_location" ]; then
            echo "⚠️  Skipping $log_location (not found)"
            continue
        fi
        
        echo "Processing: $log_location"
        
        # Hvis det er en directory
        if [ -d "$log_location" ]; then
            find "$log_location" -type f -name "*.log" | while read -r logfile; do
                process_log_file "$logfile" "$TIMESTAMP"
            done
        # Hvis det er en fil
        elif [ -f "$log_location" ]; then
            process_log_file "$log_location" "$TIMESTAMP"
        fi
    done
    
    # Cleanup gamle archives
    cleanup_old_archives
    
    echo ""
    echo "✓ Log rotation complete"
    echo "Logs archived to: $ARCHIVE_DIR"
}

# Process enkelt log fil
process_log_file() {
    local logfile="$1"
    local timestamp="$2"
    
    # Skip hvis filen er tom
    if [ ! -s "$logfile" ]; then
        return
    fi
    
    # Generer archive filnavn
    local basename=$(basename "$logfile")
    local archive_name="${basename%.log}_${timestamp}"
    
    echo "  → $logfile"
    
    # 1. Compress log
    echo "    Compressing..."
    case "$COMPRESS_TOOL" in
        gzip)
            gzip -c "$logfile" > "$ARCHIVE_DIR/${archive_name}.gz"
            compressed_file="$ARCHIVE_DIR/${archive_name}.gz"
            ;;
        xz)
            xz -c "$logfile" > "$ARCHIVE_DIR/${archive_name}.xz"
            compressed_file="$ARCHIVE_DIR/${archive_name}.xz"
            ;;
        bzip2)
            bzip2 -c "$logfile" > "$ARCHIVE_DIR/${archive_name}.bz2"
            compressed_file="$ARCHIVE_DIR/${archive_name}.bz2"
            ;;
    esac
    
    # 2. Encrypt compressed file
    echo "    Encrypting..."
    openssl enc -aes-256-cbc -salt -pbkdf2 \
        -in "$compressed_file" \
        -out "${compressed_file}.enc" \
        -pass file:"$ENCRYPTION_KEY"
    
    # 3. Remove unencrypted compressed file
    rm -f "$compressed_file"
    
    # 4. Create checksum
    sha256sum "${compressed_file}.enc" > "${compressed_file}.enc.sha256"
    
    # 5. Truncate original log (keep structure)
    echo "    Truncating original log..."
    > "$logfile"
    
    # Get file size
    size=$(stat -c %s "${compressed_file}.enc")
    echo "    ✓ Archived: ${archive_name} (${size} bytes)"
    
    ((rotated_count++))
}

# Cleanup gamle archives
cleanup_old_archives() {
    echo ""
    echo "Cleaning up archives older than $RETENTION_DAYS days..."
    
    deleted_count=0
    find "$ARCHIVE_DIR" -type f -name "*.enc" -mtime "+$RETENTION_DAYS" | while read -r old_file; do
        echo "  Deleting: $(basename "$old_file")"
        rm -f "$old_file" "${old_file}.sha256"
        ((deleted_count++))
    done
    
    if [ $deleted_count -eq 0 ]; then
        echo "  No old archives to delete"
    else
        echo "  ✓ Deleted $deleted_count old archives"
    fi
}

# Decrypt funktion
decrypt_log() {
    local encrypted_file="$1"
    
    if [ -z "$encrypted_file" ]; then
        echo "Usage: $0 decrypt <encrypted-file>"
        exit 1
    fi
    
    if [ ! -f "$encrypted_file" ]; then
        echo "Error: File not found: $encrypted_file"
        exit 1
    fi
    
    echo "=== Decrypting Log ==="
    echo "File: $encrypted_file"
    echo ""
    
    # Verify checksum først
    if [ -f "${encrypted_file}.sha256" ]; then
        echo "Verifying checksum..."
        if sha256sum -c "${encrypted_file}.sha256" 2>/dev/null; then
            echo "✓ Checksum OK"
        else
            echo "✗ Checksum verification FAILED!"
            read -p "Continue anyway? (y/n): " continue
            [[ ! "$continue" =~ ^[Yy]$ ]] && exit 1
        fi
        echo ""
    fi
    
    # Decrypt
    output_file="${encrypted_file%.enc}"
    
    echo "Decrypting..."
    if openssl enc -aes-256-cbc -d -pbkdf2 \
        -in "$encrypted_file" \
        -out "$output_file" \
        -pass file:"$ENCRYPTION_KEY"; then
        
        echo "✓ Decrypted to: $output_file"
        echo ""
        
        # Decompress
        echo "Decompressing..."
        case "$output_file" in
            *.gz)
                gunzip "$output_file"
                final_file="${output_file%.gz}"
                ;;
            *.xz)
                unxz "$output_file"
                final_file="${output_file%.xz}"
                ;;
            *.bz2)
                bunzip2 "$output_file"
                final_file="${output_file%.bz2}"
                ;;
        esac
        
        echo "✓ Decompressed to: $final_file"
        echo ""
        
        # Preview
        echo "Preview (first 20 lines):"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        head -20 "$final_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
    else
        echo "✗ Decryption failed!"
        exit 1
    fi
}

# List archives
list_archives() {
    echo "=== Archived Logs ==="
    echo ""
    
    if [ ! -d "$ARCHIVE_DIR" ]; then
        echo "No archives found"
        return
    fi
    
    echo "Location: $ARCHIVE_DIR"
    echo ""
    
    total_size=0
    count=0
    
    printf "%-50s %-12s %-20s\n" "FILE" "SIZE" "DATE"
    echo "────────────────────────────────────────────────────────────────────────────────"
    
    find "$ARCHIVE_DIR" -type f -name "*.enc" -printf "%f %s %TY-%Tm-%Td %TH:%TM\n" | \
    sort -r | while read -r filename size date time; do
        size_mb=$(echo "scale=2; $size / 1048576" | bc)
        printf "%-50s %8s MB  %s %s\n" "$filename" "$size_mb" "$date" "$time"
        ((count++))
        total_size=$((total_size + size))
    done
    
    echo ""
    total_size_mb=$(echo "scale=2; $total_size / 1048576" | bc 2>/dev/null || echo "0")
    archive_count=$(find "$ARCHIVE_DIR" -type f -name "*.enc" | wc -l)
    echo "Total: $archive_count archives, ${total_size_mb} MB"
}

# Status
show_status() {
    echo "=== Log Rotation Status ==="
    echo ""
    
    # Check if setup
    if [ -f "$ENCRYPTION_KEY" ]; then
        echo "Encryption: ✓ Configured"
    else
        echo "Encryption: ✗ Not configured (run setup)"
    fi
    
    if [ -d "$ARCHIVE_DIR" ]; then
        archive_count=$(find "$ARCHIVE_DIR" -type f -name "*.enc" 2>/dev/null | wc -l)
        echo "Archives: $archive_count files in $ARCHIVE_DIR"
    else
        echo "Archives: None"
    fi
    
    # Check cron
    if crontab -l 2>/dev/null | grep -q "$0 rotate"; then
        echo "Automation: ✓ Enabled (daily at 2 AM)"
    else
        echo "Automation: ✗ Not configured"
    fi
    
    echo ""
    echo "Configuration:"
    echo "  Retention: $RETENTION_DAYS days"
    echo "  Compression: $COMPRESS_TOOL"
    echo "  Encryption: AES-256-CBC"
    
    echo ""
    list_archives
}

# Main menu
case "${1:-help}" in
    setup)
        setup
        ;;
    
    rotate)
        rotate_logs "${2}"
        ;;
    
    decrypt)
        decrypt_log "$2"
        ;;
    
    list)
        list_archives
        ;;
    
    status)
        show_status
        ;;
    
    cleanup)
        cleanup_old_archives
        ;;
    
    *)
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  setup              - Initial setup (create key, cron job)"
        echo "  rotate [dir]       - Rotate and encrypt logs"
        echo "  decrypt <file>     - Decrypt an archived log"
        echo "  list               - List all archived logs"
        echo "  status             - Show system status"
        echo "  cleanup            - Remove archives older than retention period"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 rotate"
        echo "  $0 rotate /var/log/myapp"
        echo "  $0 decrypt /var/log/archives/access_20240101_020000.gz.enc"
        echo "  $0 list"
        echo ""
        echo "Configuration:"
        echo "  Archive directory: $ARCHIVE_DIR"
        echo "  Encryption key: $ENCRYPTION_KEY"
        echo "  Retention: $RETENTION_DAYS days"
        ;;
esac