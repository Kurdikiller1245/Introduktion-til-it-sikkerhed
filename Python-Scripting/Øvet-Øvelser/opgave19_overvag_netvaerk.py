#!/usr/bin/env python3
"""
Opgave 19: Overvåg netværksforbindelser i realtid
"""

try:
    import psutil
except ImportError:
    print("psutil er ikke installeret!")
    print("Installer med: pip install psutil")
    exit(1)

import time
from datetime import datetime

def get_forbindelser():
    """Hent alle aktive netværksforbindelser"""
    forbindelser = []
    
    try:
        for conn in psutil.net_connections(kind='inet'):
            if conn.status == 'ESTABLISHED':
                forbindelse = {
                    'laddr': f"{conn.laddr.ip}:{conn.laddr.port}" if conn.laddr else "N/A",
                    'raddr': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else "N/A",
                    'status': conn.status,
                    'pid': conn.pid
                }
                
                # Få proces navn hvis muligt
                try:
                    if conn.pid:
                        proc = psutil.Process(conn.pid)
                        forbindelse['proces'] = proc.name()
                    else:
                        forbindelse['proces'] = "N/A"
                except:
                    forbindelse['proces'] = "N/A"
                
                forbindelser.append(forbindelse)
    except psutil.AccessDenied:
        print("⚠ Adgang nægtet - kør som administrator for fuld adgang")
    
    return forbindelser

def overvag_forbindelser(interval=2, varighed=60):
    """Overvåg netværksforbindelser og vis nye forbindelser"""
    print("=" * 90)
    print("OVERVÅG NETVÆRKSFORBINDELSER")
    print("=" * 90)
    print(f"Opdateringsinterval: {interval} sekunder")
    print(f"Varighed: {varighed} sekunder (Tryk Ctrl+C for at stoppe)")
    print("=" * 90)
    
    tidligere_forbindelser = set()
    start_tid = time.time()
    nye_forbindelser_total = 0
    
    try:
        while True:
            # Tjek om vi skal stoppe
            if time.time() - start_tid > varighed:
                print("\nOvervågning afsluttet (varighed nået)")
                break
            
            # Hent nuværende forbindelser
            aktuelle = get_forbindelser()
            aktuelle_set = {(f['laddr'], f['raddr'], f['pid']) for f in aktuelle}
            
            # Find nye forbindelser
            nye = aktuelle_set - tidligere_forbindelser
            
            if nye:
                for conn in aktuelle:
                    conn_tuple = (conn['laddr'], conn['raddr'], conn['pid'])
                    if conn_tuple in nye:
                        nye_forbindelser_total += 1
                        tid = datetime.now().strftime("%H:%M:%S")
                        print(f"\n[{tid}] NY FORBINDELSE:")
                        print(f"  Lokal:   {conn['laddr']}")
                        print(f"  Remote:  {conn['raddr']}")
                        print(f"  Proces:  {conn['proces']} (PID: {conn['pid']})")
                        print(f"  Status:  {conn['status']}")
            
            # Opdater tidligere forbindelser
            tidligere_forbindelser = aktuelle_set
            
            # Vis status hver 10. sekund
            elapsed = int(time.time() - start_tid)
            if elapsed % 10 == 0 and elapsed > 0:
                print(f"\n[Status] Kørt i {elapsed}s - Aktive: {len(aktuelle)} - Nye total: {nye_forbindelser_total}")
            
            time.sleep(interval)
    
    except KeyboardInterrupt:
        print("\n\nOvervågning stoppet af bruger")
    
    print("\n" + "=" * 90)
    print("OVERSIGT")
    print("=" * 90)
    print(f"Total tid: {int(time.time() - start_tid)} sekunder")
    print(f"Nye forbindelser opdaget: {nye_forbindelser_total}")
    print("=" * 90)

def vis_aktive_forbindelser():
    """Vis alle aktive forbindelser lige nu"""
    print("\n" + "=" * 90)
    print("AKTIVE FORBINDELSER LIGE NU")
    print("=" * 90)
    
    forbindelser = get_forbindelser()
    
    if not forbindelser:
        print("Ingen etablerede forbindelser fundet")
        return
    
    print(f"{'LOKAL ADRESSE':<25} {'REMOTE ADRESSE':<25} {'PROCES':<20} {'PID':<8}")
    print("-" * 90)
    
    for conn in forbindelser[:30]:
        print(f"{conn['laddr']:<25} {conn['raddr']:<25} {conn['proces']:<20} {conn['pid']:<8}")
    
    if len(forbindelser) > 30:
        print(f"\n... og {len(forbindelser) - 30} flere forbindelser")
    
    print(f"\nTotal: {len(forbindelser)} etablerede forbindelser")

def main():
    print("⚠ BEMÆRK: Dette script kræver ofte administrator/root rettigheder")
    print("Kør med: sudo python3 opgave19_overvag_netvaerk.py\n")
    
    print("Vælg mode:")
    print("1. Vis aktive forbindelser (øjebliksbillede)")
    print("2. Overvåg nye forbindelser (realtid)")
    
    valg = input("\nVælg (1/2): ").strip() or "1"
    
    if valg == "1":
        vis_aktive_forbindelser()
    else:
        try:
            interval = int(input("Opdateringsinterval i sekunder (standard 2): ") or "2")
            varighed = int(input("Varighed i sekunder (standard 60): ") or "60")
            overvag_forbindelser(interval, varighed)
        except ValueError:
            print("Ugyldig input, bruger standardværdier")
            overvag_forbindelser()

if __name__ == "__main__":
    main()