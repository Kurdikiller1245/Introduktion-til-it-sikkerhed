# 🐧 En Rundtur i Linux - Komplet Guide

En praktisk guide til Linux terminalen med øvelser og løsningsforslag til at lære essentielle Linux-kommandoner og -koncepter.

## 📋 Indholdsfortegnelse

- [Tips til Terminalen](#-tips-til-terminalen)
- [Sammenkædning af Kommandoer](#-sammenkædning-af-kommandoer)
- [Øvelser - Linux Commands](#-øvelser---linux-commands)
  - [1) Filsystem](#-1-filsystem)
  - [2) Brugere og Grupper](#-2-brugere-og-grupper)
  - [3) Processer](#%EF%B8%8F-3-processer)
  - [4) Resurser](#-4-resurser-cpu-ram-disk)
  - [5) Netværk](#-5-netværk)
  - [6) Systeminfo & Environment](#%EF%B8%8F-6-systeminfo--environment)
  - [7) Installering & Opdatering](#-7-installering--opdatering-apt)
  - [8) Logging](#-8-logging-basic)
  - [9) Processer & Services](#-9-processer--services)
  - [10) Kryptografi](#-10-kryptografi-basic)
  - [11) AI i Shell](#-11-ai-i-shell)

## 🚀 Tips til Terminalen

### Effektivitetstips
```bash
# Autofuldførelse med Tab
cd /etc/apa<Tab>  # Autofuldfører til /etc/apache2/

# Naviger i kommando-historik
↑ # Forrige kommando
↓ # Næste kommando
Ctrl+R # Søg i historik
history # Vis kommando-historik

# Kontrol-taster
Ctrl+C # Afbryd kørende kommando
Ctrl+Z # Pause kommando (fg for at fortsætte)
Ctrl+D # Afslut session/input
Ctrl+L # Ryd skærmen (clear)
```

### Hjælpefunktioner
```bash
# Få hjælp til kommandoer
man ls           # Manuel side
ls --help        # Hurtig hjælp
whatis ls        # Kort beskrivelse
apropos search   # Find relaterede kommandoer

# Info om kommandoer
type ls          # Vis hvor kommando er
which ls         # Vis sti til kommando
whereis ls       # Vis alle steder kommando findes
```

## 🔗 Sammenkædning af Kommandoer

### Pipe Operator (`|`)
```bash
# Send output fra én kommando til en anden
ls -la | grep ".conf"          # Find konfigurationsfiler
ps aux | grep "apache"         # Find apache processer
cat /var/log/syslog | tail -20 # Vis sidste 20 linjer
dmesg | less                   # Page through kernel messages

# Kombiner flere pipes
ps aux | grep "python" | wc -l     # Tæl python processer
df -h | grep "/dev/sd" | sort -k5  # Sorter diskbrug
```

### Omdirigering (`>`, `>>`, `<`)
```bash
# Output til filer
echo "Resultat" > output.txt      # Overskriv fil
date >> log.txt                   # Tilføj til fil
ls -la > listing.txt 2> errors.txt # Separat output og fejl
ls -la > all_output.txt 2>&1      # Sammenslå output og fejl

# Input fra filer
cat < input.txt                   # Læs fra fil
sort < unsorted.txt > sorted.txt  # Sorter fil
grep "error" < /var/log/syslog    # Søg i fil

# /dev/null (kast output væk)
ls -la > /dev/null                # Ignorer output
command 2>/dev/null               # Ignorer fejlmeddelelser
```

### Logiske Operatorer
```bash
# AND (&&) - Kør kun hvis første kommando lykkes
mkdir test && cd test            # Opret og gå ind i mappe
ping -c1 google.com && echo "Online" # Tjek forbindelse

# OR (||) - Kør kun hvis første kommando fejler
cd /nonexistent || echo "Fejl"   # Håndter fejl
command || { echo "Fejl"; exit 1; } # Fejlhåndtering

# Kombiner AND og OR
make && echo "Success" || echo "Fejl"
test -f file.txt && cat file.txt || touch file.txt
```

### Bagrundskørsel (`&`)
```bash
# Kør kommandoer i baggrunden
sleep 60 &                      # Kør sleep i baggrunden
firefox &                       # Åbn browser i baggrunden
./long_script.sh &              # Kør script i baggrunden

# Kontroller baggrundsjobs
jobs                            # Vis baggrundsjobs
fg %1                           # Bring job 1 til forgrunden
bg %1                           # Send job 1 til baggrunden
kill %1                         # Stop job 1
```

## 🐧 Øvelser - Linux Commands

### 📂 1) Filsystem

#### Øvelser:
1. **Find din nuværende sti og gå til din hjemmemappe**
2. **Opret `~/kali-ovelser/fs` med `data` og `tmp` som undermapper**
3. **Lav filen `notes.txt` i `data` med teksten "hej kali"**
4. **Flyt `notes.txt` til `tmp` og omdøb den til `.hidden_notes`**

#### Læringsmål:
- Navigering i filsystemet
- Oprettelse af mapper og filer
- Flytning og omdøbning af filer
- Skjulte filer (starter med `.`)

#### Udfordringer:
```bash
# Ekstra udfordringer
# 1. Opret en symbolsk link til .hidden_notes
# 2. Find størrelsen på alle filer i fs-mappen
# 3. Tjek rettigheder på mapperne
```

### 👤 2) Brugere og Grupper

#### Øvelser:
1. **Vis dit brugernavn og hvilke grupper du er i**
2. **Slå din bruger op i `/etc/passwd`**
3. **(Hvis muligt) Opret gruppen `lab` og tilføj din bruger til den**

#### Læringsmål:
- Bruger- og gruppeinformation
- Systembrugerdatabase
- Gruppeadministration

#### Vigtige filer:
```bash
/etc/passwd    # Brugerinformation
/etc/group     # Gruppeinformation
/etc/shadow    # Password hashes (beskyttet)
```

### ⚙️ 3) Processer

#### Øvelser:
1. **Vis processer for din bruger**
2. **Find PID for din nuværende shell**
3. **Start `sleep 60` i baggrunden og vis at den kører**

#### Læringsmål:
- Processadministration
- Process ID (PID)
- Baggrundsprocesser
- Job kontrol

#### Nyttige kommandoer:
```bash
ps           # Process status
top/htop     # Realtime process viewer
pstree       # Processer som træ
kill         # Stop processer
nice/renice  # Ændre prioritet
```

### 💻 4) Resurser (CPU, RAM, Disk)

#### Øvelser:
1. **Vis et snapshot af CPU og RAM**
2. **Vis brug af monterede filerystemer**
3. **Mål hvor lang tid `ls /` tager**

#### Læringsmål:
- Systemresursovervågning
- Diskbrug og tilgængelighed
- Performance måling

#### Overvågningsværktøjer:
```bash
vmstat       # Virtuel memory statistik
iostat       # I/O statistik
sar          # System aktivitetsrapport
free         # Hukommelsesbrug
uptime       # System load
```

### 🌐 5) Netværk

#### Øvelser:
1. **Vis dine netværksinterfaces og IP-adresser**
2. **Ping `kali.org` med 3 pakker**
3. **Se hvilke processer der lytter på lokale porte**

#### Læringsmål:
- Netværkskonfiguration
- Forbindelsestest
- Port scanning og lyttere

#### Netværkskommandoer:
```bash
ifconfig/ip   # Interface konfiguration
netstat/ss    # Netværksstatistik
traceroute    # Spor rute til host
dig/nslookup  # DNS opslag
curl/wget     # HTTP requests
```

### 🛠️ 6) Systeminfo & Environment

#### Øvelser:
1. **Vis kernel-version og maskine-arkitektur**
2. **Vis miljøvariablen `PATH`**

#### Læringsmål:
- Systeminformation
- Miljøvariabler
- Shell-konfiguration

#### Systeminfo kommandoer:
```bash
uname -a      # Alle systeminfo
hostnamectl   # System hostname info
lscpu         # CPU information
lsblk         # Blok enheder
lshw          # Hardware information
```

### 📦 7) Installering & Opdatering (APT)

#### Øvelser:
1. **Opdater pakkelister**
2. **Søg efter pakken `jq`**
3. **Installer `jq`, vis versionen, og fjern den igen**

#### Læringsmål:
- Pakkehåndtering
- Software installation
- Systemopdatering

#### APT kommandoer:
```bash
sudo apt update        # Opdater pakkelister
sudo apt upgrade       # Opgrader pakker
sudo apt install       # Installer pakke
sudo apt remove        # Fjern pakke
sudo apt search        # Søg efter pakker
sudo apt show          # Vis pakkeinfo
sudo apt autoremove    # Fjern ubrugte pakker
```

### 📜 8) Logging (Basic)

#### Øvelser:
1. **Se de sidste 20 linjer i systemjournalen**
2. **Se de sidste 20 linjer for ssh-servicen**
3. **Se de seneste APT-hændelser (pakkehistorik)**
4. **Følg i realtid en logfil i ~10 sekunder og stop med Ctrl+C**
5. **List de 5 største filer i `/var/log` (overblik)**

#### Læringsmål:
- System logging
- Logfilsanalyse
- Realtime monitoring
- Logrotation

#### Logfiler og kommandoer:
```bash
/var/log/syslog       # System log
/var/log/auth.log     # Authentication log
/var/log/kern.log     # Kernel log
/var/log/dpkg.log     # Pakkeinstallationer

journalctl            # Systemd journal
logrotate             # Log rotation
grep                  # Søg i logs
tail -f               # Følg log i realtid
```

### 🔧 9) Processer & Services

#### Øvelser:
1. **Kør `ping -c 10 8.8.8.8` og stop den med Ctrl+C**
2. **Start `sleep 120` i baggrunden og stop den igen**
3. **Tjek status for ssh-service**

#### Læringsmål:
- Processkontrol
- Service administration
- Signalhåndtering

#### Service kommandoer:
```bash
systemctl status      # Service status
systemctl start       # Start service
systemctl stop        # Stop service
systemctl restart     # Genstart service
systemctl enable      # Aktivér ved opstart
systemctl disable     # Deaktivér ved opstart
```

### 🔐 10) Kryptografi (Basic)

#### Øvelser:
1. **Lav en SHA-256 hash af `.hidden_notes` og gem den**
2. **Krypter `.hidden_notes` symmetrisk til en ny fil og dekrypter igen**
3. **(Med nøgle) Signér `.hidden_notes` og verificér signaturen**

#### Læringsmål:
- Hash-funktioner
- Symmetrisk kryptering
- Digitale signaturer
- Data integritet

#### Kryptografiske værktøjer:
```bash
sha256sum/md5sum     # Hash beregning
gpg                  # GNU Privacy Guard
openssl              # SSL/TLS værktøjer
cryptsetup           Disk encryption
```

### 🤖 11) AI i Shell

#### Øvelser:
1. **Undersøg applikationen shell-gpt: https://pypi.org/project/shell-gpt/**

#### Installation og brug:
```bash
# Installer shell-gpt
pip install shell-gpt

# Konfigurer API nøgle
export OPENAI_API_KEY="din-api-nøgle"

# Brug eksempler
sgpt "vis mig alle processer der bruger meget CPU"
sgpt "hvordan installerer jeg en pakke på debian?"
sgpt "forklar denne kommando: find / -name '*.conf' 2>/dev/null"
```
