#!/usr/bin/env python3
"""
Opgave 14: Find filer med usikre rettigheder (world-writable)
"""

import os
import stat
from pathlib import Path

def er_world_writable(fil_stat):
    """Tjek om en fil er skrivbar for alle brugere"""
    return bool(fil_stat.st_mode & stat.S_IWOTH)

def find_usikre_filer(start_mappe, max_dybde=3):
    """Find alle world-writable filer i en mappe"""
    print(f"Scanner mappe: {start_mappe}")
    print(f"Max dybde: {max_dybde} niveauer\n")
    
    usikre_filer = []
    total_filer = 0
    fejl_count = 0
    
    try:
        for root, dirs, files in os.walk(start_mappe):
            # Begræns dybden
            dybde = root.replace(start_mappe, '').count(os.sep)
            if dybde > max_dybde:
                dirs.clear()
                continue
            
            for fil in files:
                total_filer += 1
                fil_sti = os.path.join(root, fil)
                
                try:
                    fil_stat = os.stat(fil_sti)
                    
                    if er_world_writable(fil_stat):
                        rettigheder = stat.filemode(fil_stat.st_mode)
                        usikre_filer.append({
                            'sti': fil_sti,
                            'rettigheder': rettigheder,
                            'størrelse': fil_stat.st_size
                        })
                        
                except (PermissionError, FileNotFoundError, OSError):
                    fejl_count += 1
                    continue
    
    except KeyboardInterrupt:
        print("\n\nScanning afbrudt af bruger")
    
    return usikre_filer, total_filer, fejl_count

def main():
    print("=" * 70)
    print("FIND FILER MED USIKRE RETTIGHEDER (WORLD-WRITABLE)")
    print("=" * 70)
    
    # Start med en sikker mappe
    start_mappe = input("Indtast mappe at scanne (standard: nuværende mappe): ").strip() or "."
    
    if not Path(start_mappe).exists():
        print(f"Fejl: Mappen '{start_mappe}' findes ikke")
        return
    
    print("\n⚠ ADVARSEL: Dette kan tage tid på store mapper")
    print("Tryk Ctrl+C for at afbryde\n")
    
    usikre_filer, total, fejl = find_usikre_filer(start_mappe)
    
    print("\n" + "=" * 70)
    print("RESULTAT")
    print("=" * 70)
    print(f"Total filer scannet: {total}")
    print(f"Fejl/Ingen adgang: {fejl}")
    print(f"Usikre filer fundet: {len(usikre_filer)}\n")
    
    if usikre_filer:
        print("⚠ USIKRE FILER (world-writable):")
        print("-" * 70)
        
        for fil in usikre_filer[:20]:
            print(f"Rettigheder: {fil['rettigheder']}")
            print(f"Størrelse: {fil['størrelse']:,} bytes")
            print(f"Sti: {fil['sti']}")
            print()
        
        if len(usikre_filer) > 20:
            print(f"... og {len(usikre_filer) - 20} flere filer")
        
        print("\n⚠ Disse filer kan være en sikkerhedsrisiko!")
        print("Overvej at ændre rettighederne med: chmod o-w <fil>")
    else:
        print("✓ Ingen world-writable filer fundet")
    
    print("=" * 70)

if __name__ == "__main__":
    main()