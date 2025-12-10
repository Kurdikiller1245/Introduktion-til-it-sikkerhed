#!/usr/bin/env python3
"""
Opgave 6: Se kørende processer
"""

try:
    import psutil
except ImportError:
    print("psutil er ikke installeret!")
    print("Installer med: pip install psutil")
    exit(1)

def vis_korende_processer():
    """List alle kørende processer og deres PID"""
    print("=" * 60)
    print("KØRENDE PROCESSER")
    print("=" * 60)
    
    processer = []
    
    for proc in psutil.process_iter(['pid', 'name', 'username', 'memory_percent']):
        try:
            info = proc.info
            processer.append({
                'pid': info['pid'],
                'name': info['name'],
                'user': info.get('username', 'N/A'),
                'memory': info.get('memory_percent', 0)
            })
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    
    # Sorter efter hukommelsesforbrug
    processer.sort(key=lambda x: x['memory'], reverse=True)
    
    print(f"Total antal processer: {len(processer)}\n")
    print(f"{'PID':<8} {'NAVN':<30} {'BRUGER':<15} {'HUKOMMELSE':<10}")
    print("-" * 63)
    
    # Vis top 20 processer
    for proc in processer[:20]:
        print(f"{proc['pid']:<8} {proc['name']:<30} {proc['user']:<15} {proc['memory']:.2f}%")
    
    if len(processer) > 20:
        print(f"\n... og {len(processer) - 20} flere processer")
    
    print("=" * 60)

if __name__ == "__main__":
    vis_korende_processer()