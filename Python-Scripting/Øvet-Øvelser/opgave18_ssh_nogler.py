#!/usr/bin/env python3
"""
Opgave 18: Tjek SSH-nøgler for brugere
"""

import pwd
from pathlib import Path
import os

def find_ssh_nogler():
    """Find alle brugeres SSH authorized_keys filer"""
    print("Søger efter SSH nøgler for alle brugere...\n")
    
    resultater = []
    
    # Gennemgå alle brugere
    for bruger in pwd.getpwall():
        username = bruger.pw_name
        hjemmemappe = Path(bruger.pw_dir)
        ssh_mappe = hjemmemappe / ".ssh"
        authorized_keys = ssh_mappe / "authorized_keys"
        
        resultat = {
            'username': username,
            'uid': bruger.pw_uid,
            'hjemmemappe': str(hjemmemappe),
            'ssh_mappe_findes': ssh_mappe.exists(),
            'authorized_keys_findes': False,
            'antal_nogler': 0,
            'fil_rettigheder': None,
            'fejl': None
        }
        
        if authorized_keys.exists():
            resultat['authorized_keys_findes'] = True
            
            try:
                # Læs filen
                with open(authorized_keys, 'r') as f:
                    linjer = [l.strip() for l in f if l.strip() and not l.startswith('#')]
                    resultat['antal_nogler'] = len(linjer)
                
                # Tjek rettigheder
                stat_info = authorized_keys.stat()
                resultat['fil_rettigheder'] = oct(stat_info.st_mode)[-3:]
                
            except PermissionError:
                resultat['fejl'] = "Ingen adgang"
            except Exception as e:
                resultat['fejl'] = str(e)
        
        resultater.append(resultat)
    
    return resultater

def tjek_sikkerhed(rettigheder):
    """Tjek om SSH nøgle rettigheder er sikre"""
    if rettigheder is None:
        return "N/A"
    
    # authorized_keys skal være 600 eller 400
    if rettigheder in ['600', '400']:
        return "✓ Sikker"
    else:
        return "⚠ USIKKER"

def main():
    print("=" * 80)
    print("TJEK SSH-NØGLER FOR BRUGERE")
    print("=" * 80)
    print("\n⚠ Dette script kræver måske administrator/root rettigheder")
    print("Kør med: sudo python3 opgave18_ssh_nogler.py\n")
    
    # Tjek om vi kører som root
    if os.geteuid() != 0:
        print("⚠ ADVARSEL: Ikke root - nogle filer kan være utilgængelige\n")
    
    try:
        resultater = find_ssh_nogler()
        
        # Filtrer for brugere med SSH nøgler
        med_nogler = [r for r in resultater if r['authorized_keys_findes']]
        med_ssh_mappe = [r for r in resultater if r['ssh_mappe_findes']]
        
        print("=" * 80)
        print("RESULTAT - OVERSIGT")
        print("=" * 80)
        print(f"Total antal brugere: {len(resultater)}")
        print(f"Brugere med .ssh mappe: {len(med_ssh_mappe)}")
        print(f"Brugere med authorized_keys: {len(med_nogler)}\n")
        
        if med_nogler:
            print("=" * 80)
            print("BRUGERE MED SSH-NØGLER")
            print("=" * 80)
            print(f"{'BRUGER':<15} {'UID':<8} {'NØGLER':<10} {'RETTIGHEDER':<12} {'STATUS':<15}")
            print("-" * 80)
            
            for r in med_nogler:
                if r['fejl']:
                    status = f"Fejl: {r['fejl']}"
                    rettigheder = "N/A"
                else:
                    status = tjek_sikkerhed(r['fil_rettigheder'])
                    rettigheder = r['fil_rettigheder'] or "N/A"
                
                print(f"{r['username']:<15} {r['uid']:<8} {r['antal_nogler']:<10} "
                      f"{rettigheder:<12} {status:<15}")
            
            # Advarsler om usikre rettigheder
            usikre = [r for r in med_nogler if r['fil_rettigheder'] not in ['600', '400', None]]
            if usikre:
                print("\n" + "=" * 80)
                print("⚠ SIKKERHEDSADVARSLER")
                print("=" * 80)
                for r in usikre:
                    print(f"Bruger '{r['username']}' har usikre rettigheder: {r['fil_rettigheder']}")
                    print(f"  Ret med: sudo chmod 600 {r['hjemmemappe']}/.ssh/authorized_keys")
        else:
            print("Ingen brugere med authorized_keys fundet")
        
        # Vis brugere med .ssh mappe men ingen nøgler
        ssh_uden_nogler = [r for r in med_ssh_mappe if not r['authorized_keys_findes']]
        if ssh_uden_nogler:
            print("\n" + "=" * 80)
            print("BRUGERE MED .SSH MAPPE MEN INGEN AUTHORIZED_KEYS")
            print("=" * 80)
            for r in ssh_uden_nogler[:10]:
                print(f"  {r['username']} (UID: {r['uid']})")
            if len(ssh_uden_nogler) > 10:
                print(f"  ... og {len(ssh_uden_nogler) - 10} flere")
        
    except PermissionError:
        print("✗ Adgang nægtet - kræver root rettigheder")
    except Exception as e:
        print(f"✗ Fejl: {e}")
    
    print("\n" + "=" * 80)

if __name__ == "__main__":
    main()