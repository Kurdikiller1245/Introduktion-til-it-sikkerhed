#!/usr/bin/env python3
"""
Opgave 8: Overvåg diskplads
"""

import shutil

def overvag_diskplads(sti="/"):
    """Tjek ledig diskplads og print advarsel hvis under 20%"""
    print("=" * 60)
    print(f"DISKPLADS OVERVÅGNING - {sti}")
    print("=" * 60)
    
    try:
        usage = shutil.disk_usage(sti)
        
        total_gb = usage.total / (1024**3)
        used_gb = usage.used / (1024**3)
        free_gb = usage.free / (1024**3)
        
        used_percent = (usage.used / usage.total) * 100
        free_percent = (usage.free / usage.total) * 100
        
        print(f"Total plads:  {total_gb:>10.2f} GB")
        print(f"Brugt plads:  {used_gb:>10.2f} GB ({used_percent:.1f}%)")
        print(f"Ledig plads:  {free_gb:>10.2f} GB ({free_percent:.1f}%)")
        print()
        
        # Vis grafisk bar
        bar_length = 50
        used_bar = int((used_percent / 100) * bar_length)
        free_bar = bar_length - used_bar
        
        print("Forbrug: [" + "█" * used_bar + "░" * free_bar + "]")
        print()
        
        # Advarsler
        if free_percent < 20:
            print("⚠ ⚠ ⚠  ADVARSEL! ⚠ ⚠ ⚠")
            print(f"Diskplads er UNDER 20% ledig ({free_percent:.1f}%)")
            print("Overvej at rydde op i unødvendige filer!")
        elif free_percent < 30:
            print("⚠  BEMÆRK: Diskpladsen begynder at blive lav")
            print(f"Kun {free_percent:.1f}% ledig plads tilbage")
        else:
            print("✓ Diskplads er OK")
        
    except Exception as e:
        print(f"Fejl ved læsning af diskplads: {e}")
    
    print("=" * 60)

if __name__ == "__main__":
    overvag_diskplads()