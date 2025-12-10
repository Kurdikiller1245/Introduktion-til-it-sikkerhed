# 🐍 Python System Administration Scripts

En samling af 20 praktiske Python scripts til systemadministration og sikkerhed. Perfekt til at lære grundlæggende og avancerede systemadministrationsopgaver med Python.

## 📋 Indholdsfortegnelse

- [Oversigt](#oversigt)
- [Installation](#installation)
- [Script Oversigt](#script-oversigt)
  - [Begynder-øvelser Scripts (1-10)](#begynder-øvelser-scripts-1-10)
  - [Øvet-øvelser Scripts (11-20)](#øvet-øvelser-scripts-11-20)
- [Brug](#brug)
- [Krav](#krav)
- [Sikkerhed](#sikkerhed)


## 🎯 Oversigt

Denne repository indeholder 20 Python scripts der dækker vigtige systemadministrationsopgaver:

- Systemovervågning og information
- Filhåndtering og integritet
- Netværksscanning og overvågning
- Processhåndtering
- Sikkerhedsauditing
- Adgangskodegenerering

## 💾 Installation

### 1. Klon repository

```bash
git clone https://github.com/Kurdikiller1245/Introduktion-til-it-sikkerhed.git 
cd python-scripting
```

### 2. Installer afhængigheder

```bash
pip install -r requirements.txt
```

**requirements.txt:**
```
psutil>=5.9.0
```

### 3. Gør scripts eksekverbare (Linux/Mac)

```bash
chmod +x opgave*.py
```

## 📚 Script Oversigt

### Begynder-øvelser Scripts (1-10)

#### 1. Vis Dato og Klokkeslæt
**Fil:** `opgave1_dato_tid.py`

Viser nuværende dato, tid, ugedag og anden tidsinformation.

```bash
python opgave1_dato_tid.py
```

#### 2. Systeminformation
**Fil:** `opgave2_systeminformation.py`

Henter computerens hostname og lokale IP-adresse.

```bash
python opgave2_systeminformation.py
```

#### 3. Find .conf Filer
**Fil:** `opgave3_find_conf_filer.py`

Søger rekursivt efter alle `.conf` konfigurationsfiler i `/etc` eller en valgt mappe.

```bash
python opgave3_find_conf_filer.py
```

#### 4. Tjek Fil Eksistens
**Fil:** `opgave4_tjek_fil.py`

Verificerer om filer og mapper eksisterer og viser information om dem.

```bash
python opgave4_tjek_fil.py
```

#### 5. Omdøb Filer
**Fil:** `opgave5_omdob_filer.py`

Omdøber alle `.txt` filer til `.md` filer i en given mappe.

```bash
python opgave5_omdob_filer.py
```

#### 6. Kørende Processer
**Fil:** `opgave6_processer.py`

Viser alle kørende processer med PID, navn, bruger og hukommelsesforbrug.

```bash
python opgave6_processer.py
```

**Kræver:** `psutil`

#### 7. Tjek Åbne Porte
**Fil:** `opgave7_tjek_port.py`

Tester om specifikke porte er åbne på en given host.

```bash
python opgave7_tjek_port.py
```

#### 8. Overvåg Diskplads
**Fil:** `opgave8_diskplads.py`

Tjekker ledig diskplads og advarer hvis under 20%.

```bash
python opgave8_diskplads.py
```

#### 9. Læs Logfil
**Fil:** `opgave9_laes_logfil.py`

Søger gennem logfiler efter specifikke nøgleord (f.eks. "failed").

```bash
python opgave9_laes_logfil.py
```

#### 10. Simpel Lommeregner
**Fil:** `opgave10_lommeregner.py`

Interaktiv lommeregner med grundlæggende operationer (+, -, *, /).

```bash
python opgave10_lommeregner.py
```

---

### Øvet-øvelser Scripts (11-20)

#### 11. Overvåg Filændringer
**Fil:** `opgave11_fil_hash.py`

Gemmer SHA256 hash af filer og detekterer ændringer over tid.

```bash
python opgave11_fil_hash.py
```

**Use case:** Integritetskontrol af kritiske systemfiler

#### 12. Generer Adgangskode
**Fil:** `opgave12_generer_password.py`

Genererer sikre adgangskoder med valgbare krav (store/små bogstaver, tal, symboler).

```bash
python opgave12_generer_password.py
```

**Features:**
- Konfigurerbar længde
- Valgbare tegntyper
- Styrkevalidering

#### 13. Verificer Fil-integritet
**Fil:** `opgave13_verificer_integritet.py`

Beregner og verificerer SHA256 hashes af filer.

```bash
python opgave13_verificer_integritet.py
```

**Use case:** Verificer downloadede filer mod kendte hashes

#### 14. Find Usikre Filrettigheder
**Fil:** `opgave14_usikre_rettigheder.py`

Scanner efter world-writable filer (sikkerhedsrisiko).

```bash
python opgave14_usikre_rettigheder.py
```

⚠️ **Kræver:** Root/administrator rettigheder for fuld scanning

#### 15. Scan Netværk for Åbne Porte
**Fil:** `opgave15_port_scanner.py`

Avanceret port scanner med multi-threading support.

```bash
python opgave15_port_scanner.py
```

**Features:**
- Quick scan (almindelige porte)
- Full scan (1-1024)
- Custom port ranges
- Service detection

#### 16. Udtræk IP-adresser fra Log
**Fil:** `opgave16_udtrak_ip.py`

Finder og tæller unikke IPv4 adresser i logfiler ved hjælp af regex.

```bash
python opgave16_udtrak_ip.py
```

**Output:** Top IP-adresser sorteret efter antal requests

#### 17. Håndter Processer
**Fil:** `opgave17_haandter_processer.py`

Find og stop processer efter navn.

```bash
sudo python opgave17_haandter_processer.py
```

⚠️ **Kræver:** Root/administrator rettigheder

**Features:**
- Søg efter proces navn
- Graceful termination
- Force kill option

#### 18. Tjek SSH-nøgler
**Fil:** `opgave18_ssh_nogler.py`

Scanner alle brugeres hjemmemapper for SSH authorized_keys filer.

```bash
sudo python opgave18_ssh_nogler.py
```

⚠️ **Kræver:** Root rettigheder

**Tjekker:**
- SSH nøgle eksistens
- Fil rettigheder (skal være 600)
- Antal nøgler per bruger

#### 19. Overvåg Netværksforbindelser
**Fil:** `opgave19_overvag_netvaerk.py`

Realtidsovervågning af nye netværksforbindelser.

```bash
sudo python opgave19_overvag_netvaerk.py
```

⚠️ **Kræver:** Root/administrator rettigheder og `psutil`

**Features:**
- Vis aktive forbindelser
- Realtidsovervågning af nye forbindelser
- Proces identifikation

#### 20. Find Setuid-filer
**Fil:** `opgave20_find_setuid.py`

Scanner efter filer med setuid/setgid bits (potentiel sikkerhedsrisiko).

```bash
sudo python opgave20_find_setuid.py
```

⚠️ **Kræver:** Root rettigheder

**Scan modes:**
- Quick scan (system binaries)
- Full system scan
- Custom directory

---

## 🚀 Brug

### Grundlæggende Brug

Kør ethvert script direkte:

```bash
python opgaveX_navn.py
```

### Scripts der Kræver Root

Nogle scripts kræver administrator/root rettigheder:

```bash
sudo python opgaveX_navn.py
```

### Interaktive Scripts

De fleste scripts er interaktive og vil guide dig gennem processen:

```bash
$ python opgave7_tjek_port.py
Indtast hostname (f.eks. google.com): google.com
Indtast port (f.eks. 443): 443
✓ google.com:443 er ÅBEN
```

## 📦 Krav

### Python Version
- Python 3.8 eller nyere

### Påkrævede Biblioteker

```bash
pip install psutil
```

### System Krav

- **Linux:** Fuld funktionalitet
- **macOS:** De fleste scripts virker
- **Windows:** Grundlæggende scripts virker, nogle kræver WSL

### Scripts der Kræver Root/Administrator

- `opgave14_usikre_rettigheder.py`
- `opgave17_haandter_processer.py`
- `opgave18_ssh_nogler.py`
- `opgave19_overvag_netvaerk.py`
- `opgave20_find_setuid.py`

## 🔒 Sikkerhed

### Vigtige Sikkerhedsnoter

⚠️ **Advarsel:** Nogle af disse scripts kan påvirke systemstabilitet eller sikkerhed.

- **Kør aldrig scripts fra ukendte kilder som root**
- **Test scripts i et sikkert miljø først**
- **Backup vigtige data før brug af scripts der ændrer filer**
- **Vær forsigtig med scripts der stopper processer**

### Sikkerhedsfokuserede Scripts

Scripts der hjælper med sikkerhedsauditing:

- `opgave11_fil_hash.py` - Integritetskontrol
- `opgave13_verificer_integritet.py` - Fil verifikation
- `opgave14_usikre_rettigheder.py` - Find sikkerhedshuller
- `opgave18_ssh_nogler.py` - SSH audit
- `opgave20_find_setuid.py` - Find potentielle exploits

## 📖 Læringsmål

Denne samling dækker:

### Python Moduler
- `datetime` - Tidshåndtering
- `socket` - Netværksprogrammering
- `pathlib` / `os` - Filsystemoperationer
- `hashlib` - Kryptografiske hashes
- `re` - Regular expressions
- `psutil` - System og procesinfo
- `pwd` - Unix brugerinfo
- `stat` - Fil metadata

### Koncepter
- Filhåndtering og I/O
- Processhåndtering
- Netværksscanning
- Sikkerhedsauditing
- Hash beregning og verifikation
- Regular expressions
- Multi-threading
- Fil permissions og rettigheder



