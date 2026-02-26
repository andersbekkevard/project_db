# Project Requirements — Extracted from project-description.md

---

## Treningssentre

- SiT Trening har sentre: Øya, Gløshaugen, Dragvoll, Moholt, DMMH
- Forskjellige sentre har forskjellige tilbud
- Noen har gruppetimer, andre kun selvtrening
- For hvert senter skal vi vite:
  - Gateadresse
  - Fasiliteter (forskjellige øvelser, garderobe, dusj, badstue, osv.)
  - Åpningstider
  - Hvilke saler de har
  - Om senteret er bemannet, og når

## Saler

- Saler tilhører sentre
- En sal har begrenset antall plasser
- Spinningssaler har et antall sykler

## Gruppeaktiviteter / Aktivitetstyper

- Ca. 30 forskjellige aktivitetstyper finnes på SiTs nettsider
- Alle aktiviteter merket «spin» skal tas med
- For hver aktivitetstype: ta med beskrivelsen fra nettsiden

## Gruppetimer / Treningsøkter

- Legges ut 48 timer før de holdes
- Begrenset antall plasser, avhengig av salen aktiviteten holdes i
- Har en instruktør (vises ved fornavn)
- Hvem som er instruktør kan endre seg fra uke til uke

## Booking

- Bruker booker en gruppetime
- Må møte senest 5 minutter før treningen
- Avbestilling senest 1 time før treningen
- Systemet skal vite hvem som er på treningen og hvem som ikke møter

## Prikker og utestengning

- De som ikke møter får en «prikk»
- 3 prikker i løpet av 30 dager → utestengt fra nettbooking
- Utestengningen varer til første prikk er eldre enn 30 dager

## Sykler (spinning)

- Et nr. på hver sykkel i salen
- Noen sykler har BodyBike-bluetooth-forbindelse (koble til watt og kadens via BodyBike-app)
- Databasen skal vite hvilke sykler som har denne egenskapen

## Tredemøller

- Produsent
- Maks hastighet
- Maks stigning
- Nr. for identifikasjon
- Forskjellige møller kan være i samme sal

## Brukere

- Navn
- Epostadresse
- Mobilnr
- Systemet skal registrere hvilke aktiviteter en bruker er registrert som deltatt på

## Instruktører

- Vises ved fornavn
- Hvem som er instruktør for en spesifikk trening kan endre seg fra uke til uke

## Idrettslag

- Idrettslagene har reservert saler i mange tidspunkt i løpet av en uke
- Vi vil registrere hvilke grupper av idrettslagene som har reservert hvilke saler
- Studenter har medlemskap i idrettslaget for å bruke disse timene
- De må også ha bruker i systemet som alle andre brukere
- Må være medlem av idrettslaget for å bruke disse timene

## Statistikk

- SiT trenger statistikk for påmelding til trening for å planlegge nye semestre
- Vi ønsker å vite maks antall påmeldte for hver økt
- Mange økter er fullregistrerte med ventelister kort tid etter utlegging
- Mange melder seg av treningen innen fristen

---

## Business Rules

1. Gruppetimer legges ut 48 timer før de holdes
2. Maks deltakere = kapasiteten til salen
3. Oppmøte senest 5 min før treningsstart
4. Avbestillingsfrist: minst 1 time før treningen
5. No-show → 1 prikk
6. 3 prikker innen 30 dager → utestengt fra nettbooking til eldste prikk > 30 dager
7. Må være idrettslagsmedlem for å bruke idrettslagets timer
8. Instruktør vises kun med fornavn; tildeling kan endre seg ukentlig

---

## Data Population Requirements

- Alle 5 sentre (Øya, Gløshaugen, Dragvoll, Moholt, DMMH)
- ~30 aktivitetstyper fra SiT, MÅ inkludere alle «spin»-typer, med beskrivelse
- Data for 3-dagers periode: 16.–18. mars (inklusiv)
- I denne perioden: KUN spinning-aktiviteter på Øya og Dragvoll
- Fasiliteter, saler og noen sykler for Øya (ikke påkrevd for andre sentre)
- Noen brukere, instruktører og treningsøkter
- Nok data til å demonstrere alle 8 brukstilfeller
