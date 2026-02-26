# Entities, Attributes & Relationships

Extracted from project-description.md. Norwegian terms kept where natural.

---

## Entities

### 1. Treningssenter
- Navn — Øya, Gløshaugen, Dragvoll, Moholt, DMMH
- Gateadresse

### 2. Åpningstid
- Dag/tidspunkt (day + time range)
- Tilhører et Treningssenter

### 3. Bemanningstid
- Dag/tidspunkt for når senteret er bemannet
- Tilhører et Treningssenter
- Noen sentre er ikke bemannet i det hele tatt

### 4. Fasilitet
- Type/navn — f.eks. øvelser, garderobe, dusj, badstue, osv.
- Tilhører et Treningssenter

### 5. Sal
- Tilhører et Treningssenter
- Kapasitet — bestemmer maks deltakere for gruppetimer i salen

### 6. Aktivitetstype
- Navn
- Beskrivelse — fra SiT sine nettsider
- Ca. 30 typer; MÅ inkludere alle merket som «spin»

### 7. Trening (Gruppetime / Økt)
- Tidspunkt (dato og klokkeslett)
- Legges ut 48 timer før den holdes
- Holdes i en bestemt Sal
- Er av en bestemt Aktivitetstype
- Maks deltakere = kapasiteten til Salen
- Har en Instruktør

### 8. Bruker
- Navn
- Epostadresse
- Mobilnr

### 9. Instruktør
- Fornavn — det eneste som vises
- Hvem som er instruktør for en trening kan endre seg fra uke til uke

### 10. Booking
- Kobler Bruker til Trening
- Må møte senest 5 min før treningen starter
- Avbestilling: senest 1 time før treningen
- Systemet må vite hvem som møtte og hvem som ikke møtte

### 11. Prikk
- Gis til Bruker som ikke møter opp til booket trening
- Har dato/tidsstempel
- Regel: 3 prikker innen 30 dager → utestengt fra nettbooking til eldste prikk er >30 dager gammel

### 12. Sykkel
- Nr (nummer i salen — identifiserer sykkelen i rommet)
- BodyBike-bluetooth (ja/nei) — støtter BodyBike-app for watt/kadens
- Tilhører en Sal (spinningsal)

### 13. Tredemølle
- Nr (for identifikasjon)
- Produsent
- Maks hastighet
- Maks stigning
- Tilhører en Sal
- Forskjellige møller kan finnes i samme sal

### 14. Idrettslagsgruppe
- Representerer en gruppe/lag innenfor idrettslaget
- Reserverer Saler på forskjellige tidspunkt i løpet av en uke

### 15. Idrettslagsmedlemskap
- Bruker må ha medlemskap for å bruke idrettslagets reserverte timer
- Brukeren må også være registrert Bruker i systemet

---

## Relationships

1. **Treningssenter → Åpningstid** (1:N) — senter har åpningstider
2. **Treningssenter → Bemanningstid** (1:N) — senter har bemanningstider (kan være 0)
3. **Treningssenter → Fasilitet** (1:N) — senter har fasiliteter
4. **Treningssenter → Sal** (1:N) — senter har saler
5. **Sal → Sykkel** (1:N) — spinningsal inneholder sykler
6. **Sal → Tredemølle** (1:N) — sal inneholder tredemøller
7. **Trening → Sal** (N:1) — trening holdes i en sal
8. **Trening → Aktivitetstype** (N:1) — trening er av en aktivitetstype
9. **Trening → Instruktør** (N:1) — trening har en instruktør; kan endre seg per uke
10. **Bruker ↔ Trening (via Booking)** (M:N) — bruker booker trening
    - Attributter på relasjonen: oppmøte (ja/nei), avbestilt (ja/nei)
11. **Bruker → Prikk** (1:N) — bruker får prikker for no-show
    - Hver prikk er knyttet til en bestemt Trening
12. **Idrettslagsgruppe ↔ Sal (Reservasjon)** (M:N) — gruppe reserverer sal
    - Attributter på relasjonen: dag/tidspunkt for reservasjon
13. **Bruker → Idrettslagsmedlemskap** — bruker kan være medlem av idrettslaget
    - Påkrevd for å delta på idrettslagets reserverte timer

---

## Business Rules

1. Gruppetimer legges ut 48 timer før de holdes
2. Maks deltakere = kapasiteten til salen treningen holdes i
3. Må møte senest 5 min før treningsstart
4. Avbestillingsfrist: minst 1 time før treningen
5. No-show → 1 prikk
6. 3 prikker innen 30 dager → utestengt fra nettbooking til eldste prikk > 30 dager
7. Må være idrettslagsmedlem for å bruke idrettslagets timer
8. Instruktør vises kun med fornavn; tildeling kan endre seg ukentlig

---

## Data Population Requirements

- Alle 5 treningssentre (Øya, Gløshaugen, Dragvoll, Moholt, DMMH)
- ~30 aktivitetstyper fra SiT, MÅ inkludere alle «spin»-typer, med beskrivelse
- 3-dagers dataperiode: 16.–18. mars (inklusiv)
- I denne perioden: KUN spinning-aktiviteter på Øya og Dragvoll
- Fasiliteter, saler og noen sykler for Øya (ikke påkrevd for andre sentre)
- Noen brukere, instruktører og treningsøkter
- Nok data til å demonstrere at alle 8 brukstilfeller fungerer
