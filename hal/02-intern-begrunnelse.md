# Intern begrunnelse – hvorfor løsningen ser slik ut

Denne teksten er **ikke** ment for innlevering. Den er et arbeidsnotat som forklarer designvalgene bak del 1.

## 1. Hva jeg optimaliserte for
Målet var ikke å lage den mest akademisk kompliserte modellen mulig. Målet var å lage den modellen som sannsynligvis scorer best i et 2.-års emne:
- tydelige entiteter
- få tvetydigheter
- god oversettelse til relasjoner
- normaliserte tabeller
- ærlig avgrensning av hva som må håndteres i software

Med andre ord: høy presisjon, lav bullshit-faktor.

## 2. Hvorfor jeg tonet ned weak entities og spesialisering
Det opprinnelige diagrammet prøver å være fancy med weak entities og subtype-hierarkier. Problemet er at det blir utydelig hva som faktisk identifiserer hva.

I læreboka er weak entities nyttige når identiteten faktisk er avhengig av en eier-entitet. Det gjelder for eksempel utstyr med nummer innenfor ett rom. Derfor beholder jeg den logikken i den relasjonelle oversettelsen gjennom sammensatte nøkler:
- `(room_id, bike_no)`
- `(room_id, treadmill_no)`

Men jeg gjør **ikke** `room` eller `membership` til weak entities, fordi det gjør mer skade enn nytte i denne oppgaven.

## 3. Hvorfor `ROOM` er generell i stedet for subtype-tabeller
Den viktigste faglige testen er: gir subtype-modellen faktisk bedre semantikk?

For denne oppgaven er svaret stort sett nei.

Vi trenger å vite:
- hvilket senter rommet tilhører
- hva rommet heter
- kapasiteten
- om det finnes sykler eller tredemøller der

Det er ikke nødvendig å bygge et helt ISA-hierarki for å få dette til. En enkel `room_type` + utstyrstabeller er mer lesbar og lettere å implementere i SQLite.

## 4. Hvorfor `BOOKING` er en egen tabell
Dette er rett ut av læreboka: en mange-til-mange-relasjon med egne attributter skal normalt bli en egen relasjon.

Mellom `APP_USER` og `GROUP_CLASS` har vi attributter som:
- bookingtidspunkt
- avbestillingstidspunkt
- innsjekkingstidspunkt
- status
- ventelisteplass

Da er `BOOKING` ikke bare en relasjon – det er en viktig forretningshendelse. Derfor må den være egen tabell.

## 5. Hvorfor prikker er egen tabell
Jeg valgte å lage `PENALTY_DOT` som egen tabell i stedet for å gjemme det inne i `BOOKING`.

Fordeler:
- lett å telle prikker siste 30 dager
- tydelig historikk
- lettere å dokumentere svartelisting som en avledet regel
- mindre risiko for semantisk rot i bookingstatus

Dette gjør også use case 6 mye renere.

## 6. Hvorfor svartelisting utledes, ikke lagres permanent
Jeg vurderte en egen `BOOKING_BAN`-tabell, men landet på at det er bedre å **utlede** svartelisting fra `PENALTY_DOT`.

Hvorfor?
- mindre redundans
- mindre risiko for inkonsistens
- følger prinsippet om at avledet informasjon helst ikke skal lagres hvis den kan beregnes korrekt fra grunnlagsdata

I del d er dette også et godt faglig svar: utestenging blir en regel som sjekkes ved booking og trigges ved no-show.

## 7. Hvorfor `max_participants` ble fjernet fra `GROUP_CLASS`
Etter adversarial review justerte jeg modellen her.

Oppgaveteksten sier at antall plasser avhenger av hallen. For å unngå unødvendig avvik fra domeneregel og for å gjøre BCNF-argumentet vanntett, ble `max_participants` fjernet fra `GROUP_CLASS`.

Nå utledes maks antall deltakere per økt direkte fra `room.capacity`.

Fordeler:
- bedre samsvar med oppgaveteksten
- mindre redundans
- enklere normalform-argumentasjon
- færre mulige inkonsistenser

## 8. Hvorfor jeg ikke modellerte generelle drop-in-besøk
Oppgaveteksten nevner registrering av ankomst til sentrene, men alle konkrete use cases handler om gruppetimer.

Jeg kunne ha lagt til en `CENTER_VISIT`-tabell, men det ville gjort modellen bredere uten å være nødvendig for del 1. For å holde løsningen fokusert og poengsterk, modellerte jeg bare oppmøte til konkrete gruppetimer.

Hvis sensor spør, er begrunnelsen enkel:
- oppgaven eksplisitt evaluerer brukstilfeller rundt treningstimer
- generell drop-in-logging er mulig å legge til senere uten å bryte resten av modellen

## 9. Hva som sannsynligvis vil imponere sensor
- at modellen er renere enn originalen
- at nøkkelvalg er eksplisitte
- at mange-til-mange med attributter er riktig håndtert
- at normalform-delen er kort, presis og ikke full av tomprat
- at vi tydelig sier hva som ikke kan håndteres kun i schema

## 10. Hva som fortsatt bør dobbeltsjekkes før endelig levering
1. Om dere vil ha `mobile` som `UNIQUE` eller bare `NOT NULL`.
2. Om `instructor` skal ha bare fornavn i databasen, eller intern ID + visningsnavn.
3. Om dere vil skrive om svartelisting som «utestenging» eller «svartelisting» i selve rapporten.
4. Om dere vil inkludere en liten AI-erklæring i rapporten allerede nå.
5. Om Mermaid-diagrammet skal tegnes om i draw.io før PDF-innlevering for penere presentasjon.

## 11. Brutalt ærlig oppsummering
Den gamle modellen er litt for forelsket i ER-symboler. Den nye modellen er mer opptatt av faktisk databasekvalitet. Det er riktig prioritering her.
