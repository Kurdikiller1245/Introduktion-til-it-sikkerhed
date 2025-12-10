#!/usr/bin/env python3
"""
Opgave 9: Læs en logfil og find fejl
"""

from pathlib import Path

def laes_logfil(logfil_sti, sogeord="failed"):
    """Åbn en logfil og print alle linjer der indeholder et specifikt ord"""
    print("=" * 60)
    print(f"LÆS LOGFIL: {logfil_sti}")
    print("=" * 60)
    
    logfil = Path(logfil_sti)
    
    if not logfil.exists():
        print(f"Fejl: Logfilen '{logfil_sti}' findes ikke!")
        return
    
    try:
        with open(logfil, 'r', errors='ignore') as f:
            linjer = f.readlines()
            
        matching_linjer = [
            (i+1, linje.strip()) 
            for i, linje in enumerate(linjer) 
            if sogeord.lower() in linje.lower()
        ]
        
        print(f"Total antal linjer: {len(linjer)}")
        print(f"Søger efter: '{sogeord}'")
        print(f"Fandt: {len(matching_linjer)} matchende linjer\n")
        
        if matching_linjer:
            print("Matchende linjer:")
            print("-" * 60)
            for linje_nr, linje in matching_linjer[:20]:
                print(f"Linje {linje_nr}: {linje[:100]}")
                if len(linje) > 100:
                    print("         ...")
            
            if len(matching_linjer) > 20:
                print(f"\n... og {len(matching_linjer) - 20} flere linjer")
        else:
            print(f"Ingen linjer med '{sogeord}' fundet")
            
    except PermissionError:
        print("Adgang nægtet - kræver administrator/root rettigheder")
    except Exception as e:
        print(f"Fejl ved læsning af fil: {e}")
    
    print("=" * 60)

def main():
    # Prøv forskellige logfiler
    logfiler = [
        "/var/log/auth.log",
        "/var/log/syslog",
        "/var/log/system.log",
        "test.log"
    ]
    
    # Find første tilgængelige logfil
    for logfil in logfiler:
        if Path(logfil).exists():
            laes_logfil(logfil, "failed")
            break
    else:
        print("Ingen standard logfiler fundet")
        print("\nOpret en test logfil...")
        
        # Opret test logfil
        test_log = Path("test.log")
        test_log.write_text("""2024-12-10 10:00:01 INFO: System started
2024-12-10 10:00:15 ERROR: Failed to connect to database
2024-12-10 10:00:30 WARNING: Retry attempt 1
2024-12-10 10:00:45 ERROR: Failed to connect to database
2024-12-10 10:01:00 INFO: Connection established
2024-12-10 10:01:15 INFO: User login successful
2024-12-10 10:01:30 ERROR: Failed to load configuration
""")
        print("Test logfil oprettet\n")
        laes_logfil("test.log", "failed")

if __name__ == "__main__":
    main()