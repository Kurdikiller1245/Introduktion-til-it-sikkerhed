#!/usr/bin/env python3
"""
Opgave 15: Scan netværk for åbne porte
"""

import socket
from concurrent.futures import ThreadPoolExecutor, as_completed

def scan_port(ip, port, timeout=1):
    """Scan en enkelt port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((ip, port))
        sock.close()
        return port, result == 0
    except:
        return port, False

def scan_porte(ip, porte, max_workers=50):
    """Scan en liste af porte på en IP-adresse"""
    print(f"Scanner {ip} for åbne porte...")
    print(f"Antal porte at scanne: {len(porte)}\n")
    
    åbne_porte = []
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(scan_port, ip, port): port for port in porte}
        
        completed = 0
        for future in as_completed(futures):
            port, er_åben = future.result()
            completed += 1
            
            # Vis progress
            if completed % 10 == 0 or er_åben:
                print(f"Progress: {completed}/{len(porte)} - ", end='')
                if er_åben:
                    print(f"✓ Port {port} er ÅBEN")
                    åbne_porte.append(port)
                else:
                    print(f"Scanning...", end='\r')
    
    return sorted(åbne_porte)

def get_service_name(port):
    """Få service navn for en port"""
    services = {
        20: "FTP Data",
        21: "FTP",
        22: "SSH",
        23: "Telnet",
        25: "SMTP",
        53: "DNS",
        80: "HTTP",
        110: "POP3",
        143: "IMAP",
        443: "HTTPS",
        3306: "MySQL",
        3389: "RDP",
        5432: "PostgreSQL",
        8080: "HTTP-alt",
        8443: "HTTPS-alt"
    }
    return services.get(port, "Unknown")

def main():
    print("=" * 70)
    print("NETVÆRK PORT SCANNER")
    print("=" * 70)
    
    # Input
    ip = input("Indtast IP-adresse (standard: localhost): ").strip() or "127.0.0.1"
    
    print("\nVælg scan type:")
    print("1. Almindelige porte (20 porte)")
    print("2. Alle porte (1-1024)")
    print("3. Custom port range")
    
    valg = input("\nVælg (1/2/3): ").strip() or "1"
    
    if valg == "1":
        # Almindelige porte
        porte = [20, 21, 22, 23, 25, 53, 80, 110, 143, 443, 
                 3306, 3389, 5432, 8080, 8443, 8888, 9000, 9090, 27017, 6379]
    elif valg == "2":
        porte = list(range(1, 1025))
    else:
        try:
            start = int(input("Start port: "))
            slut = int(input("Slut port: "))
            porte = list(range(start, slut + 1))
        except:
            print("Ugyldig input, bruger almindelige porte")
            porte = [21, 22, 80, 443, 3306, 8080]
    
    print("\n" + "=" * 70)
    åbne_porte = scan_porte(ip, porte)
    
    print("\n" + "=" * 70)
    print("RESULTAT")
    print("=" * 70)
    print(f"Scannet {len(porte)} porte på {ip}")
    print(f"Fandt {len(åbne_porte)} åbne porte\n")
    
    if åbne_porte:
        print("ÅBNE PORTE:")
        print(f"{'Port':<10} {'Service':<20}")
        print("-" * 30)
        for port in åbne_porte:
            service = get_service_name(port)
            print(f"{port:<10} {service:<20}")
    else:
        print("Ingen åbne porte fundet")
    
    print("=" * 70)

if __name__ == "__main__":
    main()