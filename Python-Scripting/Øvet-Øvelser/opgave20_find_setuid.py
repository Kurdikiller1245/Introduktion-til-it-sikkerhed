#!/usr/bin/env python3
"""
Opgave 20: Find setuid-filer (sikkerhedsrisiko)
"""

import os
import stat
from pathlib import Path

def er_setuid(fil_stat):
    """Tjek om en fil har setuid-bitten sat"""
    return bool(fil_stat.st_mode & stat.S_ISUID)

def er_setgid(fil_stat):
    """Tjek om en fil har setgid-bitten sat"""
    return bool(fil_stat.st_mode & stat.S_ISGID)

def find_setuid_filer(start_mappe="/", max_dybde=5):
    """Find alle filer med setuid eller setgid bits"""
    print(f"Scanner efter setuid/setgid filer i: {start_mappe}")
    print(f"Max dybde: {max_dybde} niveauer")
    print("Dette kan tage lang tid...\n")
    print("⚠ ADVARSEL: Kræver root rettigheder for fuld scanning\n")
    
    setuid_filer = []
    setgid_filer = []
    total_filer = 0
    fejl_count = 0
    
    mapper_at_springe_over = {'/proc', '/sys', '/dev', '/run', '/tmp'}
    
    try:
        for root, dirs, files in os.walk(start_mappe):
            # Spring over system-mapper
            dirs[:] = [d for d in dirs if os.path.join(root, d) not in mapper_at_springe_over]
            
            # Begræns dybden
            dybde = root.replace(start_mappe, '').count(os.sep)
            if dybde > max_dybde:
                dirs.clear()
                continue
            
            for fil in files:
                total_filer += 1
                
                # Vis progress
                if total_filer % 1000 == 0:
                    print(f"Scannet {total_filer} filer... (Fundet {len(setuid_filer)} setuid, {len(setgid_filer)} setgid)", end='\r')
                
                fil_sti = os.path.join(root, fil)
                
                try:
                    fil_stat = os.lstat(fil_sti)
                    
                    # Spring over hvis ikke en almindelig fil
                    if not stat.S_ISREG(fil_stat.st_mode):
                        continue
                    
                    rettigheder = stat.filemode(fil_stat.st_mode)
                    
                    if er_setuid(fil_stat):
                        setuid_filer.append({
                            'sti': fil_sti,
                            'rettigheder': rettigheder,
                            'ejer': fil_stat.st_uid,
                            'størrelse': fil_stat.st_size,
                            'type': 'setuid'
                        })
                    
                    if er_setgid(fil_stat):
                        setgid_filer.append({
                            'sti': fil_sti,
                            'rettigheder': rettigheder,
                            'ejer': fil_stat.st_uid,
                            'størrelse': fil_stat.st_size,
                            'type': 'setgid'
                        })
                
                except (PermissionError, FileNotFoundError, OSError):
                    fejl_count += 1
                    continue
    
    except KeyboardInterrupt:
        print("\n\nScanning afbrudt af bruger")
    
    return setuid_filer, setgid_filer, total_filer, fejl_count

def get_ejer_navn(uid):
    """Få brugernavn fra UID"""
    try:
        import pwd
        return pwd.getpwuid(uid).pw_name
    except:
        return str(uid)

def main():
    print("=" * 90)
    print("FIND SETUID/SETGID FILER (SIKKERHEDSRISIKO)")
    print("=" * 90)
    print("\n⚠ VIGTIGT: Dette script skal køres som root for fuld adgang")
    print("Kør med: sudo python3 opgave20_find_setuid.py\n")
    
    # Tjek om vi kører som root
    if os.geteuid() != 0:
        print("⚠ ADVARSEL: Ikke root - mange filer vil være utilgængelige\n")
    
    # Vælg start mappe
    print("Vælg scanning mode:")
    print("1. Quick scan (/usr/bin, /usr/sbin, /bin, /sbin)")
    print("2. Fuld system scan (/) - MEGET langsom")
    print("3. Custom mappe")
    
    valg = input("\nVælg (1/2/3): ").strip() or "1"
    
    if valg == "1":
        mapper = ['/usr/bin', '/usr/sbin', '/bin', '/sbin']
        alle_setuid = []
        alle_setgid = []
        total = 0
        fejl = 0
        
        for mappe in mapper:
            if os.path.exists(mappe):
                print(f"\nScanner {mappe}...")
                s, g, t, f = find_setuid_filer(mappe, max_dybde=2)
                alle_setuid.extend(s)
                alle_setgid.extend(g)
                total += t
                fejl += f
        
        setuid_filer = alle_setuid
        setgid_filer = alle_setgid
        total_filer = total
        fejl_count = fejl
        
    elif valg == "2":
        bekræft = input("Fuld scan kan tage MEGET lang tid. Fortsæt? (ja/nej): ")
        if bekræft.lower() not in ['ja', 'j']:
            print("Afbrudt")
            return
        setuid_filer, setgid_filer, total_filer, fejl_count = find_setuid_filer("/", max_dybde=10)
    
    else:
        mappe = input("Indtast mappe at scanne: ").strip()
        if not os.path.exists(mappe):
            print(f"Mappe '{mappe}' findes ikke")
            return
        setuid_filer, setgid_filer, total_filer, fejl_count = find_setuid_filer(mappe, max_dybde=5)
    
    # Vis resultater
    print("\n" + "=" * 90)
    print("RESULTAT")
    print("=" * 90)
    print(f"Total filer scannet: {total_filer}")
    print(f"Fejl/Ingen adgang: {fejl_count}")
    print(f"Setuid filer fundet: {len(setuid_filer)}")
    print(f"Setgid filer fundet: {len(setgid_filer)}\n")
    
    if setuid_filer:
        print("=" * 90)
        print("⚠ SETUID FILER (køres med ejerens rettigheder)")
        print("=" * 90)
        print(f"{'RETTIGHEDER':<15} {'EJER':<15} {'STØRRELSE':<12} {'STI':<50}")
        print("-" * 90)
        
        for fil in setuid_filer[:20]:
            ejer = get_ejer_navn(fil['ejer'])
            størrelse = f"{fil['størrelse']:,} bytes"
            print(f"{fil['rettigheder']:<15} {ejer:<15} {størrelse:<12} {fil['sti']:<50}")
        
        if len(setuid_filer) > 20:
            print(f"\n... og {len(setuid_filer) - 20} flere setuid filer")
        
        # Advarsler
        print("\n⚠ SIKKERHEDSNOTER:")
        print("- Setuid filer køres med ejerens rettigheder, ikke brugerens")
        print("- Root-ejede setuid filer er særligt risikable")
        print("- Verificer at disse filer er legitime system-filer")
        
        root_setuid = [f for f in setuid_filer if f['ejer'] == 0]
        if root_setuid:
            print(f"\n⚠ {len(root_setuid)} filer er ejet af root og har setuid!")
    
    if setgid_filer:
        print("\n" + "=" * 90)
        print("SETGID FILER (køres med gruppens rettigheder)")
        print("=" * 90)
        print(f"Fandt {len(setgid_filer)} setgid filer")
        
        for fil in setgid_filer[:10]:
            ejer = get_ejer_navn(fil['ejer'])
            print(f"{fil['rettigheder']} {ejer:<15} {fil['sti']}")
        
        if len(setgid_filer) > 10:
            print(f"... og {len(setgid_filer) - 10} flere")
    
    if not setuid_filer and not setgid_filer:
        print("✓ Ingen setuid/setgid filer fundet i det scannede område")
    
    print("\n" + "=" * 90)

if __name__ == "__main__":
    main()