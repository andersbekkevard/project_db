# Wave 2.5: Verifikasjonsbrief for DB2

## Formål

Dette notatet definerer hva som skal kjøres, hva som teller som bevis, hva som kan gi falsk trygghet, og hvilken verifikasjonstype som gjelder før implementasjonen starter.

Tier-definisjoner:

- Tier 1: autonom verifikasjon. Kjøring og observasjon kan automatiseres uten menneskelig tolkning.
- Tier 2: god proxy. Kjøring er automatiserbar, men signalet er indirekte eller delvis avhengig av avtalte demo-forutsetninger.
- Tier 3: krever menneskelig vurdering. Struktur, lesbarhet eller dokumentasjonskvalitet må vurderes manuelt.

Alle kommandoer under forutsetter at man står i `TreningDB_DB2/`.

## Brukstilfeller

| Brukstilfelle | Hva som skal kjøres | Observerbart signal som beviser at det virker | Hva som kan se riktig ut uten å være riktig | Tier |
| --- | --- | --- | --- | --- |
| UC1: legg inn grunnlagsdata | `python3 91_init_db.py` etter at `trening.db` er slettet eller nullstilt | `trening.db` opprettes, skjemaet finnes, og seed-data inneholder sentre, saler, Øya-fasiliteter, nummererte sykler, brukere, instruktører og gruppetimer i perioden `2026-03-16` til `2026-03-18` | Scriptet kan skrive «ferdig» selv om databasen allerede inneholdt gamle rader, eller om seed-data mangler Johnny, GT4 eller prikk-rader som senere brukstilfeller er avhengige av | Tier 1 |
| UC2: booking | `python3 20_uc2_book_gruppetime.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-15 19:00:00"` | Output sier at bookingen ble opprettet, og databasen får nøyaktig én ny rad i `deltar_på_time` for Johnny og GT4 med satt `påmeldt_tidspunkt` | Wrapperen kan skrive suksess selv om den booker feil trening, ignorerer kapasitetskontroll, eller oppretter dublett for samme bruker | Tier 1 |
| UC3: registrer oppmøte | `python3 30_uc3_registrer_oppmote.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-17 18:24:00"` | Output sier at oppmøte ble registrert, og raden for Johnny + GT4 får nøyaktig ett `oppmøtt_tidspunkt` | Løsningen kan oppdatere alle rader for Johnny, skrive til feil tabell, eller markere booking som oppmøte uten å sjekke 5-minuttersgrensen | Tier 1 |
| UC4: ukeplan | `python3 40_uc4_ukeplan.py --startdato 2026-03-16 --uke 12` | Output inneholder alle seedede spinningtimer i uke 12, sortert globalt stigende på starttid på tvers av Øya og Dragvoll | Output kan være sortert senter for senter, bruke tekstsortering i stedet for datotid, eller feilaktig ta med `2026-03-23`, som i 2026 er uke 13 | Tier 1 |
| UC5: personlig besøkshistorikk | `sqlite3 -header -column trening.db < 50_uc5_besokshistorikk.sql` etter init og UC3 | Output inneholder bare unike rader for Johnnys faktiske deltakelser siden `2026-01-01`, med aktivitet, senter og dato/tid | Queryet kan se riktig ut selv om det teller bookinger i stedet for oppmøte, eller om joinene gir duplikatrader som tilfeldigvis skjules i terminalvisningen | Tier 1 |
| UC6: svartelisting | `python3 60_uc6_svartelisting.py --epost johnny@stud.ntnu.no --referansetid "2026-03-18 21:00:00"` | Output sier at brukeren ble utestengt, og `bruker.utestengt_til` settes til `2026-04-16 00:00:00` fordi første relevante prikk er `2026-03-16` | Koden kan telle alle historiske prikker i stedet for siste 30 dager, bruke feil frist, eller svarteliste uten å bevise at tre-prikkerskravet faktisk var oppfylt | Tier 1 |
| UC7: månedens mest aktive | `python3 70_uc7_maanedsvinner.py --maaned 2026-03` | Output returnerer både Kari og Ola som vinnere for mars 2026, med likt høyeste antall registrerte deltakelser | Queryet kan telle bookinger, ikke oppmøter, eller returnere bare én vinner fordi den bruker `LIMIT 1` i stedet for å håndtere delt førsteplass | Tier 1 |
| UC8: trener sammen | `sqlite3 -header -column trening.db < 80_uc8_trener_sammen.sql` | Output viser to e-poster og antall felles treninger, og det seedede paret Kari + Ola finnes med riktig antall | En selv-join kan telle samme par to ganger i ulik rekkefølge, telle bookinger i stedet for oppmøter, eller inkludere samme person mot seg selv | Tier 1 |

## Tverrgående leveranser

| Leveranse | Hva som skal kjøres eller kontrolleres | Observerbart signal som beviser at det virker | Hva som kan se riktig ut uten å være riktig | Tier |
| --- | --- | --- | --- | --- |
| Tom database og full init fra bunnen | `rm -f trening.db && python3 91_init_db.py` | Hele løsningen kan bygges fra null uten manuelle SQL-steg, og samme database oppstår hver gang | `91_init_db.py` kan være avhengig av at `trening.db` allerede finnes, eller av relative repo-stier som ikke følger med i sluttmappen | Tier 1 |
| Reproduserbar standardsekvens | `python3 92_reproduser_alt.py` | Alle `resultat_*.txt` blir generert på nytt fra ren tilstand med samme innhold som leveres | Scriptet kan hoppe over brukstilfeller, bruke hardkodede resultatfiler uten å kjøre SQL, eller være avhengig av lokal utviklertilstand | Tier 1 |
| Flat leveransemappe | `ls` i sluttmappen og sammenligning mot låst filliste | Alle avtalte filer finnes med nøyaktige navn og uten skjulte repoavhengigheter | Filer kan finnes, men med avvikende navn, blandet språk eller manglende SQL-filer for brukstilfeller som skal leveres både i SQL og Python | Tier 2 |
| README som faktisk matcher kjøringen | Følg `00_README.md` ordrett i en ren mappe | Kommandoene i README virker uten ekstra forklaring og gir samme resultat som `92_reproduser_alt.py` | README kan være plausibel, men med gammel kommandosyntaks, feil filnavn eller manglende eksempelparametere | Tier 2 |
| Resultatfiler som samsvarer med kjørbar kode | `diff` mellom nygenererte filer og leverte `resultat_*.txt` | Ingen differanser etter standardkjøring fra ren init | Resultatfilene kan være håndredigerte, eller generert fra en annen seed-versjon enn den som leveres | Tier 1 |
| KI-erklæring | Manuell lesing av `01_KI-erklaering.md` | Erklæringen skiller tydelig mellom KI-generert og menneskelig bearbeidet materiale og peker til faktiske filer | Dokumentet kan være til stede uten å forklare hva som faktisk ble brukt, eller uten sporbar kobling til filene i leveransen | Tier 3 |
| Lesbar kode og SQL-first-stil | Manuell lesing av Python- og SQL-filer | SQL bærer domenelogikken, mens Python bare håndterer parametere, transaksjoner og utskrift | Koden kan fungere i demoen, men likevel tape poeng fordi Python gjør filtrering, sortering og statistikkarbeid som skulle ligget i SQL | Tier 3 |

## Faste kontrollpunkter per brukstilfelle

### UC2 må i tillegg ha én negativ kontroll

Ekstra kjøring:

`python3 20_uc2_book_gruppetime.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-17 19:00:00"`

Forventet signal:

- booking avvises fordi referansetiden er etter oppstart

Mulig falsk positiv:

- scriptet avviser av feil grunn, for eksempel fordi trening ikke finnes eller fordi brukeren allerede er booket

Tier:

- Tier 2

### UC3 må i tillegg ha én negativ kontroll

Ekstra kjøring:

`python3 30_uc3_registrer_oppmote.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-17 18:26:00"`

Forventet signal:

- oppmøte avvises fordi 5-minuttersfristen er passert

Mulig falsk positiv:

- scriptet avviser fordi booking mangler eller fordi feil trening ble slått opp

Tier:

- Tier 2

### UC6 må i tillegg ha én negativ kontroll

Ekstra kjøring på en kopi av databasen eller etter ny init:

`python3 60_uc6_svartelisting.py --epost emma@stud.ntnu.no --referansetid "2026-03-18 21:00:00"`

Forventet signal:

- svartelisting avvises fordi Emma ikke har tre prikker siste 30 dager

Mulig falsk positiv:

- scriptet avviser fordi brukeren ikke finnes, ikke fordi prikkgrunnlaget er utilstrekkelig

Tier:

- Tier 2

## Autonom minimumsgate før pakken regnes som grønn

Følgende må alle passere i samme kjøring:

1. `rm -f trening.db`
2. `python3 91_init_db.py`
3. positiv kjøring av UC2, UC3, UC4, UC6 og UC7
4. SQL-kjøring av UC5 og UC8
5. `python3 92_reproduser_alt.py`
6. ingen differanse mellom nygenererte og leverte `resultat_*.txt`

Hvis én av disse feiler, er pakken ikke klar for sluttpakking.
