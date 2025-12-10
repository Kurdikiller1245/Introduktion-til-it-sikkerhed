#!/usr/bin/env python3
import socket
import sys
from datetime import datetime

def scan_port(ip, port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(1)
            result = sock.connect_ex((ip, port))
            return result == 0
    except Exception:
        return False

# Input & validation
remote_host = input("Enter a remote host to scan: ")

try:
    remote_ip = socket.gethostbyname(remote_host)
except socket.gaierror:
    print("Could not resolve hostname.")
    sys.exit(1)

try:
    start_port = int(input("Enter start port: "))
    end_port = int(input("Enter end port: "))
    if not (1 <= start_port <= 65535 and 1 <= end_port <= 65535):
        raise ValueError
except ValueError:
    print("Ports must be numbers between 1 and 65535.")
    sys.exit(1)

print(f"\nScanning {remote_ip} from port {start_port} to {end_port}...\n")

start_time = datetime.now()

for port in range(start_port, end_port + 1):
    if scan_port(remote_ip, port):
        print(f"Port {port:<5} OPEN")

end_time = datetime.now()
print("\nScan completed in:", end_time - start_time)
