#!/usr/bin/env python3
"""
Opgave 17: Find og stop processer efter navn
"""

try:
    import psutil
except ImportError:
    print("psutil er ikke installeret!")
    print("Installer med: pip install psutil")
    exit(1)

import time

def find_processer_efter_navn(navn):
    """Find alle processer der matcher et navn"""
    matchende_processer = []
    
    for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'memory_info', 'create_time']):
        try:
            proc_navn = proc.info['name'].lower()
            if navn.lower() in proc_navn:
                matchende_processer.append({
                    'pid': proc.info['pid'],
                    'navn': proc.info['name'],
                    'cmdline': ' '.join(proc.info['cmdline'] or []),
                    'memory': proc.info['memory_info'].rss / (1024 * 1024),  # MB
                    'starttid': time.ctime(proc.info['create_time'])
                })
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    
    return matchende_processer

def stop_proces(pid, force=False):
    """Stop en proces ved PID"""
    try:
        proc = psutil.Process(pid)
        
        if force:
            proc.kill()
            print(f"✓ Proces {pid} blev KILLED (force)")
        else:
            proc.terminate()
            print(f"✓ Proces {pid} blev TERMINATED (graceful)")
        
        # Vent på at processen stopper
        proc.wait(timeout=3)
        return True
        
    except psutil.NoSuchProcess:
        print(f"✗ Proces {pid} findes ikke længere")
        return False
    except psutil.AccessDenied:
        print(f"✗ Ingen adgang til at stoppe proces {pid} (kræver administrator)")
        return False
    except psutil.TimeoutExpired:
        print(f"⚠ Proces {pid} reagerer ikke, prøv force=True")
        return False
    except Exception as e:
        print(f"✗ Fejl ved stop af proces {pid}: {e}")
        return False

def main():
    print("=" * 70)
    print("HÅNDTER PROCESSER")
    print("=" * 70)
    
    # Find processer
    navn = input("Indtast proces navn at søge efter (f.eks. 'python', 'chrome'): ").strip()
    
    if not navn:
        print("Intet navn indtastet")
        return
    
    print(f"\nSøger efter processer med navn: '{navn}'...\n")
    
    processer = find_processer_efter_navn(navn)
    
    if not processer:
        print(f"Ingen processer fundet med navn '{navn}'")
        return
    
    print(f"Fandt {len(processer)} matchende processer:\n")
    print(f"{'PID':<8} {'NAVN':<25} {'HUKOMMELSE':<12} {'STARTTID':<30}")
    print("-" * 80)
    
    for proc in processer:
        print(f"{proc['pid']:<8} {proc['navn']:<25} {proc['memory']:.1f} MB{'':<6} {proc['starttid']:<30}")
    
    print("\n" + "=" * 70)
    
    # Spørg om at stoppe processer
    svar = input("\nVil du stoppe nogle af disse processer? (ja/nej): ").strip().lower()
    
    if svar not in ['ja', 'j', 'yes', 'y']:
        print("Ingen processer stoppet")
        return
    
    print("\n⚠ ADVARSEL: At stoppe processer kan medføre datatab!")
    print("Vælg processer at stoppe:\n")
    print("1. Stop alle processer")
    print("2. Stop specifik proces (PID)")
    print("3. Annuller")
    
    valg = input("\nVælg (1/2/3): ").strip()
    
    if valg == "1":
        bekræft = input(f"Er du sikker på at du vil stoppe ALLE {len(processer)} processer? (skriv JA): ")
        if bekræft == "JA":
            force = input("Brug force? (ja/nej): ").lower() in ['ja', 'j']
            for proc in processer:
                stop_proces(proc['pid'], force)
        else:
            print("Afbrudt")
    
    elif valg == "2":
        try:
            pid = int(input("Indtast PID at stoppe: "))
            force = input("Brug force? (ja/nej): ").lower() in ['ja', 'j']
            stop_proces(pid, force)
        except ValueError:
            print("Ugyldig PID")
    
    else:
        print("Afbrudt")
    
    print("=" * 70)

if __name__ == "__main__":
    main()