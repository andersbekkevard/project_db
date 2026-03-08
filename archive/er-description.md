# ER Diagram - Final

## Entities

### Bruker
- **id** (PK, underlined)
- **navn**
- **epost**
- **mobilnummer**

### medlemskap (weak entity)
- **start-date** (partial key, dashed underline)

### prikk (weak entity)
- **tidspunkt** (partial key)

### id_rett/org
- **lag-ID** (PK, underlined)

### fasilitet
- **navn**
- **beskrivelse**
- **icon**

### treningssenter
- **senter-ID** (PK, underlined)
- **navn**
- **gateadresse**
- **åpner**
- **stenger**
- **bemann-start**
- **bemann-slutt**

### sal (weak entity)
- **rom-nr** (partial key)
- **kapasitet**

### time-slot
- **ID** (PK, underlined)
- **start-time**
- **end-time**

### Gruppetime (weak entity)
- **ID** (partial key)
- **kapasitet**
- **uke-nr**

### Instruktør
- **id** (PK, underlined)
- **fornavn**

### Spinningsal
- (subtype of sal)

### Løpesal
- (subtype of sal)

### Flerbrukshall
- **type**
- (subtype of sal)

### Spinningsykler
- **nr**
- **type**

### Tredemølle
- **nr**
- **produsent**
- **max-hastighet**
- **max-stigning**

### oppmøtt
- **anmeldt-tidspunkt**

---

## Specializations

### sal → Spinningsal, Løpesal, Flerbrukshall
- Disjoint (d) specialization

---

## Relationships

### har medl. (Bruker – medlemskap) — IDENTIFYING
- Bruker **(0,1)** — har medl. — **(1,1)** medlemskap

### har (medlemskap – prikk) — IDENTIFYING
- medlemskap — har — **(0,n)** prikk

### medlem_av (Bruker – id_rett/org)
- Bruker **(0,n)** — medlem_av — id_rett/org

### har-sal (id_rett/org – sal)
- id_rett/org **(0,n)** — har-sal — sal
- Relationship attribute: **uke-nr**

### fasiliteter (treningssenter – fasilitet)
- treningssenter — fasiliteter — fasilitet

### har-sal (treningssenter – sal) — IDENTIFYING
- treningssenter — har-sal — sal

### har-gruppetime (sal – Gruppetime) — IDENTIFYING
- sal — har-gruppetime — Gruppetime

### when (Gruppetime – time-slot)
- Gruppetime — when — time-slot

### instruerer (Gruppetime – Instruktør)
- Gruppetime **(1,1)** — instruerer — **(0,1)** Instruktør

### deltar (medlemskap – Gruppetime)
- medlemskap — deltar — Gruppetime **(0,n)**
- **oppmøtt** (anmeldt-tidspunkt) attached via dashed line

### tilhør (Spinningsal – Spinningsykler)
- Spinningsal — tilhør — Spinningsykler

### tilhør (Løpesal – Tredemølle)
- Løpesal — tilhør — Tredemølle
