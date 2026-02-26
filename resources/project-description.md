TDT4145 Datamodellering og databasesystemer: Prosjektoppgave

Problembeskrivelse
Vi skal lage en database for treningsbookinger. Vi tar utgangspunkt i SiT Trening, som det
finnes en beskrivelse av her. SiT trening har flere senter i Trondheim: Øya, Gløshaugen,
Dragvoll, Moholt og DMMH. De forskjellige sentrene har forskjellige tilbud. Noen har
gruppetimer, mens andre har kun tilbud om selvtrening. Dette kan dere finne beskrivelse
av på nettsidene til SiT. Vi ønsker å vite gateadressen til hvert senter og hvilke fasiliteter
de har (forskjellige øvelser, garderobe, dusj, badstue, osv) og hvilke åpningstider de har.
Vi ønsker også vite hvilke saler de har og om senteret er bemannet og når de evt. er
bemannet.
Tanken med systemet er at det skal tilby booking av gruppetimer og kunne registre
ankomst ved sentrene. En gruppetime legges ut 48 timer før den holdes, og den har
begrenset antall plasser, helt avhengig av salen som aktiviteten holdes i. Vi ønsker at
dere skal modellere en del typer gruppeaktiviteter som finnes på SiTs nettsider for
trening i Trondheim. Dette er ca. 30 forskjellige aktiviteter. Av disse skal dere ta med
aktiviteter merket som «spin». For hver aktivitetstype ta med beskrivelsen av aktiviteten
som finnes på nettsiden.
Når du booker en time, må du møte senest før 5 minutter før treningen. Hvis du ønsker å
avbestille treningen, må det skje senest en time før treningen. Systemet skal kunne vite
hvem som er på treningen om hvem som ikke møter. De som ikke møter, vil få en «prikk» i
systemet. Dersom du får 3 prikker i løpet av 30 dager, vil du bli utestengt fra
nettbookingen inntil første prikk er eldre enn 30 dager.
Spinningssaler har et forskjellig antall sykler og de har litt forskjellige sykler i salen. Noen
saler har sykler med BodyBike-bluetooth-forbindelse, dvs. hvis du har en BodyBike-app
på mobilen din, kan du koble til watt og kadens på sykkelen. Databasen skal vite hvilke
sykler som har denne egenskapen. Det er et nr. på hver sykkel i salen.
Tredemøllene er også av interesse i dette systemet. Vi ønsker å registrere tredemøllene i
systemet, med å vite hvem som er produsent, hva maksimal hastighet og stigning er for
møllene. Det kan være forskjellige møller i en sal og de har et nr. for identifikasjon. Vi
kunne også tenkt oss å registrere annet treningsutstyr på sentrene, men dropper dette
da oppgaven blir stor.
Hver bruker av systemet skal registreres i systemet med navn, epostadresse og mobilnr.
I tillegg skal systemet kunne vise hvem som er instruktør for hver trening. Dette vises ved
et fornavn på personen. Hvem som er instruktør for en spesifikk trening kan endre seg fra
uke til uke. Systemet skal kunne registrere hvilke aktiviteter en bruker er registret som
deltatt på.
En annen bruk av treningssentrene vi ønsker å ta med er idrettslagets bruk av salene.
Idrettslagene har reservert salene i mange tidspunkt i løpet av en uke. Vi vil gjerne
registrere hvilke grupper av idrettslagene det er som har reservert de forskjellige salene i
løpet av en uke. Studenter har medlemskap i idrettslaget for å kunne bruke disse timene. 
De må også har bruker i systemet som alle andre brukere. Du må være medlem av
idrettslaget for å kunne bruke disse timene.
SiT har også behov for å få ut statistikk for påmelding til trening, slik at de kan planlegge
for nye semestre. Vi ønsker å vite hva det maksimale tallet for påmeldte for hver økt som
man kan melde seg på i. Mange økter er svært populære og er fullregistrerte med
ventelister kun kort tid etter at de er lagt ut. Mange melder seg av treningen innen fristen.
Vi ønsker at dere setter inn data for en tre dagers periode, dvs. startende 16. mars og til
og med 18. mars. I denne perioden ønsker vi at dere kun skal sette inn data for aktiviteter
at typen «Spinning» på Øya treningssenter og på Dragvoll, dvs. alle former for spinning.
Se på SITs nettsider for data. Hvis de er utilgjengelig, lag noen treninger som dere finner
på. Sett inn fasiliteter, saler og noen sykler for Øya treningssenter. Dere trenger ikke gjøre
dette for de andre treningssentrene.
Brukstilfeller
1. Legg inn treningssenter, saler, noen sykler, noen brukere, noen trenere og
treninger som nevnt over. Dette skal leveres som SQL.
2. Booking av trening «Spin60» på tirsdag 17. mars kl. 18.30 på Øya treningssenter
for bruker «johnny@stud.ntnu.no». Denne skal leveres som både Python og SQL.
La brukernavn, aktivitet og tidspunkt være parametere, og sjekk at treningen
finnes før dere booker.
3. Registrering av oppmøte for treningen nevnt i brukstilfelle 2. Brukernavn og
hvilken trening skal være parametere. Denne skal leveres som Python og SQL.
4. Ukeplan for alle treninger registrert i uke 12, dvs. fra 16.mars til 23.mars. Denne
skal sorteres på tid, dvs. treninger fra forskjellige senter skal flettes inn i samme
output. Dette skal leveres i Pyhton og SQL. Startdag og uke skal være parametere
som settes før du kjører queriet.
5. Lag en personlig besøkshistorie for bruker «johnny@stud.ntnu.no» siden 1. januar
2026. Denne kan lages i SQL. Sørg for at det er registrert noen treninger for Johnny
i databasen. Skriv ut hvilken trening, treningssenter og dato/tid for treningen.
Resultatet skal inneholde unike rader.
6. Svartelisting. Brukeren ‘johnny@stud.ntnu.no’ fikk uheldigvis tre prikker i system
og skal utestenges fra elektronisk booking i 30 dager. Implementeres i Python og
SQL. Dere skal sjekke at det finnes minst tre prikker innen siste 30 dager før dere
svartelister.
7. Hver måned blir personen/personene som har trent flest fellestreninger, gitt
oppmerksomhet. Lag et query som finner den/de som har deltatt på flest
gruppetimer en gitt måned. Det kan være flere enn en person. Denne kan lages i
Python og SQL. Husk å ta med måned som parameter. Legg inn noen som har
trent slik at du viser at queriet virker.
8. Noen forskere ønsker å finne ut om det er vanlig å trene sammen? Foreslå en
måte å finne ut av dette på. For å forenkle problemet, kan dere anta at dere skal
finne to studenter som trener sammen. Altså epost, epost og antall felles 
treninger. Skriv dette i SQL. Legg inn noen som har trent slik at du viser at queriet
virker.
