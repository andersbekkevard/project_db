# Wave 2: Arkitektur- og gjennomføringsplan for DB2

## Formål

Dette notatet låser den anbefalte DB2-formen før implementasjon. Målet er en leveranse som er lett å kjøre fra en tom SQLite-database, scorer best mulig på rubrikken, og kan deles mellom flere kodeagenter uten overlappende ansvar.

Styrende prioritering:

1. SQL skal være hovedmotoren.
2. Leveransen skal være reproduserbar fra tom database.
3. Seed-data skal være liten, men tilstrekkelig til å bevise alle 8 brukstilfeller.
4. Skjemaendringer skal være færrest mulig, men store nok til å fjerne tvetydighet og skjøre dato-/oppmøteløsninger.

## Endelig leveranseform

Anbefalt sluttmappe er én flat mappe:

`TreningDB_DB2/`

Kanoniske filnavn i sluttmappen:

```text
TreningDB_DB2/
├── 00_README.md
├── 01_KI-erklaering.md
├── 10_schema.sql
├── 11_seed_data.sql
├── 20_uc2_book_gruppetime.sql
├── 20_uc2_book_gruppetime.py
├── 30_uc3_registrer_oppmote.sql
├── 30_uc3_registrer_oppmote.py
├── 40_uc4_ukeplan.sql
├── 40_uc4_ukeplan.py
├── 50_uc5_besokshistorikk.sql
├── 60_uc6_svartelisting.sql
├── 60_uc6_svartelisting.py
├── 70_uc7_maanedsvinner.sql
├── 70_uc7_maanedsvinner.py
├── 80_uc8_trener_sammen.sql
├── 90_db.py
├── 91_init_db.py
├── 92_reproduser_alt.py
├── trening.db
├── resultat_uc2_booking.txt
├── resultat_uc3_oppmote.txt
├── resultat_uc4_ukeplan.txt
├── resultat_uc5_besokshistorikk.txt
├── resultat_uc6_svartelisting.txt
├── resultat_uc7_maanedsvinner.txt
└── resultat_uc8_trener_sammen.txt
```

Begrunnelse:

- Flatt oppsett reduserer sensorrisiko. Sensor trenger ikke navigere i repoet.
- Nummererte filnavn gir entydig kjørerekkefølge.
- SQL er synlig som egne filer, i tråd med rubrikken.
- Python er beholdt som tynne inngangspunkter der oppgaven krever Python og SQL.

## Anbefalt kjørerekkefølge

Kanonisk sensurflyt:

1. `python3 91_init_db.py`
2. `python3 20_uc2_book_gruppetime.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-15 19:00:00"`
3. `python3 30_uc3_registrer_oppmote.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-17 18:24:00"`
4. `python3 40_uc4_ukeplan.py --startdato 2026-03-16 --uke 12`
5. `sqlite3 -header -column trening.db < 50_uc5_besokshistorikk.sql`
6. `python3 60_uc6_svartelisting.py --epost johnny@stud.ntnu.no --referansetid "2026-03-18 21:00:00"`
7. `python3 70_uc7_maanedsvinner.py --maaned 2026-03`
8. `sqlite3 -header -column trening.db < 80_uc8_trener_sammen.sql`

`92_reproduser_alt.py` skal kjøre samme rekkefølge og skrive alle `resultat_*.txt` på nytt fra ren tilstand.

## Skjemaendringer

### Påkrevde endringer

| Endring | Hvorfor den er påkrevd | Konsekvens hvis den utelates |
| --- | --- | --- |
| `bruker.epost` får `UNIQUE` | Alle brukstilfeller bruker e-post som identitet. E-post må derfor være kanonisk brukernavn. | UC2, UC3, UC5 og UC6 kan bli tvetydige. |
| `gruppetime` får `starttidspunkt TEXT NOT NULL` og `sluttidspunkt TEXT NOT NULL` med `datetime`-sjekker | Booking, oppmøte, ukeplan, historikk, svartelisting og månedsstatistikk trenger konkrete tidspunkter, ikke bare uke + tidsblokk. | SQL blir skjør, datoavledningen vanskelig, og 18:30-eksempelet passer dårlig med dagens modell. |
| `deltar_på_time` får `oppmøtt_tidspunkt TEXT` med `datetime`-sjekk | Oppgaven krever å vite hvem som møtte og hvem som ikke møtte. | UC3, UC5, UC7 og UC8 blir booking-spørringer i stedet for deltakelsesspørringer. |
| `spinningsykkel` får `nr INTEGER NOT NULL` og `UNIQUE (senter_id, sal_nr, nr)` | Oppgaven sier at hver sykkel i salen har et nummer. | Seed-data for sykler blir ikke tro mot domenet. |
| `tredemølle` får `nr INTEGER NOT NULL` og `UNIQUE (senter_id, sal_nr, nr)` | Oppgaven sier at tredemøller også identifiseres med nummer i salen. | Domenedelen for møller forblir ufullstendig. |

Anbefalt behandling av eksisterende tabeller:

- `time_skjer_i` og `tidsblokk` beholdes for bakoverkompatibilitet mot DB1-materialet.
- DB2-spørringer skal bruke `gruppetime.starttidspunkt` og `gruppetime.sluttidspunkt` som sannhetskilde.
- `uke_nr` og `år` kan beholdes i `gruppetime`, men skal regnes som sekundære felt. De brukes bare til enkel sporbarhet mot DB1.

### Valgfrie endringer

| Endring | Status | Begrunnelse |
| --- | --- | --- |
| `senter.navn` får `UNIQUE` | Valgfri | Lav kostnad og ryddig, men ikke nødvendig hvis oppslag skjer via `gruppetime.id` eller entydig SQL. |
| `deltar_på_time.status` for `booket`, `oppmøtt`, `avmeldt`, `uteblitt`, `venteliste` | Valgfri | Domenemessig fin, men ikke nødvendig for å bestå brukstilfelle 1-8. |
| `gruppetime.publisert_tidspunkt` | Valgfri | 48-timersregelen kan avledes fra `starttidspunkt - 48 timer`; eget felt er ikke nødvendig. |
| Indekser på `gruppetime.starttidspunkt`, `deltar_på_time.prikk_dato`, `deltar_på_time.oppmøtt_tidspunkt` | Valgfri | Gir bedre ytelse, men er ikke kritisk for et lite demosett. |

## Bindende tolkninger av uklarheter

### Uke 12 og datointervallet

Anbefalt tolkning:

- Ukeplanen i UC4 skal implementeres som et uttrekk for faktisk ISO-uke.
- For 2026 er `2026-03-16` mandag i uke 12.
- `2026-03-23` er mandag i uke 13, ikke i uke 12.
- Formuleringen «fra 16. mars til 23. mars» behandles derfor som en spesifikasjonsglipp.

Praktisk konsekvens:

- Kanonisk demo for UC4 bruker `--startdato 2026-03-16 --uke 12`.
- Seed-data for gruppetimer begrenses til `2026-03-16` til `2026-03-18`, i tråd med hovedoppgaven.
- Output for UC4 skal derfor vise alle registrerte treninger i uke 12 som finnes i databasen, som i praksis blir treningene 16.-18. mars 2026.

Denne tolkningen drifter minst fra spesifikasjonen fordi den bevarer både uke-parameteren og tre-dagerskravet, og unngår å legge `2026-03-23` feilaktig inn i uke 12.

### E-post som brukernavn

Anbefalt tolkning:

- «Brukernavn» i brukstilfellene betyr e-post.
- `bruker.epost` er derfor kanonisk offentlig identifikator.
- Alle Python-wrappere skal ta `--epost`.
- SQL skal slå opp internt `bruker.id` fra e-post, aldri omvendt.

### Hva som menes med «hvilken trening»

Anbefalt tolkning:

- Offentlig identifikasjon av en trening skjer ved `aktivitet + starttidspunkt`.
- SQL må kreve at denne kombinasjonen matcher nøyaktig én `gruppetime`.
- Hvis matchen er `0` eller `>1`, skal wrapperen feile eksplisitt med lesbar melding.
- `gruppetime.id` brukes bare internt i SQL og i koblingstabeller.

Dette holder seg nær spesifikasjonen fordi brukeren fortsatt oppgir reell trening, ikke intern nøkkel.

### Utestenging etter tre prikker

Anbefalt tolkning:

- Svartelisting utløses når brukeren har minst tre `prikk_dato` i intervallet `referansetid - 30 dager` til `referansetid`.
- Sperrefristen settes til første prikkdato pluss 31 dager ved midnatt, slik at første prikk faktisk er eldre enn 30 hele dager før bookinger åpnes igjen.
- Eksempel: første relevante prikk `2026-03-16` gir `utestengt_til = 2026-04-16 00:00:00`.

## Seed-data som er tilstrekkelig for alle 8 brukstilfeller

### Domeneobjekter som må finnes

Minimumssett:

- 5 sentre som referansedata: Øya, Gløshaugen, Dragvoll, Moholt og DMMH.
- Saler for Øya og Dragvoll som faktisk brukes av spinningtimene.
- Fasiliteter for Øya.
- Minst 1 spinningsal på Øya og 1 på Dragvoll.
- Minst 4 nummererte spinningsykler på Øya.
- Minst 1 nummerert tredemølle på Øya for å dekke den eksplisitte domeneteksten.
- Minst 4 brukere: Johnny, Kari, Ola og Emma.
- Minst 2 instruktører.
- Aktivitetstyper som dekker den konkrete demoen: `Spin45`, `Spin60` og `Spinning Intervall`.

### Konkret treningsplan som skal seedes

Alle gruppetimer skal ligge i perioden `2026-03-16` til `2026-03-18` og bare være spinning på Øya eller Dragvoll.

| ID-navn i planen | Start | Slutt | Senter | Aktivitet |
| --- | --- | --- | --- | --- |
| GT1 | `2026-03-16 17:30:00` | `2026-03-16 18:15:00` | Øya | `Spin45` |
| GT2 | `2026-03-16 19:30:00` | `2026-03-16 20:30:00` | Dragvoll | `Spin60` |
| GT3 | `2026-03-17 07:30:00` | `2026-03-17 08:15:00` | Dragvoll | `Spin45` |
| GT4 | `2026-03-17 18:30:00` | `2026-03-17 19:30:00` | Øya | `Spin60` |
| GT5 | `2026-03-18 17:30:00` | `2026-03-18 18:15:00` | Øya | `Spin45` |
| GT6 | `2026-03-18 19:30:00` | `2026-03-18 20:30:00` | Dragvoll | `Spinning Intervall` |

### Deltakelses- og prikkplan

Dette seedes før brukstilfellene kjøres:

- Johnny er ikke booket på GT4 ved init, slik at UC2 faktisk oppretter bookingen.
- Johnny har `oppmøtt_tidspunkt` på GT5, slik at UC5 får minst én historikkrad allerede før UC3.
- Johnny har tre eksisterende prikker på GT1, GT3 og GT6 med datoene `2026-03-16`, `2026-03-17` og `2026-03-18`.
- Kari og Ola har begge registrert oppmøte på GT2, GT4 og GT5.
- Emma har registrert oppmøte på GT2 og GT5.

Dette oppnår:

- UC2: GT4 er ledig og bookbar for Johnny.
- UC3: GT4 kan få oppmøte registrert etter bookingen.
- UC5: Johnny får unik historikk siden `2026-01-01`.
- UC6: Johnny kan svartelistes på grunnlag av tre prikker siste 30 dager.
- UC7: Kari og Ola blir delt førsteplass i mars.
- UC8: Kari og Ola trener sammen tre ganger.

### Kapasitetsplan

- Salen for GT4 skal ha kapasitet `4`.
- Ved init skal GT4 ha nøyaktig `3` aktive bookinger før Johnny booker.
- UC2 skal derfor demonstrere både at timen finnes og at kapasitetskontrollen tillater siste ledige plass.

### Data som ikke skal være del av kjerneplanen

- Venteliste seedes ikke i første implementasjonsbølge.
- Idrettslag og gruppereservasjoner holdes utenfor kjerne-demoen for DB2, siden de ikke inngår i brukstilfelle 1-8.
- Ekstra treninger utenfor `2026-03-16` til `2026-03-18` skal ikke legges inn i standard seed.

Denne avgrensningen er bevisst. Den holder datasettet lite og helt i tråd med den eksplisitte tre-dagersbestillingen, samtidig som alle 8 brukstilfeller fortsatt blir bevisbare.

## SQL/Python-grense

### Logikk som skal ligge i SQL

- Oppslag av bruker fra e-post.
- Oppslag av trening fra `aktivitet + starttidspunkt`.
- Sjekk av at trening finnes.
- Sjekk av at trening ikke er full.
- Sjekk av at bruker ikke allerede er påmeldt.
- Sjekk av at bruker ikke er utestengt på referansetidspunktet.
- Beregning av om bookingen skjer tidligst 48 timer før timen er publisert.
- Sjekk av oppmøte innen 5-minuttersgrensen.
- Telling av prikker siste 30 dager.
- Beregning av `utestengt_til`.
- Global sortering av ukeplanen.
- Deduplisering i historikkspørringen.
- Rangering og håndtering av delt førsteplass i UC7.
- Selv-join for «trener sammen» i UC8.

### Logikk som skal ligge i tynne Python-wrappere

- Parse CLI-parametere.
- Åpne SQLite-forbindelse med `sqlite3`.
- Starte og avslutte transaksjon.
- Binde parametere til SQL.
- Oversette SQL-resultater til korte, lesbare meldinger.
- Skrive identisk output til terminal og `resultat_*.txt`.
- Kjøre standardsekvensen i `92_reproduser_alt.py`.

Hva Python ikke skal gjøre:

- Ingen filtrering av resultatrader i løkker.
- Ingen telling av prikker i Python.
- Ingen sortering av ukeplan i Python.
- Ingen topplister eller samtreningsanalyse i Python.

## Implementeringssplit for neste bølge

### Agent 1: Grunnmur

Ansvar:

- `10_schema.sql`
- `11_seed_data.sql`
- `90_db.py`
- `91_init_db.py`
- oppdatering av tom `trening.db`

Må levere:

- påkrevde skjemaendringer
- init som alltid bygger samme basistilstand
- seed-data som matcher denne planen nøyaktig

Grensesnitt mot de andre:

- publiserer ferdig kolonnenavn og seedede forretningsnøkler
- endrer ikke usecase-filnavn

### Agent 2: Mutasjoner

Ansvar:

- `20_uc2_book_gruppetime.sql`
- `20_uc2_book_gruppetime.py`
- `30_uc3_registrer_oppmote.sql`
- `30_uc3_registrer_oppmote.py`
- `60_uc6_svartelisting.sql`
- `60_uc6_svartelisting.py`

Må levere:

- all muterende logikk i SQL
- tynne Python-wrappere med samme parameterstil
- tydelige feilmeldinger for `ingen match`, `flere matcher`, `full time`, `allerede booket`, `for sent`, `for tidlig`, `ikke nok prikker`

Avhengigheter:

- trenger ferdige skjemaendringer fra Agent 1
- skal ikke endre rapporteringsfilene

### Agent 3: Rapportering

Ansvar:

- `40_uc4_ukeplan.sql`
- `40_uc4_ukeplan.py`
- `50_uc5_besokshistorikk.sql`
- `70_uc7_maanedsvinner.sql`
- `70_uc7_maanedsvinner.py`
- `80_uc8_trener_sammen.sql`

Må levere:

- SQL-first lesespørringer
- stabil kolonnerekkefølge i output
- korrekt global sortering og korrekt håndtering av likt antall i UC7

Avhengigheter:

- bruker seed og skjema fra Agent 1
- bruker eventuelt hjelpekode fra `90_db.py`, men eier ikke den filen

### Agent 4: Pakking og verifikasjon

Ansvar:

- `00_README.md`
- `01_KI-erklaering.md`
- `92_reproduser_alt.py`
- alle `resultat_*.txt`
- sluttkontroll av flat leveransemappe

Må levere:

- kjørbar oppskrift fra tom database
- resultatfiler som faktisk regenereres fra samme kode
- zip-klar struktur uten repoavhengige stier

Avhengigheter:

- skal ikke endre SQL-logikken, bare orkestrere og kontrollere den

## Frys for neste bølge

Følgende er låst og skal ikke diskuteres på nytt i kodebølgen:

- flat sluttmappe med filnavnene over
- e-post er brukernavn
- UC4 bruker ISO-uke 12 med start `2026-03-16`
- `2026-03-23` behandles som uke 13 og ikke som del av UC4
- `gruppetime.starttidspunkt` og `gruppetime.sluttidspunkt` blir sannhetskilde
- `deltar_på_time.oppmøtt_tidspunkt` brukes som bevis på faktisk deltakelse
- seed-data holdes til spinning på Øya og Dragvoll i perioden `2026-03-16` til `2026-03-18`

Dette er den minste planen som fortsatt er robust nok til å gi en byggbar DB2-leveranse med lav rubrikkrisiko.
