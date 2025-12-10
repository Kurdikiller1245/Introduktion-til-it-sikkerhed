#!/usr/bin/env python3
"""
Opgave 10: Simpel lommeregner
"""

def lommeregner():
    """Simpel lommeregner der tager to tal og en operator som input"""
    print("=" * 60)
    print("SIMPEL LOMMEREGNER")
    print("=" * 60)
    
    try:
        tal1 = float(input("Indtast første tal: "))
        operator = input("Indtast operator (+, -, *, /): ").strip()
        tal2 = float(input("Indtast andet tal: "))
        
        if operator == '+':
            resultat = tal1 + tal2
            operation = "Addition"
        elif operator == '-':
            resultat = tal1 - tal2
            operation = "Subtraktion"
        elif operator == '*':
            resultat = tal1 * tal2
            operation = "Multiplikation"
        elif operator == '/':
            if tal2 == 0:
                print("\n❌ Fejl: Division med nul er ikke tilladt!")
                return
            resultat = tal1 / tal2
            operation = "Division"
        else:
            print(f"\n❌ Ukendt operator: '{operator}'")
            print("Gyldige operatorer: +, -, *, /")
            return
        
        print("\n" + "=" * 60)
        print(f"Operation: {operation}")
        print(f"Beregning: {tal1} {operator} {tal2} = {resultat}")
        print("=" * 60)
        
    except ValueError:
        print("\n❌ Fejl: Indtast venligst gyldige tal!")
    except KeyboardInterrupt:
        print("\n\nLommeregner afbrudt")

def main():
    while True:
        lommeregner()
        
        svar = input("\nVil du lave en ny beregning? (ja/nej): ").strip().lower()
        if svar not in ['ja', 'j', 'yes', 'y']:
            print("\nFarvel! 👋")
            break
        print("\n")

if __name__ == "__main__":
    main()