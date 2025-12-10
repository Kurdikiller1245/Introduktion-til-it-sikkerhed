# **Bash Scripting Portfolio**

## 📌 **Om projektet**

Dette repository indeholder en samling af Bash-scripts udviklet som en del af en læringsopgave med fokus på at opbygge praktiske færdigheder i scripting. Målet er at blive fortrolig med Bash, så jeg kan løse scriptingopgaver selvstændigt.

Alle scripts er testet i **Kali Linux** og dokumenteret, så hver linje er forstået og forklaret.

***


## 🟢 **Begynder-scripts**

*   [x] Vise dato og klokkeslæt
*   [x] Vise systemets hostname og IP-adresse
*   [x] Liste alle `.conf`-filer i `/etc`
*   [x] Tjekke om en fil findes og give besked
*   [x] Tælle antal aktive brugere
*   [x] Vise kørende processer for en given bruger
*   [x] Tjekke om en port (fx 22) er åben
*   [x] Overvåge diskplads og advare ved <10%
*   [x] Vise de sidste 10 mislykkede loginforsøg

***

## 🟡 **Øvet-scripts**

*   [x] Overvåge ændringer i `/etc/passwd`
*   [x] Generere tilfældig adgangskode (16 tegn)
*   [x] Hash en fil med `sha256sum` og tjek integritet
*   [x] Søge rekursivt efter world-writable filer
*   [x] Scanne subnet for aktive værter
*   [x] Udtrække unikke IP-adresser fra webserver-log
*   [x] Overvåge processer og dræbe dem ved nøgleord
*   [x] Tjekke `.ssh/authorized_keys` i hjemmemapper
*   [x] Overvåge åbne netværksforbindelser
*   [x] Liste alle setuid-binaries

***

## 🔴 **Avancerede scripts (valgfrit)**

*   [x] Brute-force ZIP-fil med ordliste
*   [x] Simpel keylogger (registrere tastetryk)
*   [x] Automatisere `nmap`-scanninger
*   [x] Overvåge `/var/log/auth.log` og sende mail ved mistænkelig aktivitet
*   [x] Generere firewall-regler fra whitelist
*   [x] Analysere Apache-logs for SQL-injection-forsøg
*   [x] Overvåge rettigheder på `/etc/shadow`
*   [x] Implementere simpelt IDS med checksums
*   [x] Automatisere honeyfiles og log adgangsforsøg
*   [x] Roter og krypter logs dagligt

***

## 🛠 **Sådan kører du scripts**

1.  Klon repo:
    ```bash
    git clone https://github.com/Kurdikiller1245/Introduktion-til-it-sikkerhed.git
    cd Linux:Shell-Script
    ```
2.  Gør scriptet eksekverbart:
    ```bash
    chmod +x scriptnavn.sh
    ```
3.  Kør scriptet:
    ```bash
    ./scriptnavn.sh
    ```
