# Pakkerevisjon for del 2

## Formål

Målet er å ende med **én enkel leveransemappe** som sensor kan pakke ut og kjøre fra toppen av mappen uten å lete i repoet. Dette notatet foreslår bare sluttformen for DB2-leveransen. Det innfører ikke mappen nå.

Følgende kilder er lagt til grunn:

- `resources/norwegian/project-description.md`
- `resources/norwegian/project-deliverables.md`
- `sql/schema.sql`
- nåværende repo-struktur

## Designprinsipper

- Leveransen bør være **flat**, ikke spredd over mange undermapper.
- SQL skal være synlig som egne filer, siden emnet eksplisitt favoriserer SQL framfor Python.
- Python skal hovedsakelig være et tynt lag for parameterhåndtering, kjøring og utskrift.
- Sensor skal kunne starte med en **tom SQLite-fil** og reprodusere resultatene med et kort, dokumentert kommandooppsett.
- Alt som bare er arbeidsmateriale for DB1 eller rapportproduksjon bør holdes **utenfor** den endelige DB2-mappen.

## Anbefalt endelig leveransemappe

Anbefalt mappenavn:

`TreningDB_DB2/`

Eksakt foreslått struktur:

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

## Hvorfor denne strukturen er riktig

Den flate strukturen er den minst krevende for sensor:

- alle filer ligger i samme mappe
- filnavnene sorterer i naturlig kjørerekkefølge
- det er lett å se hvilke usecaser som har både SQL og Python
- resultatfilene er synlige uten ekstra navigasjon

Dette er også tett på oppgaveteksten:

- `10_schema.sql` dekker databaseskjema
- `11_seed_data.sql` dekker usecase 1 og all initialdata som kreves for resten
- usecase 2, 3, 4, 6 og 7 finnes både som SQL og Python
- usecase 5 og 8 finnes som rene SQL-filer, slik oppgaven tillater
- `trening.db` leveres tom
- tekstlige output-filer leveres ferdig
- `00_README.md` fungerer som den konkrete oppskriften sensor trenger

## Fil for fil

### Dokumentasjon

`00_README.md`

Formål: hovedoppskrift for sensor.

Hvorfor nødvendig: oppgaveteksten krever at sensor skal kunne kjøre leveransen uten å streve. Denne filen må inneholde krav til Python-versjon, at kun standardbiblioteket brukes, eksakt kommandorekkefølge og hvilke filer som blir generert eller overskrevet.

`01_KI-erklaering.md`

Formål: egen erklæring om bruk av KI i del 2.

Hvorfor nødvendig: KI-erklæring gir egne poeng i vurderingen. Den bør derfor ikke gjemmes i en større rapport eller blandes inn i README.

### Databasegrunnlag

`10_schema.sql`

Formål: oppretter hele SQLite-skjemaet.

Hvorfor nødvendig: dette er grunnlaget for all sensur og må kunne kjøres direkte mot den tomme databasen. I sluttmappen bør denne være den autoritative skjema-filen, selv om utviklingsrepoet fortsatt kan ha `sql/schema.sql`.

`11_seed_data.sql`

Formål: setter inn alle data som skal finnes før usecasene kjøres.

Hvorfor nødvendig: oppgaven krever at sensor kan gjenskape databasen slik den er før usecasene kjøres. Denne filen må derfor inneholde sentre, saler, sykler på Øya, brukere, instruktører, aktivitetstyper, treninger, historikkdata for Johnny, prikker og data som gjør at usecase 7 og 8 faktisk demonstrerer noe.

`trening.db`

Formål: tom SQLite-database som leveres sammen med script og kode.

Hvorfor nødvendig: dette er eksplisitt påkrevd i DB2-kravene. Filen skal være tom i levert zip, ikke en ferdig utfylt database.

### Felles Python-støtte

`90_db.py`

Formål: minimal felleskode for SQLite-tilkobling, lasting av SQL fra fil, transaksjonshåndtering og konsistent utskrift til skjerm og resultatfil.

Hvorfor nødvendig: hindrer at samme boilerplate kopieres i alle Python-filene. Det gir mindre risiko for at usecasene oppfører seg ulikt under sensur.

`91_init_db.py`

Formål: initialiserer `trening.db` på nytt fra `10_schema.sql` og `11_seed_data.sql`.

Hvorfor nødvendig: sensor trenger én entydig startkommando fra tom database til et konsistent utgangspunkt. Denne filen er reproduksjonsankeret i leveransen.

`92_reproduser_alt.py`

Formål: kjører anbefalt sensursekvens fra start til slutt og skriver alle resultatfilene på nytt.

Hvorfor nødvendig: dette er den enkleste måten å oppfylle kravet om reproduserbarhet. Sensor kan fortsatt kjøre usecasene enkeltvis, men skal ikke være avhengig av manuell plukking av kommandoer.

### Usecase-filer

`20_uc2_book_gruppetime.sql`

Formål: SQL for selve bookingen med nødvendige valideringer som kan ligge i SQL-laget.

Hvorfor nødvendig: usecase 2 skal leveres som SQL og Python. SQL-filen gjør det synlig hva databasen faktisk gjør.

`20_uc2_book_gruppetime.py`

Formål: mottar parametere for e-post, aktivitet og tidspunkt, kaller SQL-laget og skriver bekreftelse eller feilmelding.

Hvorfor nødvendig: usecase 2 skal også leveres i Python, og parameteriseringen skal være enkel å teste for sensor.

`30_uc3_registrer_oppmote.sql`

Formål: SQL for registrering av oppmøte på en bestemt trening for en bestemt bruker.

Hvorfor nødvendig: usecase 3 skal leveres som SQL og Python.

`30_uc3_registrer_oppmote.py`

Formål: parameterisert kjøring av usecase 3.

Hvorfor nødvendig: gir sensor samme enkle kjøremønster som for usecase 2.

`40_uc4_ukeplan.sql`

Formål: SQL-spørringen som henter ukeplanen sortert på tid på tvers av sentre.

Hvorfor nødvendig: usecase 4 skal leveres som SQL og Python, og dette er et sentralt vurderingspunkt for korrekt sortering og riktig uttrekk.

`40_uc4_ukeplan.py`

Formål: tar inn startdato og ukeparameter, kjører SQL og skriver både til terminal og resultatfil.

Hvorfor nødvendig: oppgaveteksten ber om Python og SQL, og resultatet skal være lett å reprodusere.

`50_uc5_besokshistorikk.sql`

Formål: SQL som henter Johnnys unike besøkshistorie siden 1. januar 2026.

Hvorfor nødvendig: usecase 5 kan leveres i SQL alene, og resultatet må kunne produseres direkte fra databasen.

`60_uc6_svartelisting.sql`

Formål: SQL-delen som finner relevant bruker, teller prikker i siste 30 dager og utfører oppdateringen når kriteriet er oppfylt.

Hvorfor nødvendig: usecase 6 skal leveres som SQL og Python, og logikken bør være mest mulig synlig i SQL.

`60_uc6_svartelisting.py`

Formål: parameterisert kjøring av svartelisting med tydelig tilbakemelding.

Hvorfor nødvendig: usecase 6 skal også ha Python-del, og sensor må kunne teste både positiv og negativ bane uten manuell SQL-redigering.

`70_uc7_maanedsvinner.sql`

Formål: SQL som finner personen eller personene med flest deltakelser i en gitt måned.

Hvorfor nødvendig: usecase 7 skal leveres som SQL og Python, og SQL-filen viser tydelig hvordan delt førsteplass håndteres.

`70_uc7_maanedsvinner.py`

Formål: tar inn måned som parameter, kjører SQL og skriver resultat.

Hvorfor nødvendig: gjør usecase 7 enkel å demonstrere uten SQLite-CLI eller manuell parameterbinding.

`80_uc8_trener_sammen.sql`

Formål: SQL som finner to studenter som trener sammen, med e-post, e-post og antall felles treninger.

Hvorfor nødvendig: usecase 8 kan leveres i SQL alene, og oppgaven ber eksplisitt om et SQL-forslag som kan demonstreres på dataene.

### Resultatfiler

`resultat_uc2_booking.txt`

Formål: lagret eksempeloutput fra booking-kjøringen.

Hvorfor nødvendig: ikke strengt påkrevd av ordlyden om spørringsoutput alene, men sterkt anbefalt fordi det dokumenterer at muterende usecaser faktisk er testet og gir forventet respons.

`resultat_uc3_oppmote.txt`

Formål: lagret eksempeloutput fra oppmøteregistrering.

Hvorfor nødvendig: samme begrunnelse som for usecase 2.

`resultat_uc4_ukeplan.txt`

Formål: tekstlig output for ukeplanspørringen.

Hvorfor nødvendig: dette er eksplisitt en del av leveransekravet om tekstlige resultater.

`resultat_uc5_besokshistorikk.txt`

Formål: tekstlig output for personlig besøkshistorie.

Hvorfor nødvendig: eksplisitt del av leveransekravet.

`resultat_uc6_svartelisting.txt`

Formål: lagret eksempeloutput som viser at svartelistingen ble vurdert og eventuelt aktivert.

Hvorfor nødvendig: gjør tilstandsendringen sporbar ved sensur og reduserer tvil om usecasen faktisk er testet.

`resultat_uc7_maanedsvinner.txt`

Formål: tekstlig output for månedsvinner-spørringen.

Hvorfor nødvendig: eksplisitt del av leveransekravet.

`resultat_uc8_trener_sammen.txt`

Formål: tekstlig output for "trener sammen"-spørringen.

Hvorfor nødvendig: eksplisitt del av leveransekravet.

## Hva som bør beholdes, erstattes eller pekes til

### Bør beholdes i utviklingsrepoet, men ikke legges i sluttmappen

- `sql/schema.sql`: beholdes som utviklingsfil og nåværende kilde, men kopieres eller fryses som `10_schema.sql` i leveransemappen.
- `resources/norwegian/project-description.md` og `resources/norwegian/project-deliverables.md`: beholdes som referanser i repoet, men skal ikke inn i DB2-mappen.
- `relational-schema.md`, `assumptions.md`, `archive/`, `hal/` og ER-diagrammene: nyttige for gruppen, men ikke nødvendige for sensor i DB2-zipen.

### Bør erstattes i del 2-leveransen

- `delivery/Template_Project_NTNU/`: denne strukturen er laget for rapportproduksjon og er for tung for en enkel, kjørbar DB2-zip.
- `delivery/contents/*.md`: disse ser ut til å høre hjemme i rapportarbeid for del 1 og bør ikke være den primære dokumentasjonen i DB2-mappen.

Anbefaling: i stedet for å pakke med hele LaTeX-oppsettet i DB2-leveransen, bruk `00_README.md` og `01_KI-erklaering.md` som de operative dokumentene i sluttmappen. Hvis gruppen også vil levere en PDF-rapport, bør den bygges separat og ikke være en forutsetning for at sensor kan kjøre databasedelen.

### Bør omtales eksplisitt i README

- at leveransen bruker `sqlite3` fra Pythons standardbibliotek
- at alle kommandoer skal kjøres fra toppen av `TreningDB_DB2/`
- at `trening.db` forventes å være tom før `91_init_db.py`
- at `92_reproduser_alt.py` overskriver eksisterende resultatfiler

## Anbefalt gradersekvens

Dette er den sekvensen jeg anbefaler at README dokumenterer som den primære:

1. Pakk ut zip-filen og gå til `TreningDB_DB2/`.
2. Verifiser at `trening.db` er tom eller slett den og opprett en ny tom fil med samme navn.
3. Kjør `python3 91_init_db.py`.
4. Kjør `python3 92_reproduser_alt.py`.
5. Kontroller resultatfilene `resultat_uc2_booking.txt` til `resultat_uc8_trener_sammen.txt`.

Dette bør `92_reproduser_alt.py` gjøre i denne rekkefølgen:

1. Kjør usecase 2 for `johnny@stud.ntnu.no`, aktivitet `Spin60`, tidspunkt `2026-03-17 18:30`.
2. Kjør usecase 3 for samme bruker og trening.
3. Kjør usecase 4 med startdato `2026-03-16` og uke `12`.
4. Kjør usecase 5 for `johnny@stud.ntnu.no` siden `2026-01-01`.
5. Kjør usecase 6 for `johnny@stud.ntnu.no`.
6. Kjør usecase 7 for den måneden som seed-dataene demonstrerer best, anbefalt `2026-03`.
7. Kjør usecase 8 og skriv parene som trener sammen.

## Viktig presisering om datoer

README bør være helt eksplisitt om datointervallene:

- tre-dagers datasettet skal dekke `2026-03-16`, `2026-03-17` og `2026-03-18`
- usecase 5 skal bruke historikk siden `2026-01-01`
- usecase 4 må dokumentere hvordan dere tolker "uke 12"

Det er en liten uklarhet i oppgaveteksten: uke 12 i 2026 er mandag `2026-03-16` til søndag `2026-03-22`, mens teksten også nevner "fra 16. mars til 23. mars". Den tryggeste løsningen er å dokumentere at spørringen bruker intervallet `2026-03-16 00:00:00` til før `2026-03-23 00:00:00`, slik at både ukeparameteren og den skrevne datoavgrensningen håndteres uten tvetydighet.

## Konklusjon

Den anbefalte sluttformen for DB2 er en **flat, kjørbar leveransemappe** med:

- én tom SQLite-fil
- ett skjema-script
- ett seed-script
- tydelige SQL-filer per usecase
- tynne Python-wrappere der oppgaven krever Python
- én init-fil
- én helkjøringsfil
- ferdige resultatfiler
- en kort README og en separat KI-erklæring

Dette er enklere for sensor enn å levere dagens repo-struktur eller en tung LaTeX-mappe, og det treffer direkte på vurderingspunktene for SQL, Python, reproduserbarhet og output.
