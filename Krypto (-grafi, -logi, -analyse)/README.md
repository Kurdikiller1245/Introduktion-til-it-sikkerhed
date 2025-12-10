# Kryptografiopgaver – Rapport

Dette repository indeholder løsninger og beskrivelser af kryptografiske opgaver gennemført som en del af et studieprojekt. Opgaverne dækker både historisk og moderne kryptografi samt anvendte kryptografiske teknologier.

## Indholdsfortegnelse
- [Historisk kryptografi](#historisk-kryptografi)
- [Moderne kryptografi](#moderne-kryptografi)
- [Anvendt kryptografi](#anvendt-kryptografi)

---

## Historisk kryptografi

### 1. Caesar ROT
- **Opgave:** Kryptering og dekryptering med ROT1 og ROT13 i CyberChef.
- **Klartekst:** `Hej jeg hedder Alend`
- **Kryptotekst:** `Urw wrt urqgre Nyraq`
- **Resultat:** Succesfuld udveksling og dekryptering med medstuderende.

### 2. Vigenére
- **Opgave:** Kryptering og dekryptering med Vigenére-chiffer.
- **Nøgle (fra mig):** `alend`
- **Kryptotekst (fra mig):** `Hpn uyao pnyec hh`
- **Nøgle (fra medstuderende):** `alperen`
- **Kryptotekst (fra medstuderende):** `mtc ofhr ec wia123456`

### 3. Steganografi
- **Opgave:** Find en skjult besked i et billede via [Steganography Online](https://gist.github.com/andracs/c2b6a7ae6efb179043b6728e312222ac).
- **Resultat:** Beskeden blev dekodet og beskriver steganografiens princip.

### 4. Enigma og Bomba (Ekstraopgave)
- **Opgave:** Simulering af Enigma-kryptering og dekryptering med Bomba i CyberChef.
- **Input:** `Kan denne besked læses?`
- **Output:** `WDOLR ERYFC JCLFV DTN`
- **Bombe-dekryptering:** `Kandennebeskedlæses?`

---

## Moderne kryptografi

### 1. Symmetrisk kryptering
- **DES, Triple DES, AES** blev afprøvet i CyberChef.
- Nøgler, IV’er og output er dokumenteret for hvert algoritme.

### 2. Asymmetrisk kryptering (RSA)
- **Opgave:** Generering af RSA-nøgler, kryptering, dekryptering, signering og verifikation.
- **Værktøj:** OpenSSL / CyberChef.
- **Resultat:** Succesfuld udveksling og verifikation med medstuderende.

### 3. Encoding
- **Opgave:** Konvertering af UTF-8 tekst med danske tegn og emojis til ASCII, URL encoding, Base64 og Base32.
- **Resultat:** Datatab ved konvertering til ASCII blev observeret.

### 4. PGP
- **Opgave:** Kryptering, signering, dekryptering og verifikation med PGP i CyberChef.
- **Nøgler:** Genereret i CyberChef.

### 5. Hashing
- **Opgave:** Beregning af hashværdier (MD4, MD5, SHA-1, SHA-2, SHA-3) for en given besked.
- **Verifikation:** Medstuderende verificerede hashværdierne.

### 6. Cracking med CrackStation
- **Opgave:** Crack en MD5-hash af et simpelt password.
- **Resultat:** Hash: `480b6e862e547a795ffc4e541caeddd` → Password: `easy`

### 7. ECC (Elliptic Curve Cryptography)
- **Opgave:** Generering af ECDSA-nøglepar, signering og verifikation af en besked.
- **Værktøj:** CyberChef og [emn178.github.io](https://emn178.github.io/online-tools/ecdsa/verify/).
- **Resultat:** Signatur verificeret korrekt.

### 8. Hashcat
- **Opgave:** Crack et MD4-hashed password med Hashcat i Kali Linux.
- **Hash:** `a58fc871f5f68e4146474ac1e2f07419` → Password: `Hello`

### 9. Crack en passwordbeskyttet ZIP-fil
- **Opgave:** Opret og crack en ZIP-fil beskyttet med adgangskode.
- **Værktøj:** `fcrackzip` i Kali.
- **Resultat:** Password fundet: `password`

---

## Anvendt kryptografi

### 1. TLS-certifikater i browsere
- **Opgave:** Undersøg TLS-certifikatet for `moodle.zealand.dk`.
- **Resultat:** Certifikat fra Let's Encrypt med RSA 2048-bit.

### 2. Keybase.io
- **Opgave:** Brug Keybase til sikker chat, filoverførsel, signering og verifikation.
- **Resultat:** End-to-end krypteret kommunikation afprøvet.

### 3. OnionShare
- **Opgave:** Del filer anonymt via Tor med OnionShare.
- **Resultat:** Filoverførsel gennem midlertidige .onion-links.

### 4. Pcrypt
- **Opgave:** Undersøg Pcrypt som lokal kryptografivirksomhed.

### 5. Open source key management
- **Opgave:** Afprøv Bitwarden som open source password manager.
- **Resultat:** Brugervenlig og sikker løsning til password-håndtering.

### 6. Kryptografi i din software
- **Opgave:** Undersøg Web Crypto API.
- **Kilde:** [Microsoft Copilot](https://copilot.cloud.microsoft/)
- **Resultat:** Web Crypto API giver adgang til kryptografiske funktioner direkte i browseren.

### 7. Sikker e-mail?
- **Opgave:** Undersøg muligheder for sikker e-mail (PGP, Office 365 Encryption, Proton Mail).
- **Resultat:** Forskellige løsninger afprøvet og dokumenteret.

### 8. Kvantesikker kryptografi (artikel)
- **Opgave:** Læs og opsummer [CFCS-artikel om kvantesikker kryptografi](https://www.cfcs.dk/da/temasider/overgangen-til-kvantesikker-kryptografi/).
- **Opsummering:** 6 bullet points om trusler, standardisering og tiltag.

### 9. Blockchain fra bunden (Ekstra)
- **Opgave:** Design og simpel implementering af en blockchain.
- **Resultat:** Blockchain med genesis block og transaktioner valideret.


