#!/usr/bin/env python3
"""
Opgave 5: Omdøb alle .txt filer til .md filer
"""

import os
from pathlib import Path

def omdob_txt_til_md(mappe="."):
    """Omdøb alle .txt filer til .md filer i en given mappe"""
    print("=" * 60)
    print(f"OMDØB .TXT TIL .MD FILER I {mappe}")
    print("=" * 60)
    
    sti = Path(mappe)
    
    if not sti.exists():
        print(f"Fejl: Mappen '{mappe}' findes ikke!")
        return
    
    # Find alle .txt filer
    txt_filer = list(sti.glob("*.txt"))
    
    if not txt_filer:
        print("Ingen .txt filer fundet i mappen")
        return
    
    print(f"Fandt {len(txt_filer)} .txt filer:\n")
    
    # Vis filer og bed om bekræftelse
    for txt_fil in txt_filer:
        print(f"  {txt_fil.name}")
    
    svar = input("\nOmdøb disse filer? (ja/nej): ")
    
    if svar.lower() in ['ja', 'j', 'yes', 'y']:
        print("\nOmdøber filer...")
        for txt_fil in txt_filer:
            md_fil = txt_fil.with_suffix(".md")
            print(f"  {txt_fil.name} → {md_fil.name}")
            txt_fil.rename(md_fil)
        print("\n✓ Alle filer omdøbt!")
    else:
        print("\nAfbrudt - ingen filer blev ændret")
    
    print("=" * 60)

if __name__ == "__main__":
    # Opret test-mappe med nogle .txt filer
    test_mappe = Path("./test_txt_filer")
    test_mappe.mkdir(exist_ok=True)
    
    # Opret nogle test filer hvis de ikke findes
    for i in range(3):
        test_fil = test_mappe / f"test{i}.txt"
        if not test_fil.exists():
            test_fil.write_text(f"Dette er test fil {i}")
    
    omdob_txt_til_md(test_mappe)