#!/bin/bash
# Script der genererer en tilfældig adgangskode på 16 tegn

LENGTH="${1:-16}"

echo "=== Password Generator ==="
echo ""

# Metode 1: Brug /dev/urandom og tr (mest sikker)
echo "Metode 1: Alfanumerisk + special tegn"
password1=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}|;:,.<>?' < /dev/urandom | head -c "$LENGTH")
echo "$password1"
echo ""

# Metode 2: Kun alfanumerisk
echo "Metode 2: Kun alfanumerisk"
password2=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$LENGTH")
echo "$password2"
echo ""

# Metode 3: Med openssl (hvis tilgængelig)
if command -v openssl &> /dev/null; then
    echo "Metode 3: OpenSSL base64"
    password3=$(openssl rand -base64 "$LENGTH" | tr -d '/+=' | head -c "$LENGTH")
    echo "$password3"
    echo ""
fi

# Metode 4: Stærk password med alle tegn typer garanteret
echo "Metode 4: Garanteret mix (store, små, tal, special)"
# Sikr mindst et af hver type
upper=$(tr -dc 'A-Z' < /dev/urandom | head -c 4)
lower=$(tr -dc 'a-z' < /dev/urandom | head -c 4)
digit=$(tr -dc '0-9' < /dev/urandom | head -c 4)
special=$(tr -dc '!@#$%^&*()_+-=' < /dev/urandom | head -c 4)

# Kombiner og bland
password4=$(echo "${upper}${lower}${digit}${special}" | fold -w1 | shuf | tr -d '\n')
echo "$password4"
echo ""

# Beregn password styrke (simpel check)
echo "--- Password Styrke Info ---"
echo "Længde: ${#password1} tegn"

# Tjek kompleksitet for password1
has_upper=0
has_lower=0
has_digit=0
has_special=0

[[ "$password1" =~ [A-Z] ]] && has_upper=1
[[ "$password1" =~ [a-z] ]] && has_lower=1
[[ "$password1" =~ [0-9] ]] && has_digit=1
[[ "$password1" =~ [^A-Za-z0-9] ]] && has_special=1

complexity=$((has_upper + has_lower + has_digit + has_special))

echo "Kompleksitet score: $complexity/4"
echo "  Store bogstaver: $([[ $has_upper -eq 1 ]] && echo '✓' || echo '✗')"
echo "  Små bogstaver: $([[ $has_lower -eq 1 ]] && echo '✓' || echo '✗')"
echo "  Tal: $([[ $has_digit -eq 1 ]] && echo '✓' || echo '✗')"
echo "  Special tegn: $([[ $has_special -eq 1 ]] && echo '✓' || echo '✗')"