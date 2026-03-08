# TDT4145 – Del 1: ER-modell, relasjonsskjema og SQL for SiT Trening

## Innledning
Denne rapporten modellerer en database for **SiT Trening i Trondheim** med fokus på booking av gruppetimer, registrering av oppmøte, prikksystem, sportslagsreservasjoner og grunnleggende statistikkgrunnlag. Løsningen er laget for å være faglig sterk innenfor rammene til et 2.-års emne i databaser: presis, normalisert og tydelig, uten unødvendig kompleksitet.

Modellen er forankret i oppgaveteksten, offentlig informasjon fra SiT sine nettsider og prinsippene i *Database System Concepts (7th edition)*, særlig om:
- entiteter og relasjoner
- kardinalitet og deltakelseskrav
- sterke og svake entiteter
- mange-til-mange-relasjoner med attributter
- oversetting fra ER-modell til relasjonsskjema
- BCNF/3NF
- hvilke regler som må håndteres i programlogikk eller triggere, ikke bare i schema

---

## 1. Kritikk av nåværende ER-diagram
Utgangspunktet i `SitTrening_nikolai_endring.png` har flere gode ideer, men det vil etter min vurdering koste poeng i nåværende form.

### 1.1 Det som er bra
- Diagrammet dekker mange relevante domeneobjekter: senter, sal, gruppetime, bruker, instruktør, sykkel, tredemølle og idrettslag.
- Det forsøker å bruke EER-begreper som spesialisering og svake entiteter.
- Det prøver å fange forretningsregler som oppmøte, prikker og reservasjoner.

### 1.2 Hovedproblemer

#### a) Uklare nøkler
Flere entiteter har uklare eller urealistiske primærnøkler:
- Er `rom_nr` unikt globalt eller bare innenfor et senter?
- Er sykkelnummer unikt i hele databasen, eller bare innenfor en spinningsal?
- Er tredemøllenummer unikt globalt?

Når dette ikke er tydelig, blir også fremmednøkler og identifiserende relasjoner uklare.

#### b) For mye svak entitet-tenkning
`medlemskap`, `sal` og delvis også andre deler av modellen ser ut til å være tvunget inn som svake entiteter uten at det gir en klar gevinst. Oppgaven krever ikke at vi modellerer alt som avhengige objekter. Dette gjør modellen vanskeligere å lese enn nødvendig.

#### c) Overkomplisert spesialisering av sal
Oppdelingen i `spinningsal`, `løpesal` og `flerbrukshall` er ikke i seg selv feil, men den er ikke strengt nødvendig for å løse oppgaven. Det viktigste er å vite:
- hvilket senter rommet tilhører
- kapasitet
- hva slags rom det er
- hvilket utstyr som finnes i rommet

Når spesialiseringen ikke brukes til å håndheve klare, forskjellige regler, blir den mer støy enn verdi.

#### d) Mange-til-mange-relasjoner med attributter er ikke ryddig løst
`deltar` og sportslagsreservasjonene har egne attributter, men er ikke modellert på den mest ryddige måten. Etter læreboka bør slike relasjoner normalt oversettes til egne assosiative relasjoner/tabeller.

#### e) Tidsmodellene er uklare
Diagrammet blander dato, tidspunkt, uke og reservasjonstid på en måte som gjør det vanskelig å håndtere:
- åpningstider
- bemanningstider
- konkrete gruppetimer
- ukentlige sportslagsreservasjoner

Disse bør skilles tydeligere.

#### f) Manglende eller uklare kardinaliteter
Det er flere steder uklart om deltakelse er obligatorisk eller valgfri, og om relasjoner er 1:N eller M:N. Dette svekker den faglige presisjonen.

### 1.3 Konklusjon på kritikken
Det nåværende diagrammet prøver å modellere mye, men er for komplekst på feil steder og for uklart på viktige steder. En bedre løsning er å:
- bruke færre, tydeligere entiteter
- la mange-til-mange-relasjoner med egne attributter bli egne tabeller
- unngå unødvendige svake entiteter og spesialiseringer
- skille tydelig mellom **konkrete treninger**, **ukentlige reservasjoner**, **oppmøte/bookinger** og **utstyr i rom**

---

## 2. Foreslått ER-modell (del a)
Den foreslåtte modellen er vist i Mermaid-diagrammet i `03-foreslaatt-er-mermaid.md`.

### 2.1 Designvalg
Jeg modellerer løsningen rundt følgende hovedobjekter:
- **Treningssenter**
- **Åpningstid**
- **Bemanningstid**
- **Fasilitet**
- **Sal**
- **Sykkel**
- **Tredemølle**
- **Aktivitetstype**
- **Instruktør**
- **Bruker**
- **Gruppetime**
- **Booking**
- **Prikk**
- **Idrettslag**
- **Idrettslagsgruppe**
- **Sportslagsmedlemskap**
- **Sportslagsreservasjon**

### 2.2 Hvorfor denne modellen er bedre
Den er bedre fordi den følger de viktigste modellprinsippene i boka:
- hver tabell representerer én tydelig type ting
- relasjoner med egne attributter blir egne tabeller
- nøkler er tydelige
- regler som ikke kan uttrykkes naturlig i modellen, dokumenteres eksplisitt som applikasjonslogikk eller triggerlogikk

### 2.3 Viktige forretningsregler i modellen
Modellen støtter disse reglene:
- Et treningssenter har flere saler.
- En sal tilhører nøyaktig ett treningssenter.
- En gruppetime holdes i én sal, har én aktivitetstype og én instruktør.
- En booking kobler én bruker til én gruppetime.
- En booking kan være bekreftet, venteliste, avbestilt eller registrert som oppmøtt / no-show.
- En bruker kan få prikker for manglende oppmøte.
- Sportslagsgrupper kan reservere saler i faste ukentlige tidsrom.
- Brukere kan ha medlemskap i sportslagsgrupper.

### 2.4 Antakelser
For å holde modellen presis og realistisk har jeg brukt disse antakelsene:
1. `room_name` er bare unikt innenfor ett senter, ikke globalt.
2. Sykkelnummer og tredemøllenummer er bare unike innenfor ett rom.
3. Oppgaven sier at instruktør bare vises med fornavn; derfor lagres kun fornavn som et minimumskrav. I praksis kunne en intern person-ID vært brukt.
4. Svartelisting lagres **ikke** som et permanent hovedfaktum i modellen, men utledes fra prikker. Dette reduserer risiko for inkonsistens.
5. Jeg modellerer venteliste gjennom bookingstatus i stedet for en egen venteliste-entitet. Dette er tilstrekkelig for oppgaven.
6. Jeg modellerer ikke generelle selvtreningsbesøk som egne besøksposter, fordi alle eksplisitte use cases i oppgaven gjelder gruppetimer og oppmøte på disse.

### 2.5 Restriksjoner som ikke uttrykkes fullt i ER-modellen
Følgende regler må håndteres i programvare eller triggere:
- en instruktør kan ikke være på to steder samtidig
- en bruker kan ikke være påmeldt to overlappende timer samtidig
- en booking må nektes hvis brukeren har tre prikker siste 30 dager
- antall bekreftede bookinger kan ikke overstige kapasiteten i salen
- avbestilling må skje senest én time før start
- oppmøte må registreres senest fem minutter før start for å telle som møtt

---

## 3. Relasjonsskjema og normalformer (del b)
Under er den foreslåtte relasjonsmodellen. Full SQL finnes i `04-schema.sql`.

### 3.1 Relasjoner

#### training_center
`training_center(center_id, name, street_address)`

**Nøkler:**
- PK: `center_id`
- UNIQUE: `name`

**Normalform:** BCNF.
Alle ikke-trivielle avhengigheter går fra kandidatnøkkel til resten av attributtene.

#### center_opening_hours
`center_opening_hours(center_id, weekday, opens_at, closes_at)`

**Nøkler:**
- PK: `(center_id, weekday, opens_at)`
- FK: `center_id -> training_center`

**Normalform:** BCNF.
En rad beskriver ett konkret åpningsintervall for ett senter på én ukedag.

#### center_staffing_hours
`center_staffing_hours(center_id, weekday, staffed_from, staffed_to)`

**Nøkler:**
- PK: `(center_id, weekday, staffed_from)`
- FK: `center_id -> training_center`

**Normalform:** BCNF.
Samme begrunnelse som over.

#### facility
`facility(facility_id, name, description)`

**Nøkler:**
- PK: `facility_id`
- UNIQUE: `name`

**Normalform:** BCNF.

#### center_facility
`center_facility(center_id, facility_id)`

**Nøkler:**
- PK: `(center_id, facility_id)`
- FK: `center_id -> training_center`
- FK: `facility_id -> facility`

**Normalform:** BCNF.
Ren koblingstabell uten ekstra attributter.

#### room
`room(room_id, center_id, room_name, room_type, capacity)`

**Nøkler:**
- PK: `room_id`
- FK: `center_id -> training_center`
- UNIQUE: `(center_id, room_name)`

**Normalform:** BCNF.
`room_id` bestemmer alle andre attributter. `room_type` er brukt i stedet for egen subtype-modell fordi det gjør løsningen enklere og tydeligere uten å miste kravdekning.

#### spinning_bike
`spinning_bike(room_id, bike_no, bike_model, has_bodybike_bluetooth)`

**Nøkler:**
- PK: `(room_id, bike_no)`
- FK: `room_id -> room`

**Normalform:** BCNF.
Sykkelnummer er bare unikt innenfor rommet, derfor komposittnøkkel.

#### treadmill
`treadmill(room_id, treadmill_no, manufacturer, max_speed_kmh, max_incline_pct)`

**Nøkler:**
- PK: `(room_id, treadmill_no)`
- FK: `room_id -> room`

**Normalform:** BCNF.
Samme begrunnelse som for sykkel.

#### activity_type
`activity_type(activity_type_id, name, category, description)`

**Nøkler:**
- PK: `activity_type_id`
- UNIQUE: `name`

**Normalform:** BCNF.

#### instructor
`instructor(instructor_id, first_name)`

**Nøkler:**
- PK: `instructor_id`

**Normalform:** BCNF.
Oppgaven krever bare at instruktør vises med fornavn. Hvis systemet senere trenger mer informasjon, kan tabellen utvides.

#### app_user
`app_user(user_id, full_name, email, mobile)`

**Nøkler:**
- PK: `user_id`
- UNIQUE: `email`
- UNIQUE: `mobile`

**Normalform:** BCNF.

#### group_class
`group_class(session_id, activity_type_id, room_id, instructor_id, starts_at, ends_at, published_at)`

**Nøkler:**
- PK: `session_id`
- FK: `activity_type_id -> activity_type`
- FK: `room_id -> room`
- FK: `instructor_id -> instructor`
- UNIQUE: `(room_id, starts_at)`

**Normalform:** BCNF.
`session_id` bestemmer resten. Maks antall deltakere per økt utledes fra `room.capacity`, i tråd med oppgaveteksten.

#### booking
`booking(user_id, session_id, booked_at, canceled_at, check_in_at, booking_status, waitlist_position)`

**Nøkler:**
- PK: `(user_id, session_id)`
- FK: `user_id -> app_user`
- FK: `session_id -> group_class`

**Normalform:** BCNF.
Dette er en klassisk assosiativ relasjon mellom bruker og gruppetime med egne attributter. Den må derfor være egen tabell.

#### penalty_dot
`penalty_dot(dot_id, user_id, session_id, awarded_at, reason)`

**Nøkler:**
- PK: `dot_id`
- FK: `user_id -> app_user`
- FK: `session_id -> group_class`
- UNIQUE: `(user_id, session_id)`

**Normalform:** BCNF.
Hver prikk representerer én konkret sanksjon knyttet til én bruker og én gruppetime.

#### sports_team
`sports_team(team_id, name)`

**Nøkler:**
- PK: `team_id`
- UNIQUE: `name`

**Normalform:** BCNF.

#### sports_team_group
`sports_team_group(group_id, team_id, name)`

**Nøkler:**
- PK: `group_id`
- FK: `team_id -> sports_team`
- UNIQUE: `(team_id, name)`

**Normalform:** BCNF.
En gruppe tilhører ett idrettslag.

#### sports_team_membership
`sports_team_membership(user_id, group_id, valid_from, valid_to)`

**Nøkler:**
- PK: `(user_id, group_id, valid_from)`
- FK: `user_id -> app_user`
- FK: `group_id -> sports_team_group`

**Normalform:** BCNF.
Denne tabellen gjør det mulig å ha historikk i medlemskap over tid.

#### sports_team_reservation
`sports_team_reservation(group_id, room_id, weekday, starts_at, ends_at)`

**Nøkler:**
- PK: `(group_id, room_id, weekday, starts_at)`
- FK: `group_id -> sports_team_group`
- FK: `room_id -> room`

**Normalform:** BCNF.
Representerer faste ukentlige reservasjoner.

### 3.2 Kommentar om normalformer
Hele modellen er designet for å ligge i **BCNF** ut fra de funksjonelle avhengighetene i denne domeneavgrensningen.

---

## 4. SQL-script og restriksjoner (del c)
Full opprettelse av databasen leveres i `04-schema.sql`.

### 4.1 Restriksjoner som uttrykkes direkte i SQL
Følgende er uttrykt direkte i schemaet:
- primærnøkler
- fremmednøkler
- `UNIQUE`
- `NOT NULL`
- `CHECK` for enkle domener, gyldige statusverdier og tidsformat
- regel om at `published_at` skal være nøyaktig 48 timer før `starts_at`
- sammensatte nøkler der identifikasjon er lokal, f.eks. sykkelnummer i et rom

### 4.2 Restriksjoner som ikke uttrykkes fullt i schemaet
Noen regler er vanskelig å uttrykke kun med standard relasjonsmodell og enkel SQLite-DDL:
- ingen overlappende timer for samme instruktør
- ingen overlappende bookinger for samme bruker
- ingen overbooking av salens kapasitet
- svartelisting etter 3 prikker siste 30 dager
- avbestilling senest én time før start
- oppmøte senest fem minutter før start
- sportslagsreservasjon kan ikke kollidere med gruppetime eller annen reservasjon i samme sal

Disse bør løses i:
- programlogikk
- eller SQLite-triggere dersom man ønsker mer databasebasert håndheving

Dette er i tråd med læreboka: ikke alle forretningsregler er naturlige å modellere som nøkler og fremmednøkler alene.

---

## 5. Svar på spørsmålene i del d

### d1. Hvordan kan vi sikre at en instruktør ikke er to steder samtidig?
Dette kan **ikke** løses fullt ut bare gjennom ER-modellen eller vanlige nøkler/fremmednøkler. Problemet er et **tidsintervall-overlapp**.

ER-modellen kan vise at en instruktør er koblet til mange gruppetimer, men den kan ikke alene uttrykke regelen «to økter for samme instruktør kan ikke overlappe i tid».

Dette bør derfor håndteres i:
- programlogikk ved innsending av ny gruppetime
- eller i en database-trigger som avviser innsetting/oppdatering ved overlapp

**Konklusjon:** Må håndteres i programvare eller triggerlogikk, ikke bare i selve modellen.

### d2. Samme spørsmål for en bruker
Dette er samme type problem som for instruktør: en bruker skal ikke kunne være påmeldt to overlappende gruppetimer samtidig.

Heller ikke dette kan uttrykkes tilfredsstillende bare med relasjonsmodellen og standard nøkler. Det krever en sjekk mot andre bookinger for samme bruker og overlapp i tidsintervall.

**Konklusjon:** Må håndteres i programvare eller triggerlogikk.

### d3. Fra hvilket use case blir svartelisting testet / opprettet?
Den naturlige plasseringen er i forbindelse med **registrering av manglende oppmøte**.

Når en booking går fra «confirmed» til «no_show», opprettes en prikk. Etter at prikken er opprettet, sjekker systemet om brukeren nå har minst tre prikker innenfor siste 30 dager.

Selve **testen** bør også kjøres når brukeren forsøker å booke en ny time. Det betyr:
- **oppretting/logisk utløsning:** ved no-show / prikkregistrering
- **håndheving:** ved nytt bookingforsøk

Dette trenger derfor ikke være ett av de oppgitte use casene, men det er mest naturlig knyttet til use case 3 (registrering av oppmøte / manglende oppmøte) og til booking-use caset.

### d4. Må statistikk lagres eksplisitt, eller kan vi bare spørre databasen?
I utgangspunktet bør statistikk **ikke** lagres eksplisitt hvis den kan utledes fra eksisterende data. Dette følger god databasedesign: man bør unngå redundant lagring dersom den samme informasjonen kan beregnes korrekt fra grunnlagsdata.

For denne oppgaven kan de fleste statistikker utledes direkte med spørringer, for eksempel:
- antall påmeldte per økt
- hvor mange som faktisk møtte
- hvilke økter som ble fullbooket
- hvem som trente mest i en måned
- hvor mange som trente sammen

Det eneste som eventuelt kan lagres eksplisitt er **historiske oppsummeringer** dersom systemet blir stort og ytelse blir viktig. Men i denne oppgaven, og særlig i SQLite, er det fullt tilstrekkelig og faglig riktig å beregne statistikk med SQL-spørringer.

**Konklusjon:** Statistikk bør primært utledes med spørringer, ikke lagres eksplisitt, med mindre man senere har et ytelsesbehov.

---

## 6. Oppsummering
Den foreslåtte løsningen er mer presis og enklere enn nåværende ER-diagram, samtidig som den dekker kravene i oppgaven:
- alle sentre, rom, fasiliteter og åpningstider kan modelleres
- gruppetimer, instruktører og brukere er tydelig modellert
- booking, venteliste, oppmøte og prikker er samlet i en ryddig struktur
- sportslagsreservasjoner er skilt fra gruppetimer
- skjemaet er normalisert og egnet for SQLite
- regler som ikke passer naturlig i schema er dokumentert som applikasjonslogikk eller triggerlogikk

Kort sagt: mindre pynt, mer presisjon. Det er akkurat det denne innleveringen trenger.
