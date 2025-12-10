#!/bin/bash
# Script der laver hash af en fil og tjekker integritet

HASH_FILE=".file_hashes.db"

echo "=== File Integrity Checker ==="
echo ""

# Funktion til at hashe en fil
hash_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Fejl: Filen '$file' findes ikke!"
        return 1
    fi
    
    echo "Hasher fil: $file"
    hash=$(sha256sum "$file" | awk '{print $1}')
    
    # Gem hash i database
    echo "$file:$hash:$(date '+%Y-%m-%d %H:%M:%S')" >> "$HASH_FILE"
    
    echo "SHA256: $hash"
    echo "Hash gemt i $HASH_FILE"
}

# Funktion til at verificere en fil
verify_file() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo "Fejl: Filen '$file' findes ikke!"
        return 1
    fi
    
    if [ ! -f "$HASH_FILE" ]; then
        echo "Fejl: Ingen hash database fundet!"
        echo "Kør først: $0 hash <filnavn>"
        return 1
    fi
    
    # Hent gemt hash
    stored_hash=$(grep "^$file:" "$HASH_FILE" | tail -1 | cut -d':' -f2)
    
    if [ -z "$stored_hash" ]; then
        echo "Fejl: Ingen hash fundet for '$file'"
        echo "Kør først: $0 hash $file"
        return 1
    fi
    
    # Beregn nuværende hash
    current_hash=$(sha256sum "$file" | awk '{print $1}')
    
    echo "Verificerer fil: $file"
    echo ""
    echo "Gemt hash:     $stored_hash"
    echo "Nuværende hash: $current_hash"
    echo ""
    
    if [ "$stored_hash" == "$current_hash" ]; then
        echo "✓ INTEGRITET OK - Filen er uændret!"
        return 0
    else
        echo "✗ ADVARSEL! INTEGRITET FEJLET - Filen er blevet ændret!"
        return 1
    fi
}

# Funktion til at vise alle hashes
list_hashes() {
    if [ ! -f "$HASH_FILE" ]; then
        echo "Ingen hash database fundet."
        return
    fi
    
    echo "--- Gemte File Hashes ---"
    echo ""
    printf "%-40s %-64s %s\n" "FIL" "HASH" "DATO"
    echo "------------------------------------------------------------"
    
    while IFS=':' read -r file hash date; do
        printf "%-40s %-64s %s\n" "$file" "$hash" "$date"
    done < "$HASH_FILE"
}

# Hovedmenu
case "$1" in
    hash)
        if [ -z "$2" ]; then
            echo "Brug: $0 hash <filnavn>"
            exit 1
        fi
        hash_file "$2"
        ;;
    
    verify)
        if [ -z "$2" ]; then
            echo "Brug: $0 verify <filnavn>"
            exit 1
        fi
        verify_file "$2"
        ;;
    
    list)
        list_hashes
        ;;
    
    batch)
        # Hash multiple filer
        if [ -z "$2" ]; then
            echo "Brug: $0 batch <directory>"
            exit 1
        fi
        
        dir="$2"
        echo "Hasher alle filer i $dir..."
        echo ""
        
        find "$dir" -type f | while read -r file; do
            hash_file "$file"
        done
        ;;
    
    *)
        echo "Brug:"
        echo "  $0 hash <filnavn>       - Hash en fil"
        echo "  $0 verify <filnavn>     - Verificer en fils integritet"
        echo "  $0 list                 - Vis alle gemte hashes"
        echo "  $0 batch <directory>    - Hash alle filer i directory"
        echo ""
        echo "Eksempel:"
        echo "  $0 hash /etc/passwd"
        echo "  $0 verify /etc/passwd"
        exit 1
        ;;
esac