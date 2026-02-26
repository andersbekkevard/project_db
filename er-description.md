# ER Diagram v1

## Entities

### Bruker
- **navn** — "navn" (line 33)
- **epostadresse** — "epostadresse" (line 33)
- **mobilnr** — "mobilnr" (line 33)
- **id** (PK, from ER)

### Lagsmedlem
- (subtype of Bruker)
- Must also be a Bruker in the system (line 42-43)
- Must be member of idrettslaget to use reserved times (line 43)

### medlemskap
- (subtype of Bruker)
- **start-date** (from ER)

### prikk
- **member_id** (from ER)
- **when** (from ER)
- Given when a user does not show up to a booked session (line 21-22)
- 3 prikker within 30 days → blocked from online booking until first prikk is older than 30 days (line 22-23)

### id_rett/org
- Represents groups within idrettslaget (line 40: "hvilke grupper av idrettslagene")
- Reserve saler at multiple timeslots during a week (line 39-40)

### fasilitet
- **navn** (from ER)
- **beskrivelse** (from ER)
- **icon** (from ER)
- Examples: forskjellige øvelser, garderobe, dusj, badstue (line 8-9)

### treningssenter
- **navn** (from ER) — e.g. Øya, Gløshaugen, Dragvoll, Moholt, DMMH (line 5-6)
- **gateadresse** (line 8)
- **åpner** — åpningstid (line 9)
- **stenger** — stengetid (line 9)
- **bemann-start** — when staffed from (line 10-11)
- **bemann-slutt** — when staffed until (line 10-11)

### sal
- **plasser** — antall plasser (line 14: "begrenset antall plasser, helt avhengig av salen")
- **senterID** (from ER)

### time-slot
- **ID** (from ER)
- **weekeday**
- **start-time** (from ER)
- **end-time** (from ER)
- Gruppetime legges ut 48 timer før den holdes (line 13)

### Gruppetime
- **ID** (from ER)
- **sal** (from ER)
- **kapasitet** (from ER) — begrenset antall plasser avhengig av sal (line 14)
- ~30 forskjellige aktiviteter, inkl. alle merket "spin" (line 15-17)
- For hver aktivitetstype: ta med beskrivelsen fra nettsiden (line 17-18)

### Instruktør
- **fornavn** (line 34-35: "vises ved et fornavn på personen")
- **id** (from ER)
- Hvem som er instruktør for en spesifikk trening kan endre seg fra uke til uke (line 35-36)

### Spinningsal
- (subtype of sal)
- Har forskjellig antall sykler (line 24)
- Har forskjellige typer sykler i salen (line 24)

### Løpesal
- (subtype of sal)
- Contains tredemøller (line 28-31)

### Flerbrukshall
- (subtype of sal)

### Spinningsykler
- **nr** — nr. på hver sykkel i salen (line 27)
- **type** — noen har BodyBike-bluetooth-forbindelse (line 25-26: "databasen skal vite hvilke sykler som har denne egenskapen")

### Tredemølle
- **nr** — nr. for identifikasjon (line 30)
- **produsent** — hvem som er produsent (line 29)
- **max-hastighet** — maksimal hastighet (line 29)
- **max-stigning** — maksimal stigning (line 29-30)
- Kan være forskjellige møller i en sal (line 30)

### oppmøtt
- **anmeldt-tidspunkt** (from ER)
- Must arrive senest 5 min before training (line 19)
- Avbestilling senest 1 time før treningen (line 20)

---

## Specializations

### Bruker → Lagsmedlem, medlemskap
- Overlap (o) specialization
- Bruker is supertype; Lagsmedlem and medlemskap are subtypes

### sal → Spinningsal, Løpesal, Flerbrukshall
- Disjoint (d) specialization
- sal is supertype with three subtypes

---

## Relationships

### har (medlemskap – prikk)
- medlemskap **(0,n)** — har — prikk

### medlem_av (Lagsmedlem – id_rett/org)
- Lagsmedlem **(1,n)** — medlem_av — **(0,n)** id_rett/org

### fasiliteter (treningssenter – fasilitet)
- treningssenter — fasiliteter — fasilitet

### har-sal (treningssenter – sal)
- treningssenter — har-sal — sal

### har-gruppetime (sal – Gruppetime)
- sal — har-gruppetime — Gruppetime

### when (Gruppetime – time-slot)
- Gruppetime — when — time-slot

### instruerer (Gruppetime – Instruktør)
- Gruppetime **(1,1)** — instruerer — **(0,1)** Instruktør

### deltar (– Gruppetime)
- Connected to Gruppetime with **(0,n)**
- **oppmøtt** (with anmeldt-tidspunkt) attached to deltar via dashed line

### tilhør (Spinningsal – Spinningsykler)
- Spinningsal — tilhør — Spinningsykler

### tilhør (Løpesal – Tredemølle)
- Løpesal — tilhør — Tredemølle
