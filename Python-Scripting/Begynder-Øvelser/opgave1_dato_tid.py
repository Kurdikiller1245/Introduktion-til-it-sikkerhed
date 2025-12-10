#!/usr/bin/env python3
"""
Opgave 1: Vis dato og klokkeslæt
"""

import datetime

def vis_dato_tid():
    """Vis den nuværende dato og tid i et pænt format"""
    nu = datetime.datetime.now()
    
    print("=" * 60)
    print("DATO OG KLOKKESLÆT")
    print("=" * 60)
    print(f"Nuværende dato og tid: {nu.strftime('%d-%m-%Y %H:%M:%S')}")
    print(f"Ugedag: {nu.strftime('%A')}")
    print(f"Måned: {nu.strftime('%B')}")
    print(f"År: {nu.year}")
    print(f"Uge nummer: {nu.strftime('%W')}")
    print("=" * 60)

if __name__ == "__main__":
    vis_dato_tid()
