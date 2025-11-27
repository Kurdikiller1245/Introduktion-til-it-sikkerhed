# 🐧 Linux Øvelser – Grundlæggende Systemforståelse

Dette repository indeholder mine Linux-øvelser, hvor jeg gennemfører en række praktiske terminalopgaver inden for filsystem, brugere, processer, netværk, logging, kryptografi og AI i command line.

## 📂 1) Filsystem

* Finder min nuværende sti og går til min hjemmemappe.
* Opretter `~/kali-ovelser/fs` med `data` og `tmp` som undermapper.
* Laver filen `notes.txt` i `data` med teksten “hej kali”.
* Flytter `notes.txt` til `tmp` og omdøber den til `.hidden_notes`.

## 👤 2) Brugere og grupper

* Viser mit brugernavn og hvilke grupper jeg er i.
* Slår min bruger op i `/etc/passwd`.
* Opretter gruppen `lab` og tilføjer min bruger til den (hvis muligt).

## ⚙️ 3) Processer

* Viser processer for min bruger.
* Finder PID for min nuværende shell.
* Starter `sleep 60` i baggrunden og viser at processen kører.

## 💻 4) Ressourcer (CPU, RAM, disk)

* Viser et snapshot af CPU og RAM.
* Viser brug af monterede filsystemer.
* Måler hvor lang tid `ls /` tager.

## 🌐 5) Netværk

* Viser mine netværksinterfaces og IP-adresser.
* Pinger `kali.org` med 3 pakker.
* Viser hvilke processer der lytter på lokale porte.

## 🛠️ 6) Systeminfo & environment

* Viser kernel-version og maskinarkitektur.
* Viser miljøvariablen `PATH`.

## 📦 7) Installering & opdatering (APT)

* Opdaterer pakkelister.
* Søger efter pakken `jq`.
* Installerer `jq`, viser versionen og fjerner den igen.

## 📜 8) Logging (basic)

* Viser de sidste 20 linjer i systemjournalen.
* Viser de sidste 20 linjer for SSH-servicen.
* Viser de seneste APT-hændelser (pakkehistorik).
* Følger en logfil i ca. 10 sekunder og stopper med Ctrl+C.
* Lister de 5 største filer i `/var/log`.

## 🔧 9) Processer & services

* Kører `ping -c 10 8.8.8.8` og stopper den med Ctrl+C.
* Starter `sleep 120` i baggrunden og stopper den igen.
* Tjekker status på SSH-service.

## 🔐 10) Kryptografi (basic)

* Laver en SHA-256 hash af `.hidden_notes` og gemmer den.
* Krypterer `.hidden_notes` symmetrisk til en ny fil og dekrypterer den igen.
* Signerer `.hidden_notes` og verificerer signaturen.

## 🤖 11) AI i shell

* Undersøger applikationen *shell-gpt* (command-line AI).
