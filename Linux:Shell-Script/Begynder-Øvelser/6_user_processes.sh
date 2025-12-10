#!/bin/bash
# Script der viser alle kørende processer for en given bruger

# Tjek om der er givet et brugernavn
if [ $# -eq 0 ]; then
    echo "Brug: $0 <brugernavn>"
    echo "Eksempel: $0 root"
    exit 1
fi

bruger="$1"

# Tjek om brugeren findes
if ! id "$bruger" &>/dev/null; then
    echo "Fejl: Brugeren '$bruger' findes ikke!"
    exit 1
fi

echo "=== Processer for bruger: $bruger ==="
echo ""

# Vis processer for brugeren
ps -u "$bruger" -o pid,ppid,%cpu,%mem,stat,start,time,cmd

echo ""
echo "---"

# Tæl antal processer
antal=$(ps -u "$bruger" --no-headers | wc -l)
echo "Total antal processer: $antal"