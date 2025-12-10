#!/usr/bin/env python3
"""
Opgave 12: Generer sikker adgangskode
"""

import random
import string

def generer_adgangskode(længde=16, brug_store=True, brug_små=True, 
                        brug_tal=True, brug_symboler=True):
    """Generer en sikker adgangskode med specificerede krav"""
    
    if længde < 4:
        print("Adgangskoden skal være mindst 4 tegn lang")
        return None
    
    # Byg character pool
    tegn = ""
    if brug_store:
        tegn += string.ascii_uppercase
    if brug_små:
        tegn += string.ascii_lowercase
    if brug_tal:
        tegn += string.digits
    if brug_symboler:
        tegn += string.punctuation
    
    if not tegn:
        print("Mindst én tegntype skal være valgt")
        return None
    
    # Generer adgangskode
    adgangskode = ''.join(random.choice(tegn) for _ in range(længde))
    
    # Verificer at alle krævede typer er inkluderet
    har_store = any(c in string.ascii_uppercase for c in adgangskode)
    har_små = any(c in string.ascii_lowercase for c in adgangskode)
    har_tal = any(c in string.digits for c in adgangskode)
    har_symboler = any(c in string.punctuation for c in adgangskode)
    
    # Hvis ikke alle krav er opfyldt, prøv igen
    if (brug_store and not har_store) or (brug_små and not har_små) or \
       (brug_tal and not har_tal) or (brug_symboler and not har_symboler):
        return generer_adgangskode(længde, brug_store, brug_små, brug_tal, brug_symboler)
    
    return adgangskode

def vurder_styrke(adgangskode):
    """Vurder styrken af en adgangskode"""
    if not adgangskode:
        return "Ugyldig"
    
    længde = len(adgangskode)
    har_store = any(c in string.ascii_uppercase for c in adgangskode)
    har_små = any(c in string.ascii_lowercase for c in adgangskode)
    har_tal = any(c in string.digits for c in adgangskode)
    har_symboler = any(c in string.punctuation for c in adgangskode)
    
    point = 0
    if længde >= 12:
        point += 2
    elif længde >= 8:
        point += 1
    
    point += sum([har_store, har_små, har_tal, har_symboler])
    
    if point <= 2:
        return "Svag ⚠"
    elif point <= 4:
        return "Middel 🔶"
    else:
        return "Stærk ✓"

def main():
    print("=" * 70)
    print("SIKKER ADGANGSKODE GENERATOR")
    print("=" * 70)
    
    try:
        længde = int(input("Indtast ønsket længde (standard 16): ") or "16")
        
        print("\nVælg tegntyper (tryk Enter for ja, n for nej):")
        brug_store = input("Inkluder store bogstaver (A-Z)? ").lower() != 'n'
        brug_små = input("Inkluder små bogstaver (a-z)? ").lower() != 'n'
        brug_tal = input("Inkluder tal (0-9)? ").lower() != 'n'
        brug_symboler = input("Inkluder symboler (!@#$...)? ").lower() != 'n'
        
        antal = int(input("\nHvor mange adgangskoder vil du generere? (standard 5): ") or "5")
        
        print("\n" + "=" * 70)
        print("GENEREREDE ADGANGSKODER:")
        print("=" * 70)
        
        for i in range(antal):
            pwd = generer_adgangskode(længde, brug_store, brug_små, brug_tal, brug_symboler)
            styrke = vurder_styrke(pwd)
            print(f"{i+1}. {pwd} - Styrke: {styrke}")
        
        print("=" * 70)
        
    except ValueError:
        print("Ugyldig input")
    except KeyboardInterrupt:
        print("\n\nAfbrudt")

if __name__ == "__main__":
    main()