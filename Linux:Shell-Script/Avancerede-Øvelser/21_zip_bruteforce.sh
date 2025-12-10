#!/bin/bash
# Script der brute-forcer en ZIP-fil med en ordliste

ZIP_FILE="${1}"
WORDLIST="${2:-/usr/share/wordlists/rockyou.txt}"
LOG_FILE="zip_crack_$(date +%Y%m%d_%H%M%S).log"

echo "=== ZIP Password Cracker ==="
echo ""

# Tjek argumenter
if [ -z "$ZIP_FILE" ]; then
    echo "Brug: $0 <zip-fil> [ordliste]"
    echo ""
    echo "Eksempel:"
    echo "  $0 secret.zip"
    echo "  $0 secret.zip /usr/share/wordlists/rockyou.txt"
    exit 1
fi

# Tjek om ZIP-fil findes
if [ ! -f "$ZIP_FILE" ]; then
    echo "Fejl: ZIP-fil '$ZIP_FILE' findes ikke!"
    exit 1
fi

# Tjek om wordlist findes
if [ ! -f "$WORDLIST" ]; then
    echo "Fejl: Ordliste '$WORDLIST' findes ikke!"
    echo ""
    echo "Download rockyou wordlist:"
    echo "  sudo apt install wordlists"
    echo "  sudo gunzip /usr/share/wordlists/rockyou.txt.gz"
    exit 1
fi

# Tjek om ZIP er password-beskyttet
if ! unzip -t "$ZIP_FILE" 2>&1 | grep -q "password"; then
    echo "✓ ZIP-filen er IKKE password-beskyttet!"
    echo "Udtrækker filer..."
    unzip "$ZIP_FILE"
    exit 0
fi

echo "Target: $ZIP_FILE"
echo "Wordlist: $WORDLIST"
echo "Logger til: $LOG_FILE"
echo ""

# Tjek om fzf er installeret (for unzip password cracking)
if ! command -v unzip &> /dev/null; then
    echo "Fejl: unzip er ikke installeret!"
    echo "Installer med: sudo apt install unzip"
    exit 1
fi

# Tæl passwords i wordlist
total_passwords=$(wc -l < "$WORDLIST")
echo "Total passwords i wordlist: $total_passwords"
echo ""

read -p "Start brute force? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Afbrudt."
    exit 0
fi

echo ""
echo "Starter brute force attack..."
echo "Dette kan tage lang tid..."
echo ""

# Init log
{
    echo "=== ZIP Brute Force Log ==="
    echo "Target: $ZIP_FILE"
    echo "Wordlist: $WORDLIST"
    echo "Started: $(date)"
    echo ""
} > "$LOG_FILE"

# Brute force
attempts=0
start_time=$(date +%s)
found=0

while IFS= read -r password; do
    ((attempts++))
    
    # Progress hver 1000. forsøg
    if [ $((attempts % 1000)) -eq 0 ]; then
        elapsed=$(($(date +%s) - start_time))
        rate=$((attempts / (elapsed + 1)))
        echo -ne "\rForsøg: $attempts/$total_passwords | Rate: $rate/s | Password: ${password:0:30}..."
    fi
    
    # Test password
    if unzip -q -P "$password" -t "$ZIP_FILE" 2>/dev/null; then
        found=1
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        
        echo ""
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🎉 PASSWORD FUNDET!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Password: $password"
        echo "Forsøg: $attempts"
        echo "Tid: ${elapsed}s"
        echo ""
        
        # Log success
        {
            echo "SUCCESS!"
            echo "Password: $password"
            echo "Attempts: $attempts"
            echo "Time: ${elapsed}s"
            echo "Found at: $(date)"
        } >> "$LOG_FILE"
        
        # Udtræk filer
        read -p "Udtræk filer nu? (y/n): " extract
        if [[ "$extract" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Udtrækker filer..."
            unzip -P "$password" "$ZIP_FILE"
            echo ""
            echo "✓ Filer udtrukket!"
        fi
        
        break
    fi
    
done < "$WORDLIST"

if [ $found -eq 0 ]; then
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    
    echo ""
    echo ""
    echo "✗ Password ikke fundet efter $attempts forsøg"
    echo "Tid brugt: ${elapsed}s"
    echo ""
    echo "Prøv:"
    echo "  - En anden ordliste"
    echo "  - fcrackzip: fcrackzip -u -D -p $WORDLIST $ZIP_FILE"
    echo "  - John the Ripper med zip2john"
    
    # Log failure
    {
        echo "FAILED"
        echo "Attempts: $attempts"
        echo "Time: ${elapsed}s"
    } >> "$LOG_FILE"
fi

echo ""
echo "Log gemt til: $LOG_FILE"