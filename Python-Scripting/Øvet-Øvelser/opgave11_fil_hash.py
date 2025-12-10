#!/usr/bin/env python3
"""
Opgave 11: Overvåg filændringer med hash
Gemmer en hash af en fil og tjekker senere om den er ændret
"""

import hashlib
import json
from pathlib import Path

HASH_FILE = "file_hashes.json"

def beregn_fil_hash(fil_sti):
    """Beregn SHA256 hash af en fil"""
    sha256 = hashlib.sha256()
    
    try:
        with open(fil_sti, 'rb') as f:
            # Læs filen i chunks for at håndtere store filer
            while chunk := f.read(8192):
                sha256.update(chunk)
        return sha256.hexdigest()
    except Exception as e:
        print(f"Fejl ved læsning af fil: {e}")
        return None

def gem_hash(fil_sti, hash_værdi):
    """Gem hash til JSON fil"""
    hashes = {}
    
    # Indlæs eksisterende hashes
    if Path(HASH_FILE).exists():
        with open(HASH_FILE, 'r') as f:
            hashes = json.load(f)
    
    hashes[str(fil_sti)] = hash_værdi
    
    with open(HASH_FILE, 'w') as f:
        json.dump(hashes, f, indent=2)

def tjek_fil_ændring(fil_sti):
    """Tjek om fil er ændret siden sidste gang"""
    nuværende_hash = beregn_fil_hash(fil_sti)
    
    if nuværende_hash is None:
        return
    
    # Indlæs gemte hashes
    if not Path(HASH_FILE).exists():
        print(f"Ingen tidligere hash fundet for {fil_sti}")
        print(f"Gemmer ny hash: {nuværende_hash}")
        gem_hash(fil_sti, nuværende_hash)
        return
    
    with open(HASH_FILE, 'r') as f:
        hashes = json.load(f)
    
    tidligere_hash = hashes.get(str(fil_sti))
    
    if tidligere_hash is None:
        print(f"Første gang denne fil overvåges")
        print(f"Gemmer hash: {nuværende_hash}")
        gem_hash(fil_sti, nuværende_hash)
    elif tidligere_hash == nuværende_hash:
        print(f"✓ Filen er UÆNDRET")
        print(f"Hash: {nuværende_hash}")
    else:
        print(f"⚠ ADVARSEL: Filen ER ÆNDRET!")
        print(f"Tidligere hash: {tidligere_hash}")
        print(f"Nuværende hash: {nuværende_hash}")
        
        svar = input("Opdater hash til den nye værdi? (ja/nej): ")
        if svar.lower() in ['ja', 'j', 'yes', 'y']:
            gem_hash(fil_sti, nuværende_hash)
            print("Hash opdateret")

def main():
    print("=" * 70)
    print("OVERVÅG FILÆNDRINGER MED HASH")
    print("=" * 70)
    
    # Standard fil at overvåge
    standard_filer = ["/etc/passwd", "/etc/hosts", "test_fil.txt"]
    
    # Find første tilgængelige fil
    fil_sti = None
    for fil in standard_filer:
        if Path(fil).exists():
            fil_sti = fil
            break
    
    if fil_sti is None:
        print("Opretter test fil...")
        fil_sti = "test_fil.txt"
        Path(fil_sti).write_text("Dette er en test fil til overvågning\n")
    
    print(f"Overvåger fil: {fil_sti}\n")
    
    tjek_fil_ændring(fil_sti)
    
    print("\n" + "=" * 70)
    print("TIP: Kør scriptet igen efter at have ændret filen")
    print("=" * 70)

if __name__ == "__main__":
    main()
