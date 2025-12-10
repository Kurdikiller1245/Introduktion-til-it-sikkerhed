#!/usr/bin/env python3
"""
Opgave 16: Udtræk IP-adresser fra webserver log
"""

import re
from collections import Counter
from pathlib import Path

def find_ip_adresser(tekst):
    """Find alle IPv4 adresser i tekst med regex"""
    # IPv4 regex pattern
    ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
    return re.findall(ip_pattern, tekst)

def er_valid_ip(ip):
    """Verificer at IP-adressen er valid"""
    dele = ip.split('.')
    if len(dele) != 4:
        return False
    try:
        return all(0 <= int(del_) <= 255 for del_ in dele)
    except ValueError:
        return False

def analyser_log_fil(fil_sti):
    """Analyser log fil og udtræk IP-adresser"""
    print(f"Læser log fil: {fil_sti}\n")
    
    try:
        with open(fil_sti, 'r', errors='ignore') as f:
            indhold = f.read()
        
        # Find alle IP-adresser
        alle_ips = find_ip_adresser(indhold)
        
        # Filtrer for valid IPs
        valid_ips = [ip for ip in alle_ips if er_valid_ip(ip)]
        
        # Tæl forekomster
        ip_tæller = Counter(valid_ips)
        
        return ip_tæller
        
    except FileNotFoundError:
        print(f"Fejl: Filen '{fil_sti}' findes ikke")
        return None
    except Exception as e:
        print(f"Fejl ved læsning af fil: {e}")
        return None

def main():
    print("=" * 70)
    print("UDTRÆK IP-ADRESSER FRA LOG FIL")
    print("=" * 70)
    
    # Opret eksempel log fil hvis den ikke findes
    test_log = Path("webserver.log")
    if not test_log.exists():
        print("Opretter eksempel log fil...\n")
        eksempel_log = """192.168.1.1 - - [10/Dec/2024:10:00:01] "GET /index.html HTTP/1.1" 200
192.168.1.100 - - [10/Dec/2024:10:00:05] "GET /about.html HTTP/1.1" 200
10.0.0.5 - - [10/Dec/2024:10:00:10] "POST /login HTTP/1.1" 401
192.168.1.1 - - [10/Dec/2024:10:00:15] "GET /dashboard HTTP/1.1" 200
203.0.113.45 - - [10/Dec/2024:10:00:20] "GET /api/data HTTP/1.1" 200
192.168.1.100 - - [10/Dec/2024:10:00:25] "GET /contact HTTP/1.1" 200
10.0.0.5 - - [10/Dec/2024:10:00:30] "POST /login HTTP/1.1" 200
192.168.1.1 - - [10/Dec/2024:10:00:35] "GET /profile HTTP/1.1" 200
203.0.113.45 - - [10/Dec/2024:10:00:40] "GET /api/users HTTP/1.1" 403
8.8.8.8 - - [10/Dec/2024:10:00:45] "GET / HTTP/1.1" 200
"""
        test_log.write_text(eksempel_log)
    
    # Analyser log fil
    fil_sti = input(f"Indtast log fil sti (standard: {test_log}): ").strip() or str(test_log)
    
    print()
    ip_tæller = analyser_log_fil(fil_sti)
    
    if ip_tæller is None:
        return
    
    print("=" * 70)
    print("RESULTAT")
    print("=" * 70)
    print(f"Total unikke IP-adresser: {len(ip_tæller)}")
    print(f"Total antal requests: {sum(ip_tæller.values())}\n")
    
    print(f"{'IP-ADRESSE':<20} {'ANTAL REQUESTS':<15} {'PROCENT':<10}")
    print("-" * 50)
    
    total = sum(ip_tæller.values())
    for ip, antal in ip_tæller.most_common():
        procent = (antal / total) * 100
        print(f"{ip:<20} {antal:<15} {procent:.1f}%")
    
    print("\n" + "=" * 70)
    print("TOP 5 MEST AKTIVE IP-ADRESSER:")
    print("=" * 70)
    
    for i, (ip, antal) in enumerate(ip_tæller.most_common(5), 1):
        print(f"{i}. {ip} - {antal} requests")
    
    print("=" * 70)

if __name__ == "__main__":
    main()