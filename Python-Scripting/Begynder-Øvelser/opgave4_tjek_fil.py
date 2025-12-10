#!/usr/bin/env python3
"""
Opgave 4: Tjek om en fil eksisterer
"""

from pathlib import Path
import os

def tjek_fil_eksistens(fil_sti):
    """Tjek om en fil eksisterer og print resultat"""
    # Metode 1: pathlib.Path
    fil = Path(fil_sti)
    if fil.exists():
        print(f"✓ '{fil_sti}' FINDES")
        if fil.is_file():
            print(f"  Type: Fil")
            print(f"  Størrelse: {fil.stat().st_size} bytes")
        elif fil.is_dir():
            print(f"  Type: Mappe")
    else:
        print(f"✗ '{fil_sti}' FINDES IKKE")

def main():
    print("=" * 60)
    print("TJEK FIL EKSISTENS")
    print("=" * 60)
    
    # Test forskellige filer
    test_filer = [
        "/etc/hosts",
        "/etc/passwd",
        "/etc/shadow",
        "denne_fil_findes_ikke.txt",
        "."
    ]
    
    for fil in test_filer:
        tjek_fil_eksistens(fil)
        print()
    
    # Tjek bruger-input
    fil_input = input("Indtast en fil-sti at tjekke (eller Enter for at springe over): ")
    if fil_input.strip():
        print()
        tjek_fil_eksistens(fil_input)
    
    print("=" * 60)

if __name__ == "__main__":
    main()