#!/bin/bash
# Script der søger rekursivt efter world-writable filer

START_DIR="${1:-.}"

echo "=== World-Writable Files Scanner ==="
echo "Scanner directory: $START_DIR"
echo ""

# Tjek om directory eksisterer
if [ ! -d "$START_DIR" ]; then
    echo "Fejl: Directory '$START_DIR' findes ikke!"
    exit 1
fi

echo "Søger efter world-writable filer..."
echo "Dette kan tage noget tid..."
echo ""

# Find world-writable filer (permissions: -wx eller rwx for other)
echo "--- World-Writable Filer ---"
find "$START_DIR" -type f -perm -o+w 2>/dev/null | while read -r file; do
    perms=$(stat -c "%A" "$file")
    owner=$(stat -c "%U:%G" "$file")
    size=$(stat -c "%s" "$file")
    
    echo "⚠️  $file"
    echo "    Permissions: $perms | Owner: $owner | Size: $size bytes"
done

echo ""
echo "--- World-Writable Directories ---"
find "$START_DIR" -type d -perm -o+w 2>/dev/null | while read -r dir; do
    perms=$(stat -c "%A" "$dir")
    owner=$(stat -c "%U:%G" "$dir")
    
    echo "⚠️  $dir"
    echo "    Permissions: $perms | Owner: $owner"
done

echo ""
echo "--- Statistik ---"
file_count=$(find "$START_DIR" -type f -perm -o+w 2>/dev/null | wc -l)
dir_count=$(find "$START_DIR" -type d -perm -o+w 2>/dev/null | wc -l)

echo "World-writable filer fundet: $file_count"
echo "World-writable directories fundet: $dir_count"

# Advarsel hvis der findes writable filer
if [ $file_count -gt 0 ] || [ $dir_count -gt 0 ]; then
    echo ""
    echo "⚠️  SIKKERHEDSADVARSEL!"
    echo "World-writable filer/directories er en sikkerhedsrisiko."
    echo "Alle brugere kan ændre disse filer!"
    echo ""
    echo "Fix med: chmod o-w <filnavn>"
fi

# Ekstra checks
echo ""
echo "--- Ekstra Sikkerhedschecks ---"

# Find SUID filer der også er world-writable
echo "SUID + World-writable (meget farligt!):"
suid_writable=$(find "$START_DIR" -type f -perm -u+s -perm -o+w 2>/dev/null | wc -l)
if [ $suid_writable -gt 0 ]; then
    echo "⚠️  KRITISK: $suid_writable SUID filer er world-writable!"
    find "$START_DIR" -type f -perm -u+s -perm -o+w 2>/dev/null
else
    echo "✓ Ingen SUID + world-writable filer"
fi

# Find scripts der er world-writable
echo ""
echo "Executable scripts der er world-writable:"
script_count=$(find "$START_DIR" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.pl" \) -perm -o+w 2>/dev/null | wc -l)
if [ $script_count -gt 0 ]; then
    echo "⚠️  $script_count executable scripts er world-writable"
else
    echo "✓ Ingen world-writable scripts"
fi