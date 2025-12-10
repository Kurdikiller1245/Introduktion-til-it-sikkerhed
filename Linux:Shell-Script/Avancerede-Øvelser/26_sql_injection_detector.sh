#!/bin/bash
# Script der analyserer Apache-logs og finder mulige SQL-injection-forsøg

LOG_FILE="${1:-/var/log/apache2/access.log}"
OUTPUT_FILE="sql_injection_report_$(date +%Y%m%d_%H%M%S).txt"
ALERT_THRESHOLD=5

echo "=== SQL Injection Attack Detector ==="
echo ""

# Tjek om log fil findes
if [ ! -f "$LOG_FILE" ]; then
    echo "Fejl: Log fil '$LOG_FILE' findes ikke!"
    echo ""
    echo "Brug: $0 [log-fil]"
    echo "Eksempel: $0 /var/log/apache2/access.log"
    exit 1
fi

echo "Analyserer: $LOG_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# SQL Injection patterns
declare -A sqli_patterns=(
    ["UNION"]="union.*select|union.*all.*select"
    ["COMMENT"]="--.*|/\*.*\*/|#.*"
    ["BOOLEAN"]="'.*or.*'.*=.*'|1.*=.*1|'.*or.*1.*--"
    ["STACKED"]=".*;.*drop|.*;.*update|.*;.*delete"
    ["BLIND"]="sleep\(|benchmark\(|waitfor.*delay"
    ["ERROR"]="'.*group.*by|'.*having|'.*order.*by.*--"
    ["INJECTION"]="'.*\).*or.*\(|'.*and.*\(|\".*or.*\""
    ["DROP"]="drop.*table|drop.*database|drop.*column"
    ["INSERT"]="insert.*into.*values|insert.*into.*select"
    ["UPDATE"]="update.*set.*where"
    ["EXEC"]="exec\(|execute\(|xp_cmdshell"
    ["LOAD_FILE"]="load_file\(|load.*data.*infile"
    ["INFORMATION"]="information_schema|mysql.user|sys.database"
)

# Init report
{
    echo "=== SQL Injection Analysis Report ==="
    echo "Log File: $LOG_FILE"
    echo "Analysis Date: $(date)"
    echo "Threshold: $ALERT_THRESHOLD attempts"
    echo ""
    echo "========================================"
    echo ""
} > "$OUTPUT_FILE"

echo "Scanning for SQL injection patterns..."
echo ""

# Scan for hver pattern
total_attempts=0
declare -A ip_attempts

for pattern_name in "${!sqli_patterns[@]}"; do
    pattern="${sqli_patterns[$pattern_name]}"
    
    echo -n "Checking for $pattern_name attacks... "
    
    # Find matches (case insensitive)
    matches=$(grep -iE "$pattern" "$LOG_FILE" 2>/dev/null)
    count=$(echo "$matches" | grep -c . 2>/dev/null || echo "0")
    
    if [ "$count" -gt 0 ]; then
        echo "⚠️  $count found"
        total_attempts=$((total_attempts + count))
        
        {
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Attack Type: $pattern_name"
            echo "Pattern: $pattern"
            echo "Count: $count"
            echo ""
            echo "Examples:"
            echo "$matches" | head -5
            echo ""
        } >> "$OUTPUT_FILE"
        
        # Udtræk IP'er for disse forsøg
        echo "$matches" | grep -oE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
        while read -r ip; do
            ip_attempts["$ip"]=$((${ip_attempts[$ip]:-0} + 1))
        done
    else
        echo "✓ None"
    fi
done

echo ""
echo "=== Analysis Complete ==="
echo ""
echo "Total SQL injection attempts detected: $total_attempts"

# Top 10 angribende IP'er
if [ "$total_attempts" -gt 0 ]; then
    echo ""
    echo "=== Top Attacking IP Addresses ==="
    {
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "TOP ATTACKING IP ADDRESSES"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    } >> "$OUTPUT_FILE"
    
    # Print IP attempts sorted
    for ip in "${!ip_attempts[@]}"; do
        echo "${ip_attempts[$ip]} $ip"
    done | sort -rn | head -10 | while read -r count ip; do
        printf "%-15s : %5d attempts" "$ip" "$count"
        
        # Tjek om over threshold
        if [ "$count" -ge "$ALERT_THRESHOLD" ]; then
            printf " ⚠️  HIGH RISK"
        fi
        echo ""
        
        # Log til rapport
        echo "$ip - $count attempts" >> "$OUTPUT_FILE"
        
        # Vis eksempler for denne IP
        {
            echo ""
            echo "Examples from $ip:"
            grep "^$ip" "$LOG_FILE" | grep -iE "union.*select|drop.*table|'.*or.*'" | head -3
            echo ""
        } >> "$OUTPUT_FILE"
    done
fi

# Detaljeret analyse af payloads
echo ""
echo "=== Payload Analysis ==="
{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "DETECTED PAYLOADS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
} >> "$OUTPUT_FILE"

# Udtræk unikke payloads
echo "Extracting unique payloads..."
grep -iE "union.*select|drop.*table|'.*or.*'|insert.*into" "$LOG_FILE" | \
awk '{
    for(i=1; i<=NF; i++) {
        if ($i ~ /[?&]/ || $i ~ /=/) {
            print $i
        }
    }
}' | sort -u | head -20 | while read -r payload; do
    echo "  • $payload"
    echo "$payload" >> "$OUTPUT_FILE"
done

# Tidsbaseret analyse
echo ""
echo "=== Timeline Analysis ==="
{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ATTACK TIMELINE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
} >> "$OUTPUT_FILE"

echo "Analyzing attack timeline..."

# Group by hour
grep -iE "union.*select|drop.*table|'.*or.*'" "$LOG_FILE" | \
awk '{print $4}' | cut -d: -f1-2 | sort | uniq -c | sort -rn | head -10 | \
while read -r count time; do
    printf "%s : %d attempts\n" "$time" "$count"
    echo "$time - $count attempts" >> "$OUTPUT_FILE"
done

# Targeted URLs
echo ""
echo "=== Most Targeted URLs ==="
{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TARGETED URLS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
} >> "$OUTPUT_FILE"

grep -iE "union.*select|drop.*table|'.*or.*'" "$LOG_FILE" | \
awk '{print $7}' | cut -d? -f1 | sort | uniq -c | sort -rn | head -10 | \
while read -r count url; do
    printf "%-50s : %d attempts\n" "$url" "$count"
    echo "$url - $count attempts" >> "$OUTPUT_FILE"
done

# Recommendations
echo ""
echo "=== Security Recommendations ==="
{
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "SECURITY RECOMMENDATIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
} >> "$OUTPUT_FILE"

recommendations=(
    "1. Implement prepared statements/parameterized queries"
    "2. Use Web Application Firewall (WAF) like ModSecurity"
    "3. Validate and sanitize all user inputs"
    "4. Implement rate limiting for suspicious IPs"
    "5. Use least privilege database accounts"
    "6. Block identified attacker IPs at firewall level"
    "7. Enable SQL injection detection in your IDS/IPS"
    "8. Regular security audits and penetration testing"
    "9. Keep all software and frameworks updated"
    "10. Implement proper error handling (don't expose DB errors)"
)

for rec in "${recommendations[@]}"; do
    echo "$rec"
    echo "$rec" >> "$OUTPUT_FILE"
done

# Generate IP blocklist
if [ "$total_attempts" -gt 0 ]; then
    echo ""
    echo "=== Generating IP Blocklist ==="
    
    blocklist_file="sqli_blocklist_$(date +%Y%m%d).txt"
    
    echo "# SQL Injection Attacker IPs - $(date)" > "$blocklist_file"
    echo "# Auto-generated by SQL Injection Detector" >> "$blocklist_file"
    echo "" >> "$blocklist_file"
    
    for ip in "${!ip_attempts[@]}"; do
        if [ "${ip_attempts[$ip]}" -ge "$ALERT_THRESHOLD" ]; then
            echo "$ip  # ${ip_attempts[$ip]} attempts" >> "$blocklist_file"
        fi
    done
    
    echo "✓ Blocklist genereret: $blocklist_file"
    echo ""
    echo "Block IPs with:"
    echo "  iptables: while read ip _; do iptables -A INPUT -s \$ip -j DROP; done < $blocklist_file"
    echo "  ufw: while read ip _; do ufw deny from \$ip; done < $blocklist_file"
fi

echo ""
echo "✓ Detaljeret rapport gemt til: $OUTPUT_FILE"
echo ""

# Summary
if [ "$total_attempts" -gt 0 ]; then
    echo "⚠️  SECURITY ALERT: SQL injection attempts detected!"
    echo "   Review the report and take immediate action."
else
    echo "✓ No SQL injection attempts detected in the analyzed logs."
fi