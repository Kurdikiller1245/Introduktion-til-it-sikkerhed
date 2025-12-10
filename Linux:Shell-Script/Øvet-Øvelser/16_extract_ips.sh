#!/bin/bash
# Script der udtrækker alle unikke IP-adresser fra en webserver-log

LOG_FILE="${1}"

echo "=== IP Adresse Extraktor ==="
echo ""

# Tjek om log fil er angivet
if [ -z "$LOG_FILE" ]; then
    echo "Brug: $0 <log-fil>"
    echo ""
    echo "Eksempler:"
    echo "  $0 /var/log/apache2/access.log"
    echo "  $0 /var/log/nginx/access.log"
    exit 1
fi

# Tjek om filen findes
if [ ! -f "$LOG_FILE" ]; then
    echo "Fejl: Log fil '$LOG_FILE' findes ikke!"
    exit 1
fi

echo "Analyserer: $LOG_FILE"
echo ""

# Udtræk alle IP adresser (IPv4)
# Matcher standard IPv4 format: xxx.xxx.xxx.xxx
echo "--- Alle Unikke IP Adresser ---"
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$LOG_FILE" | sort -u > /tmp/unique_ips.txt

# Vis IP'er
cat /tmp/unique_ips.txt

echo ""
echo "--- Statistik ---"
total_ips=$(cat /tmp/unique_ips.txt | wc -l)
total_requests=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$LOG_FILE" | wc -l)

echo "Unikke IP adresser: $total_ips"
echo "Total antal requests: $total_requests"

# Top 10 mest aktive IP'er
echo ""
echo "--- Top 10 Mest Aktive IP Adresser ---"
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10 | \
while read -r count ip; do
    printf "%-15s : %6d requests\n" "$ip" "$count"
done

# Geografisk distribution (hvis geoiplookup er tilgængelig)
if command -v geoiplookup &> /dev/null; then
    echo ""
    echo "--- Geografisk Distribution (Top 10) ---"
    head -10 /tmp/unique_ips.txt | while read -r ip; do
        country=$(geoiplookup "$ip" | awk -F': ' '{print $2}')
        echo "$ip - $country"
    done
fi

# HTTP status koder per IP (hvis Apache/Nginx format)
echo ""
echo "--- HTTP Status Koder ---"
echo "Status | Antal"
echo "-------|-------"
awk '{print $9}' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -10 | \
while read -r count status; do
    printf "  %3s  | %6d\n" "$status" "$count"
done

# Mistænkelige aktiviteter
echo ""
echo "--- Mistænkelige Aktiviteter ---"

# Tjek for SQL injection forsøg
sql_attempts=$(grep -i -E "union.*select|drop.*table|insert.*into|update.*set" "$LOG_FILE" | wc -l)
if [ $sql_attempts -gt 0 ]; then
    echo "⚠️  SQL Injection forsøg: $sql_attempts"
    echo "   IP'er involveret:"
    grep -i -E "union.*select|drop.*table|insert.*into" "$LOG_FILE" | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | sort -u | head -5
fi

# Tjek for directory traversal
traversal_attempts=$(grep -E '\.\./|\.\.\\\' "$LOG_FILE" | wc -l)
if [ $traversal_attempts -gt 0 ]; then
    echo "⚠️  Directory Traversal forsøg: $traversal_attempts"
fi

# Tjek for XSS forsøg
xss_attempts=$(grep -i -E "<script|javascript:|onerror=" "$LOG_FILE" | wc -l)
if [ $xss_attempts -gt 0 ]; then
    echo "⚠️  XSS forsøg: $xss_attempts"
fi

# Tjek for brute force (mange 401/403 fra samme IP)
echo ""
echo "--- Potentielle Brute Force Angreb ---"
awk '{print $1, $9}' "$LOG_FILE" 2>/dev/null | grep -E " (401|403)$" | \
awk '{print $1}' | sort | uniq -c | sort -rn | head -5 | \
while read -r count ip; do
    if [ "$count" -gt 50 ]; then
        printf "⚠️  %-15s : %d fejlede forsøg\n" "$ip" "$count"
    fi
done

# User agents (bots og crawlers)
echo ""
echo "--- Top User Agents ---"
awk -F'"' '{print $6}' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -5

# Eksporter resultater
OUTPUT_FILE="ip_analysis_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "=== IP Analysis Report ==="
    echo "Log File: $LOG_FILE"
    echo "Generated: $(date)"
    echo ""
    echo "Total Unique IPs: $total_ips"
    echo ""
    echo "All IPs:"
    cat /tmp/unique_ips.txt
} > "$OUTPUT_FILE"

echo ""
echo "✓ Rapport gemt til: $OUTPUT_FILE"

# Cleanup
rm -f /tmp/unique_ips.txt