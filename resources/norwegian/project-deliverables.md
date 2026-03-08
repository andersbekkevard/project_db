TDT4145 Datamodellering og databasesystemer:
Prosjektinnleveringer
Selve oppgaven er beskrevet i eget dokumentet. Dette dokumentet beskriver kravene til
leveransene. Dere velger selv om dere vil skrive på norsk eller engelsk, men ikke bland språk.
Del 1 teller 50 % og del 2 teller 50 %.
Innlevering, del 1: ER-modell og relasjonsdatabaseskjema
DB1: Frist mandag 9. mars 14:00 (02:00 pm) på Blackboard
(NTNU krever at vi leverer innen arbeidstid, senest 2 timer før arbeidsslutt pga. datasupport).
Innleveringen består av tre deler:
a. En ER-modell som viser deres fullstendige datamodell. Dere står fritt til å bruke alle ERog EER-konsepter som er gjennomgått i emnet. Dokumenter de forutsetningene dere har
gjort og eventuelle restriksjonene som ikke (kan) uttrykkes gjennom ER-modellen.
b. ER-modellen oversatt til relasjonsdatabaseskjema (tabeller). Spesifiser nøkler og
fremmednøkler for hver tabell. For hver tabell skal du forklare hvorfor tabellen er på
BCNF, eventuelt forklar hvorfor du velger å ha den på en lavere normalform (du må
forklare hvilken). Det holder å levere tabellene som i SQL-en i c), men forklaringene på
normalformer skal være som tekst.
c. Et SQL-script som konstruerer databasen med tabellene. Husk å spesifiser primær- og
fremmednøkler, samt andre nødvendige restriksjoner. Dokumenter restriksjoner som
ikke uttrykkes i relasjonsdatabaseskjemaet og derfor må håndteres i
applikasjonsprogrammene.
d. Vi ønsker svar på følgende spørsmål:
1. Hvordan (eller kan) dere sørge for at en instruktør ikke kan være til stede på to
forskjellige plasser samtidig? Kan dere få til dette ved hjelp av modellen deres,
eller må noe slikt implementeres i programvaren,
2. Det samme spørsmålet for en bruker. Kan dette løses i modellen eller må det
gjøres i programvaren?
3. Fra hvilket usecase testes det for / opprettes utestengelse (svartelisting) ? Det
trenger ikke være en av de oppgitte usecasene.
4. Statistikk er det noe som må lagres eksplisitt eller går det an å bare gjøre queries
for å få svar? Diskuter dette.
Lever besvarelsen som PDF-fil. SQL-scriptet skal legges ved som en .sql-fil (tekstfil).
Dokumentet skal være oversiktlig og konsist, og figurene skal være enkle å forstå. Husk å ta med
gruppenr, navn på alle gruppemedlemmene og lever på Blackboard.
Innlevering, del 2: Realisert databasesystem
DB2: Frist mandag 23. mars 14:00 (02:00 pm) på Blackboard
(NTNU krever at vi leverer i arbeidstid).
TreningDB implementert i SQL og Python med bruk av sqlite3.
Databaseapplikasjonen skal implementeres i Python (noen brukstilfeller skrives som SQLscript, se beskrivelsen) basert på skjemaet fra første delinnlevering. Hvis dere endrer skjemaet,
er det også greit, men dokumenter hva og hvorfor dere har gjort det. Brukstilfellene må være
realisert og tilfredsstilt. Enkleste løsning er å lage et tekstbasert grensesnitt som kjører i et
terminalvindu (eksempelvis cmd, bash, o.l.). Husk at poenget med oppgaven er å lage modeller,
skrive SQL og gjøre databaseaksess fra Python. Følgende skal leveres:
a. Python kildekode med SQL og SQL-scripts pakket i en zip-fil. Vi ønsker Python og ikke
Jupyter notebook eller annet ikke rent Python. Det er viktig at vi får scriptet som setter inn
data for at vi skal gjenskape databasen slik den er før usecasene kjøres.
b. Databasefilen til prosjektets SQLite-database. Denne skal være tom, slik at sensor kan
kjøre alle initialiseringsprogrammene dere leverer. Det skal være med en oppskrift på
hvordan sensor skal kjøre programmet, sammen med eksempeldata som brukes som
input. Det er viktig at sensor kan kjøre programmet uten å streve. Husk å teste at dette er
mulig før dere leverer.
c. De tekstlige resultatene (output) fra brukerhistorienes spørringer.
Dokumentet skal være konsist og ev. figurer enkle å forstå. Husk å ta med gruppenr, navn på alle
gruppemedlemmene og lever på BlackBoard.
Bruk av KI – kunstig intelligens
Hvis dere gjør bruk av kunstig intelligens i prosjektet, må dere dokumentere hvordan og hvor
dere har brukt dette. Blant annet må dere vise hvilken del av koden som er generert av KI og
hvilken del som dere har programmert selv. Evt. hvilken del av koden som er generert av AI, som
dere har endret på etterpå. Det samme gjelder for bruk av KI i ER-delen av prosjektet. Skriv
gjerne noe om erfaringer med bruk av KI.
Evalueringskriterier
Følgende kriterier ligger til grunn for vurderingen:
DB1:
1. Struktur og sammenheng i datamodellen – bruk av entitetsklasser, relasjonsklasser og
attributter. Disse modellkonseptene skal anvendes konsekvent og hensiktsmessig, det
skal være lett å forstå hva de modellerer.
2. Bruk av nøkler, herunder naturlige og genererte nøkler.
3. Bruk av restriksjoner, som for eksempel strukturelle restriksjoner, i modellen. Disse skal
anvendes konsekvent og korrekt.
4. Riktig oversetting til relasjonsmodellen, dvs. SQL. Korrekt beskrivelse og vurdering av
normal-former.
5. Korrekt bruk av SQL, herunder attributtdomener,
(fremmed-)nøkkelrestriksjoner og UNIQUE.
6. Dokumentene skal være konsise og figurene skal være enkle å forstå.
Poengfordeling mellom delene.
1. (E)ER-modell: Inntil 30 poeng. 
2. Inntil 10 poeng på SQL-definisjoner
3. Inntil 5 poeng på vurdering av normalformer.
4. Inntil 5 poeng. Svar på spørsmål stilt i starten (d) av dokumentet
DB2:
1. Korrekt bruk av SQL i Python. Vi favoriserer SQL framfor Python, slik at hvis det er greit å
løse noe i SQL, ønsker vi det, framfor at det løses i Python. Alle data som er nevnt i
oppgaven skal settes inn.
2. Forståelig og lesbar kode.
3. Det skal være mulig å reprodusere de leverte resultatene ved hjelp av programmet og
databasen som er levert. Oppskriften på hvordan programmet skal kjøres, skal fungere.
Følgende poeng gis på delene av leveransen:
1. Inntil 35 poeng. 25 poeng på SQL og 10 poeng på tilhørende Python.
2. Inntil 5 poeng. Reproduserbarhet av resultatene er viktig.
3. Inntil 5 poeng på riktig output.
4. Inntil 5 poeng på KI-deklarasjon.
Generelt:
Karaktergivningen baserer seg på de generelle beskrivelsene man finner her:
https://i.ntnu.no/wiki/-/wiki/Norsk/Karakterbeskrivelser+for+teknologiske+fag
