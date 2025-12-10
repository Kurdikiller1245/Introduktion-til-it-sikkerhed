#!/usr/bin/env python3
"""
Opgave 7: Tjek om en port er åben
"""

import socket

def tjek_port(host, port, timeout=2):
    """Forsøg at oprette forbindelse til en host på en specifik port"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    
    try:
        result = sock.connect_ex((host, port))
        if result == 0:
            print(f"✓ {host}:{port} er ÅBEN")
            return True
        else:
            print(f"✗ {host}:{port} er LUKKET")
            return False
    except socket.gaierror:
        print(f"✗ {host}:{port} - Kunne ikke resolve hostname")
        return False
    except socket.timeout:
        print(f"✗ {host}:{port} - Timeout")
        return False
    finally:
        sock.close()

def main():
    print("=" * 60)
    print("TJEK ÅBNE PORTE")
    print("=" * 60)
    
    # Test almindelige hosts og porte
    test_forbindelser = [
        ("google.com", 443),  # HTTPS
        ("google.com", 80),   # HTTP
        ("google.com", 22),   # SSH
        ("localhost", 22),    # SSH lokalt
        ("localhost", 80),    # HTTP lokalt
    ]
    
    print("Tester almindelige forbindelser:\n")
    for host, port in test_forbindelser:
        tjek_port(host, port)
    
    # Lad brugeren teste en custom forbindelse
    print("\n" + "=" * 60)
    print("Test en custom forbindelse:")
    try:
        host = input("Indtast hostname (f.eks. google.com): ").strip()
        port = int(input("Indtast port (f.eks. 443): ").strip())
        print()
        tjek_port(host, port)
    except ValueError:
        print("Ugyldig port-nummer")
    except KeyboardInterrupt:
        print("\nAfbrudt")
    
    print("=" * 60)

if __name__ == "__main__":
    main()