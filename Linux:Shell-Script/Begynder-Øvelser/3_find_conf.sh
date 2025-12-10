#!/bin/bash
# Script der viser alle filer i /etc som ender på .conf

echo "=== Filer i /etc der ender på .conf ==="
echo ""

# Find alle .conf filer i /etc (kun filer, ikke directories)
find /etc -maxdepth 1 -type f -name "*.conf" 2>/dev/null | sort

# Tæl antal filer
antal=$(find /etc -maxdepth 1 -type f -name "*.conf" 2>/dev/null | wc -l)
echo ""
echo "Total antal .conf filer: $antal"