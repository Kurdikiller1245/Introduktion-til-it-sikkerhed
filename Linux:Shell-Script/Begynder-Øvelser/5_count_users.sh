#!/bin/bash
# Script der tæller hvor mange brugere der er logget ind

echo "=== Loggede brugere ==="
echo ""

# Vis alle loggede brugere
who

echo ""
echo "---"

# Tæl antal loggede brugere
antal=$(who | wc -l)
echo "Antal loggede brugere: $antal"

# Vis unikke brugernavne
echo ""
echo "Unikke brugere:"
who | awk '{print $1}' | sort -u