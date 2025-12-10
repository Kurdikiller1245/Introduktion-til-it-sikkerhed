#!/usr/bin/env python3
"""
Opgave 3: Find alle .conf filer i /etc
"""

from pathlib import Path

def find_conf_filer(mappe="/etc"):
    """Gennemgå alle filer og find dem der ender med .conf"""
    print("=" * 60)
    print(f"FIND .CONF FILER I {mappe}")
    print("=" * 60)
    
    sti = Path(mappe)
    
    if not sti.exists():
        print(f"Advarsel: Mappen {mappe} findes ikke")
        print("Prøver nuværende mappe i stedet...")
        sti = Path(".")
    
    try:
        conf_filer = [f for f in sti.rglob("*.conf") if f.is_file()]
        
        if conf_filer:
            print(f"Fandt {len(conf_filer)} .conf filer:\n")
            for fil in sorted(conf_filer):
                print(f"  {fil}")
        else:
            print("Ingen .conf filer fundet")
    except PermissionError as e:
        print(f"Adgang nægtet: {e}")
        print("Kræver måske administrator/root rettigheder")
    
    print("=" * 60)

if __name__ == "__main__":
    find_conf_filer()