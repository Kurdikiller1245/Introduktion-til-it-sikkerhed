#!/usr/bin/env python3
"""
Opgave 2: Find systeminformation
"""

import socket

def find_systeminformation():
    """Hent og vis computerens hostname og lokale IP-adresse"""
    print("=" * 60)
    print("SYSTEMINFORMATION")
    print("=" * 60)
    
    hostname = socket.gethostname()
    print(f"Hostname: {hostname}")
    
    try:
        ip = socket.gethostbyname(hostname)
        print(f"Lokal IP-adresse: {ip}")
    except socket.gaierror:
        print("Kunne ikke finde IP-adresse")
    
    try:
        # Alternativ metode til at finde IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        print(f"Netværks IP-adresse: {local_ip}")
    except:
        pass
    
    print("=" * 60)

if __name__ == "__main__":
    find_systeminformation()