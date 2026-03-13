# Spesifikasjonsrevisjon for DB2 del 2

Dette notatet peker på vurderingsfeller og skjulte tapsområder i DB2-del 2, basert på oppgaveteksten, leveransekravene og dagens skjema. Fokus er hva som lett kan koste poeng selv om løsningen "ser riktig ut".

## MÅ oppfylles

### 1. SQL må være hovedmotoren, ikke Python

Sensor sier eksplisitt at SQL foretrekkes framfor Python, og poengfordelingen understreker det: 25 poeng på SQL og 10 poeng på tilhørende Python. Det betyr at Python bør brukes til parameterinnhenting, kjøring av SQL, transaksjonsstyring og utskrift, mens selve datalogikken bør ligge i SQL.

Konsekvens for implementasjonsstil:

- Filtrering, oppslag, validering, tabellkoblinger, aggregering, rangering og svartelistingssjekker bør skje i SQL.
- Python bør ikke hente store datasett og så implementere bookingregler, telling av prikker eller månedsstatistikk i løkker.
- Brukstilfeller som er merket "Python og SQL" bør forstås som Python-kode som kaller tydelig SQL, ikke som to separate logikker der Python gjør mesteparten av jobben.
- Brukstilfeller som er merket "SQL" bør leveres som faktiske SQL-skript eller tydelige SQL-spørringer, ikke bare som SQL-strenger inne i Python.

Skjult poengtap:

- Hvis en gruppe løser for eksempel månedsvinner, ukeplan eller svartelisting hovedsakelig i Python, kan løsningen fungere praktisk men tape tungt på rubricen.

### 2. Reproduserbarhet er et eksplisitt sensorkrav

Leveransen må kunne kjøres av sensor uten manuell rydding. Kravet er strengere enn bare "koden virker hos oss".

Dette innebærer i praksis:

- SQLite-filen som leveres skal være tom.
- Det må finnes init-rekkefølge som bygger skjema og setter inn data fra bunnen av.
- Det må finnes en kjørbar oppskrift som faktisk virker på en ren start.
- Eksempelinput må følge med, slik at sensor kan trigge brukstilfellene uten å gjette parametere.
- Tekstlig output må følge med som leveranse, ikke bare kunne genereres i teorien.

Skjult poengtap:

- Å levere en ferdig utfylt databasefil i stedet for tom fil bryter direkte med teksten.
- Å ha bare ett script som antar eksisterende data, eller krever manuell kjøring i "riktig" rekkefølge uten dokumentasjon, er en reproduksjonsfelle.
- Hvis outputfilene ikke samsvarer med dataene som init-scriptet faktisk lager, vil sensor kunne gjenskape noe annet enn dokumentert resultat.

### 3. Oppstartsdata må være tilstrekkelig til å demonstrere alle krevde brukstilfeller

Oppgaveteksten ber om tre dagers data fra 16. mars til 18. mars og kun spinningaktiviteter på Øya og Dragvoll, men brukstilfellene krever også at det finnes brukere, trenere, deltakelse, prikker og nok historikk til statistikk.

Det betyr at datasettet minst må støtte:

- booking av `Spin60` tirsdag 17. mars kl. 18.30 på Øya,
- registrering av oppmøte for samme time,
- personlig historikk for `johnny@stud.ntnu.no`,
- svartelisting basert på minst tre prikker siste 30 dager,
- månedsstatistikk med minst én vinner og gjerne et scenario med delt førsteplass,
- et SQL-eksempel som viser to studenter som trener sammen.

Skjult poengtap:

- Hvis oppstartsdata bare dekker den tre dagers perioden, men ikke gir tre prikker innen 30 dager eller nok registrerte deltakelser til statistikk, kan brukstilfellene ikke demonstreres troverdig.
- "Legg inn noen som har trent slik at du viser at queriet virker" er et reelt krav, ikke en pynteting. Manglende eksempeldata gjør at sensor ikke kan verifisere brukstilfellene.

### 4. Bookingregler må håndheves mot faktiske data, ikke bare antas

Oppgaven beskriver konkrete regler:

- en gruppetime legges ut 48 timer før den holdes,
- bruker må møte senest 5 minutter før,
- avbestilling må skje senest 1 time før,
- tre prikker i løpet av 30 dager gir utestengelse,
- kapasiteten avhenger av salen.

Skjult poengtap:

- En bookingløsning som bare sjekker at timen finnes, men ikke kapasitet eller utestenging, er funksjonelt for svak.
- En svartelistingsløsning som bare teller totalt antall prikker, og ikke siste 30 dager, treffer ikke kravet.
- Hvis oppmøteregistrering ikke tar hensyn til 5-minuttersregelen, er forretningsregelen ikke realisert.

### 5. Leveransen må være konsekvent i språk, struktur og artefakter

Leveransedokumentet krever ett språk gjennomgående. Samtidig må zip, SQL-skript, tom databasefil, oppskrift og tekstlige outputfiler henge sammen.

Skjult poengtap:

- Blandet norsk og engelsk i README, outputfiler og SQL-kommentarer kan framstå som slurv.
- Filnavn, scriptnavn og instruksjoner som ikke samsvarer, gjør leveransen vanskelig å kjøre og svekker lesbarhet og reproduserbarhet.

## BØR oppfylles

### 1. Skill tydelig mellom skjemaopprettelse, oppstartsdata og brukstilfeller

Den tryggeste strukturen er:

- ett skjemascript,
- ett eller flere init-script for data,
- egne SQL-filer for SQL-baserte brukstilfeller,
- et Python-startscript som kaller SQL med parametere for brukstilfeller som krever Python.

Dette reduserer risikoen for at sensor ikke klarer å gjenskape "databasen slik den er før usecasene kjøres".

### 2. Dokumenter eksplisitt hva som er flyttet til applikasjonslaget

Dagens skjema kan ikke alene håndheve alle tidsregler og domeneregler. Det er derfor viktig å skrive tydelig hvilke kontroller som skjer i SQL-spørringer og hvilke som skjer i Python-flyten rundt dem.

Dette gjelder særlig:

- 48-timersregelen,
- 5-minuttersregelen,
- 1-times avbestillingsregel,
- 30-dagersvindu for prikker,
- kapasitetskontroll på bookinger,
- sjekk for eksisterende trening før booking.

Sensor vil sannsynligvis akseptere at ikke alt ligger som statiske `CHECK`-restriksjoner, men ikke at reglene er uadressert.

### 3. Bruk e-post som reell identifikator i løsningen

Brukstilfellene refererer til bruker via e-post eller "brukernavn", mens skjemaet har intern `id` som nøkkel og ingen `UNIQUE` på `bruker.epost`.

Dette er en risikosone:

- oppgaven forutsetter i praksis at `johnny@stud.ntnu.no` identifiserer én entydig bruker,
- skjemaet tillater i dag flere rader med samme e-post,
- flere brukstilfeller blir tvetydige hvis e-post ikke er unik.

Selv om skjemaet ikke nødvendigvis må endres, bør løsningen dokumentere og håndheve entydighet. Uten dette kan sensor med rette mene at brukstilfellene er dårlig spesifisert eller dårlig realisert.

### 4. Sørg for at outputene viser at spørringene faktisk oppfyller detaljkravene

Det holder ikke bare å skrive at spørringen virker. Outputene bør gjøre kravene synlige:

- ukeplanen må være globalt sortert på tid, ikke sortert senter for senter,
- besøkshistorikken må ha unike rader,
- månedsvinneren må kunne returnere flere personer ved likt antall,
- "trener sammen"-spørringen må vise to e-poster og antall felles treninger.

## Lett å overse

### 1. Tydelig motsetning mellom datoperiode og ukeplanskravet

Oppgaveteksten sier å sette inn data for en tre dagers periode fra 16. mars til 18. mars. Brukstilfelle 4 ber samtidig om ukeplan for uke 12 "fra 16. mars til 23. mars". Dette er ikke konsistent:

- intervallet 16.-23. mars er åtte dager dersom begge datoer tas med,
- det går utover den oppgitte tre dagers perioden for oppstartsdata,
- uke 12 og datointervallet peker ikke rent på samme utsnitt.

Praktisk implikasjon:

- Hvis gruppen bare legger inn 16.-18. mars, kan sensor mene at ukeplanen er for tynn.
- Hvis gruppen legger inn 16.-23. mars for å tilfredsstille brukstilfelle 4, går de utover dataperioden i problemteksten.

Dette bør håndteres ved å dokumentere valgt tolkning eksplisitt.

### 2. "Brukernavn" og e-post brukes om hverandre

Brukstilfellene sier både "brukernavn" og konkret e-postadresse. Det skaper en skjult spesifikasjonsglipp:

- enten er e-post ment som brukernavn,
- eller så mangler oppgaven et eget brukernavn-attributt.

Hvis implementasjonen tar e-post som brukernavn, bør det sies eksplisitt i dokumentasjonen. Hvis ikke risikerer gruppen å bli trukket for å ha tolket begrepene løst.

### 3. Venteliste er nevnt, men ikke spesifisert som brukstilfelle

Problemteksten omtaler populære økter som fulltegnet med ventelister, men ingen brukstilfeller eller leveransekrav sier hvordan ventelister skal implementeres.

Implikasjon:

- det er sannsynligvis ikke nødvendig å implementere venteliste fullt ut,
- men kapasitet og fulltegnet booking er fortsatt del av domenet,
- en gruppe som ignorerer fullbooket situasjon helt, kan framstå som om de har hoppet over et viktig domeneaspekt.

### 4. Dagens skjema gjør tidshåndtering mulig, men ikke uten friksjon

`gruppetime` lagrer `uke_nr` og `år`, mens selve tidspunktet ligger indirekte via `time_skjer_i` og `tidsblokk`. Det betyr at flere regler krever sammensatt datoutledning før de kan sjekkes korrekt.

Dette er spesielt risikabelt for:

- 48 timer før timen,
- 5 minutter før oppmøte,
- 1 time før avmelding,
- "siste 30 dager" ved svartelisting,
- ukeplansuttrekk basert på faktiske datoer.

Det er ikke nødvendigvis feil modell, men det øker sjansen for halvkorrekte dato-beregninger i SQL eller Python.

### 5. Oppgaven sier "alle data som er nevnt i oppgaven skal settes inn"

Denne formuleringen i evalueringskriteriene er bredere enn den mer avgrensede teksten om tre dagers spinningdata. Det skaper usikkerhet om omfanget.

Mulig sensorforventning:

- minst én representasjon av alle sentrale domeneobjekter bør finnes,
- ikke bare akkurat de radene som trengs for å få én demo til å kjøre.

Det betyr at fullstendig fravær av for eksempel tredemøller, idrettslag eller senterbesøk kan bli tolket negativt, selv om ikke alle disse inngår i et konkret brukstilfelle.

### 6. Tekstlige outputs kan være ment for alle brukerhistorier, ikke bare rene SELECT-spørringer

Leveranseteksten ber om "de tekstlige resultatene (output) fra brukerhistorienes spørringer". Det er uklart om dette bare gjelder de lesende brukstilfellene eller også booking, oppmøte og svartelisting.

Den trygge tolkningen er å levere tekstlig output for alle demonstrerte brukstilfeller, inkludert bekreftelser og feilmeldinger.

## Tvetydigheter og mulige motsetninger som bør dokumenteres

### 1. Tre dagers oppstartsdata versus ukeplan til 23. mars

Dette er den tydeligste interne motsetningen i spesifikasjonen. Gruppen bør velge én tolkning og begrunne den.

### 2. SQL-skript versus Python-applikasjon

Leveranseteksten sier at applikasjonen skal implementeres i Python, men at noen brukstilfeller skrives som SQL-skript. Den praktiske tolkningen bør være at SQL er den primære realiseringen, mens Python fungerer som kjøreflate der det kreves. Hvis dette ikke skilles tydelig, er det lett å levere for mye i Python og tape SQL-poeng.

### 3. Omfanget av oppstartsdata

Problemteksten snevrer inn til spinning og tre dager, mens evalueringsdelen sier at alle data nevnt i oppgaven skal settes inn. Dette er ikke helt harmonisert og bør kommenteres i leveransen.

### 4. Begrepet besøkshistorie

Domeneoppsummeringen snakker både om ankomst ved sentrene og registrerte deltakelser på aktiviteter. Brukstilfelle 5 ber om trening, senter og dato/tid for trening, som peker mot gruppetimer heller enn generelle senterbesøk. Dette bør tolkes eksplisitt, ellers kan man ende med å bruke feil tabellgrunnlag.

## Prioriterte vurderingsrisikoer

1. For mye logikk i Python og for lite i SQL.
2. Ikke-reproduserbar leveranse: feil databasefil, manglende init-rekkefølge eller ufullstendig oppskrift.
3. Oppstartsdata som ikke faktisk demonstrerer alle brukstilfellene.
4. Uavklart tolkning av datoområdet for ukeplanen.
5. Tvetydig identifikasjon av bruker fordi e-post ikke er entydig håndhevet.
