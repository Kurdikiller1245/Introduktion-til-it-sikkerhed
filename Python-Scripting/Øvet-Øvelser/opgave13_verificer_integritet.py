#!/usr/bin/env python3
"""
Opgave 13: Verificer fil-integritet med SHA256
"""

import hashlib
from pathlib import Path

def beregn_sha256(fil_sti):
    """Beregn SHA256 hash af en fil"""
    sha256 = hashlib.sha256()
    
    try:
        with open(fil_sti, 'rb') as f:
            while chunk := f.read(8192):
                sha256.update(chunk)
        return sha256.hexdigest()
    except FileNotFoundError:
        print(f"Fejl: Filen '{fil_sti}' findes ikke")
        return None
    except PermissionError:
        print(f"Fejl: Ingen adgang til '{fil_sti}'")
        return None
    except Exception as e:
        print(f"Fejl ved læsning af fil: {e}")
        return None

def verificer_integritet(fil_sti, forventet_hash):
    """Verificer at filens hash matcher den forventede hash"""
    print(f"Verificerer: {fil_sti}")
    print(f"Forventet hash: {forventet_hash}")
    
    beregnet_hash = beregn_sha256(fil_sti)
    
    if beregnet_hash is None:
        return False
    
    print(f"Beregnet hash: {beregnet_hash}")
    
    if beregnet_hash == forventet_hash:
        print("\n✓ VERIFICERING SUCCESSFUL")
        print("Filens integritet er intakt")
        return True
    else:
        print("\n✗ VERIFICERING FEJLET")
        print("⚠ ADVARSEL: Filen er blevet ændret eller er korrupt!")
        return False

def main():
    print("=" * 70)
    print("FIL-INTEGRITET VERIFICERING")
    print("=" * 70)
    
    # Eksempel: Opret en test fil
    test_fil = Path("test_integritet.txt")
    test_indhold = "Dette er en test fil til integritetskontrol\n"
    
    if not test_fil.exists():
        test_fil.write_text(test_indhold)
        print(f"Oprettet test fil: {test_fil}")
    
    # Beregn hash af test filen
    original_hash = beregn_sha256(test_fil)
    
    print(f"\nOriginal hash af {test_fil}:")
    print(f"{original_hash}")
    
    print("\n" + "=" * 70)
    print("TEST 1: Verificer uændret fil")
    print("=" * 70)
    verificer_integritet(test_fil, original_hash)
    
    print("\n" + "=" * 70)
    print("TEST 2: Verificer efter ændring")
    print("=" * 70)
    
    # Ændr filen
    test_fil.write_text(test_indhold + "ÆNDRET!\n")
    verificer_integritet(test_fil, original_hash)
    
    # Gendan filen
    test_fil.write_text(test_indhold)
    
    print("\n" + "=" * 70)
    print("VERIFICER DIN EGEN FIL")
    print("=" * 70)
    
    try:
        fil_sti = input("Indtast fil-sti: ").strip()
        if fil_sti:
            beregnet = beregn_sha256(fil_sti)
            if beregnet:
                print(f"\nSHA256 hash: {beregnet}")
                
                kendt_hash = input("\nIndtast kendt hash for at verificere (eller Enter for at springe over): ").strip()
                if kendt_hash:
                    verificer_integritet(fil_sti, kendt_hash)
    except KeyboardInterrupt:
        print("\n\nAfbrudt")
    
    print("=" * 70)

if __name__ == "__main__":
    main()