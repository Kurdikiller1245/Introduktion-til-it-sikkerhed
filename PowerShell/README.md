# 🔋🐚 PowerShell Portfolio Scripts

En samling af praktiske PowerShell scripts til systemadministration og automatisering. Dette portfolio indeholder to professionelle scripts, der demonstrerer PowerShell scripting evner til sikkerhed og systemadministration.

## 📋 Indholdsfortegnelse

- [Oversigt](#-oversigt)
- [Installation](#-installation)
- [Script Oversigt](#script-oversigt)
  - [1. PowerShell Password Generator](#1-powershell-password-generator)
  - [2. PowerShell Nmap Port Scanner](#2-powershell-nmap-port-scanner)
- [Brug](#-brug)
- [Krav](#-krav)
- [Sikkerhed](#-sikkerhed)

## 🎯 Oversigt

Denne portfolio indeholder to avancerede PowerShell scripts der demonstrerer kompetencer inden for:

- **Sikkerhed:** Adgangskodegenerering og netværkssikkerhed
- **Automation:** Systemadministration og netværksscanning
- **Integration:** Cross-platform kompatibilitet og eksterne værktøjer

## 💾 Installation

### 1. Klon eller download scripts

```powershell
# Hent scripts til din lokale maskine
git clone https://github.com/Kurdikiller1245/Introduktion-til-it-sikkerhed.git
cd powershell
```

### 2. Sikre kørselspolitik

```powershell
# Check nuværende execution policy
Get-ExecutionPolicy

# Sæt sikker policy for CurrentUser (anbefalet)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Alternativ: Kør med Bypass for enkeltstående scripts
powershell -ExecutionPolicy Bypass -File password-generator.ps1
```

### 3. Installer eksterne afhængigheder

**For Nmap Port Scanner:**
```bash
# Linux/macOS
sudo apt install nmap      # Debian/Ubuntu
sudo yum install nmap      # RHEL/CentOS
brew install nmap          # macOS

# Windows
# Download fra: https://nmap.org/download.html
# Standard installationsti: C:\Program Files (x86)\Nmap\
```

## 📚 Script Oversigt

### 1. PowerShell Password Generator
**Fil:** `password-generator.ps1`

En professionel adgangskodegenerator med konfigurerbare sikkerhedskrav og styrkevalidering.

#### Funktioner
- Konfigurerbar længde (8-64 tegn)
- Valgfri tegnsæt (store/små bogstaver, tal, symboler)
- Minimum krav for hver tegnkategori
- Styrkevalidering og scoring
- Generering af flere adgangskoder
- Kopier til udklipsholderen
- Cross-platform kompatibilitet

#### Brugseksempler
```powershell
# Grundlæggende brug (16 tegn)
.\password-generator.ps1

# Med specifik længde
.\password-generator.ps1 -Length 20

# Med avancerede krav
.\password-generator.ps1 -Length 24 -MinUpperCase 3 -MinNumbers 2 -MinSymbols 2

# Generer flere adgangskoder
.\password-generator.ps1 -Length 16 -Count 5
```

#### Eksempel output
```powershell
PS C:\Portfolio> .\password-generator.ps1 -Length 20

=== PASSWORD GENERATOR ===
[✓] Længde: 20 tegn
[✓] Kompleksitet: Meget høj (9/10)
[✓] Tegnsæt: A-Z, a-z, 0-9, !@#$%^&*()

Genereret adgangskode: J7#kP9@mQ2!vR5&xL8$t

[ℹ] Adgangskode opfylder NIST standarder
[ℹ] Kopieret til udklipsholderen
```

---

### 2. PowerShell Nmap Port Scanner
**Fil:** `nmap-openports.ps1`

En avanceret port scanning wrapper der integrerer Nmap med PowerShell til netværksreconnaissance.

#### Funktioner
- Finde åbne porte på targets
- Service detection og version information
- Multiple scan typer (Quick, Full, Custom)
- Massescanning af IP ranges
- Export af resultater til CSV/JSON/XML
- Custom port ranges og scanning strategies
- Progress reporting og timing

#### Scanningstyper
- **Quick:** Top 1000 porte (standard)
- **Full:** Alle porte (1-65535)
- **UDP:** UDP port scanning
- **Stealth:** SYN stealth scanning (kræver admin rettigheder)
- **Custom:** Brugerdefinerede portranges

#### Brugseksempler
```powershell
# Scan en enkelt host
.\nmap-openports.ps1 -Target 192.168.1.1

# Scan med service detection
.\nmap-openports.ps1 -Target scanme.nmap.org -ServiceDetection

# Scan specifikke porte
.\nmap-openports.ps1 -Target 192.168.1.1 -Ports "22,80,443,8080,8443"

# Fuld port scan
.\nmap-openports.ps1 -Target 192.168.1.1 -ScanType Full

# Scan et IP range
.\nmap-openports.ps1 -TargetRange "192.168.1.1-50" -ScanType Quick

# Export resultater til CSV
.\nmap-openports.ps1 -Target example.com -OutputFormat CSV -OutputFile "scan-results.csv"
```

#### Eksempel output
```powershell
PS C:\Portfolio> .\nmap-openports.ps1 -Target scanme.nmap.org -ServiceDetection

=== NMAP PORT SCANNER ===
[ℹ] Mål: scanme.nmap.org (45.33.32.156)
[ℹ] Scan type: Quick scan (top 1000 TCP ports)
[ℹ] Starttid: 11-12-2024 14:30:22

[↻] Scanning i gang...
[✓] 54 porte scannet (5% færdig)
[✓] 212 porte scannet (21% færdig)
[✓] Scanning færdig: 100% (1000/1000 porte)

ÅBNE PORTER FUNDET:
Port    State   Service     Version
----    -----   -------     -------
22/tcp  open    ssh         OpenSSH 8.9p1 Ubuntu 3ubuntu0.6
80/tcp  open    http        Apache httpd 2.4.52
443/tcp open    ssl/https   Apache httpd 2.4.52

SCAN STATISTIK:
- Scannet porte: 1000
- Åbne porte: 3 (0.3%)
- Filtered porte: 997
- Scan varighed: 12.45 sekunder

[✓] Resultater gemt til: scanme-nmap-org-results-20241211.csv
[ℹ] Rapport genereret: scanme-nmap-org-report.html
```

---

## 🚀 Brug

### Grundlæggende Brug

```powershell
# Naviger til mappen med scripts
cd C:\Sti\Til\Scripts

# Kør password generator
.\password-generator.ps1

# Kør port scanner
.\nmap-openports.ps1 -Target 192.168.1.1
```

### Avancerede Parametre

#### Password Generator:
```powershell
# Komplet parameter eksempel
.\password-generator.ps1 `
    -Length 24 `
    -MinUpperCase 3 `
    -MinLowerCase 4 `
    -MinNumbers 2 `
    -MinSymbols 2 `
    -ExcludeSimilar `
    -NoAmbiguous `
    -CopyToClipboard `
    -ShowStrength
```

#### Nmap Port Scanner:
```powershell
# Komplet scanning opsætning
.\nmap-openports.ps1 `
    -Target "192.168.1.0/24" `
    -ScanType "TCP-SYN" `
    -Ports "1-1000" `
    -ServiceDetection `
    -OSDetection `
    -TimingTemplate "Aggressive" `
    -OutputFormat "All" `
    -OutputDir ".\ScanResults" `
    -Verbose
```

### Scripts der Kræver Administrator

```powershell
# Kør PowerShell som Administrator
Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"nmap-openports.ps1`" -Target 127.0.0.1 -ScanType Full"

# Eller på Linux/macOS
sudo pwsh ./nmap-openports.ps1 -Target localhost
```

---

## 📦 Krav

### Systemkrav

| Komponent | Minimum | Anbefalet |
|-----------|---------|------------|
| PowerShell | 5.1 | 7.3+ |
| RAM | 512 MB | 2 GB |
| Diskplads | 100 MB | 500 MB |

### Platform Support

| Script | Windows | Linux | macOS | Notes |
|--------|---------|-------|-------|-------|
| password-generator.ps1 | ✓ | ✓ | ✓ | Full support alle platforme |
| nmap-openports.ps1 | ✓ | ✓ | ✓ | Kræver Nmap installation |

### Nødvendige Installationer

#### For alle scripts:
- PowerShell 5.1+ (Windows) eller PowerShell Core 7+ (cross-platform)

#### Specifikt for Nmap Port Scanner:

**Windows:**
1. Download Nmap fra https://nmap.org/download.html
2. Installer med standardindstillinger
3. Tilføj til PATH: `C:\Program Files (x86)\Nmap\`

**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install nmap
```

**Linux (RHEL/CentOS/Fedora):**
```bash
sudo dnf install nmap
# eller
sudo yum install nmap
```

**macOS:**
```bash
brew install nmap
```

---

## 🔒 Sikkerhed

### Vigtige Sikkerhedsnoter

⚠️ **Advarsel:** Anvend disse scripts ansvarligt og etisk.

#### For Password Generator:
1. **Adgangskode opbevaring:** Gem aldrig genererede adgangskoder i klartekst
2. **Sikkerhedskopiering:** Brug en password manager til opbevaring
3. **Midlertidige filer:** Slet alle midlertidige filer efter brug
4. **Clipboard management:** Ryd udklipsholderen efter brug i offentlige miljøer

#### For Nmap Port Scanner:
1. **Tilladelse:** Scan kun systemer du ejer eller har skriftlig tilladelse til at scanne
2. **Netværkspolitikker:** Respekter lokale netværkspolitikker og firewalls
3. **Rate limiting:** Undgå aggressive scanning der kan forårsage DoS
4. **Juridisk compliance:** Følg lokale og internationale love omkring netværksscanning

### Etiske Retningslinjer

```powershell
# ACCEPTABEL BRUG (med tilladelse)
.\nmap-openports.ps1 -Target dit_egen_server
.\nmap-openports.ps1 -Target kundeserver -WithWrittenPermission

# ACCEPTABEL BRUG (udvikling/test)
.\nmap-openports.ps1 -Target localhost
.\nmap-openports.ps1 -Target 127.0.0.1

# IKKE ACCEPTABEL BRUG (uden tilladelse)
.\nmap-openports.ps1 -Target offentlig_server_uden_tilladelse
.\nmap-openports.ps1 -TargetRange "10.0.0.0/8" -ScanType Aggressive
```

