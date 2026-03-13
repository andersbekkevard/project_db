# Del 2: Sporbarhet

Sporbarhetsmatrisen under binder hvert brukstilfelle til konkrete leveranseartefakter og et minimalt verifikasjonssignal. Matrisen er avledet fra [`resources/norwegian/project-description.md`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/resources/norwegian/project-description.md), [`resources/norwegian/project-deliverables.md`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/resources/norwegian/project-deliverables.md) og dagens skjema i [`sql/schema.sql`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/sql/schema.sql).

## Sporbarhetsmatrise

| Brukstilfelle | Påkrevde filer / artefakter | Verifikasjonssignal |
| --- | --- | --- |
| 1. Innlegging av grunnlagsdata | SQL-script for initialisering mot tom database, med rader for sentre, saler, aktivitetstyper, gruppetimer, brukere, instruktører og noen spinningsykler. Må være konsistent med tabellene i skjemaet, særlig `senter`, `sal`, `spinningsal`, `spinningsykkel`, `bruker`, `instruktør`, `aktivitetstype`, `gruppetime` og `time_skjer_i`. | Sensor kan kjøre scriptet på tom database og få et datagrunnlag som dekker 16.-18. mars, bare spinning på Øya og Dragvoll, og fasiliteter/saler/sykler for Øya. |
| 2. Booking | Python-inngangspunkt, tilhørende SQL for oppslag og innsetting, eksempelinput for `brukernavn`, `aktivitet` og `tidspunkt`, og tekstlig output fra kjøringen. Berører minst `bruker`, `gruppetime`, `time_skjer_i` og `deltar_på_time`. | Kjøring med `johnny@stud.ntnu.no`, `Spin60` og tirsdag 17. mars kl. 18.30 sjekker at treningen finnes før booking og gir et observerbart resultat som viser om bookingen ble opprettet. |
| 3. Oppmøteregistrering | Python-inngangspunkt, tilhørende SQL for oppslag og oppdatering/registrering, eksempelinput for `brukernavn` og trening, og tekstlig output fra kjøringen. Berører minst `deltar_på_time` og treningstabellene. | Kjøring for brukeren og treningen fra brukstilfelle 2 gir et observerbart resultat som viser om oppmøtet ble registrert. |
| 4. Ukeplan | Python-inngangspunkt, SQL-query, eksempelinput for `startdag` og `uke`, og lagret tekstlig resultat. Berører minst `gruppetime`, `time_skjer_i`, `senter`, `sal`, `aktivitetstype` og `instruktør`. | Output viser alle registrerte treninger i den valgte ukeavgrensningen og er sortert på tid på tvers av sentre. |
| 5. Besøkshistorie | SQL-query og lagret tekstlig resultat. Krever seed-data som faktisk gir Johnny deltakelser. Berører minst `bruker`, `deltar_på_time`, `gruppetime`, `time_skjer_i` og `senter`. | Output inneholder unike rader med trening, treningssenter og dato/tid for `johnny@stud.ntnu.no` siden 1. januar 2026. |
| 6. Svartelisting | Python-inngangspunkt, SQL for opptelling av prikker og selve svartelistingen, seed-data med minst tre prikker innen 30 dager, og tekstlig output. Berører minst `deltar_på_time` og `bruker`. | Kjøring svartelister bare når tre-prikkerskravet i siste 30 dager er oppfylt og gir et observerbart resultat som viser utfallet. |
| 7. Månedens mest aktive | Python-inngangspunkt, SQL-query, parameterisert eksempel for måned, seed-data som viser at queryet virker, og lagret tekstlig resultat. Berører minst `deltar_på_time`, `bruker` og `gruppetime`. | Output returnerer alle personer som deler høyeste antall gruppetimer i valgt måned. |
| 8. Trener sammen | SQL-query, seed-data med overlappende deltakelser, og lagret tekstlig resultat. Berører minst `bruker`, `deltar_på_time` og `gruppetime`. | Output inneholder tre felter per rad: epost, epost og antall felles treninger. |

## Tverrgående leveranseartefakter

- Tom SQLite-databasefil som sensor kan initialisere fra bunnen av.
- Oppskrift for kjøring med eksempeldata, slik at sensor kan reprodusere resultatene uten å streve.
- Tekstlige resultater fra brukerhistorienes spørringer.
- Python-kildekode med SQL og SQL-script pakket i zip-fil ved endelig levering.
- KI-deklarasjon som dokumenterer hvordan og hvor KI er brukt, dersom KI er brukt.

## Kjente kontraktrisikoer

- Ukeavgrensningen i brukstilfelle 4 er ikke helt entydig fordi teksten nevner både uke 12 og intervallet 16.-23. mars.
- Oppgaven låser ikke ett bestemt identifikasjonsformat for «hvilken trening».
- Kildene krever fungerende output, men ikke et detaljert utskriftsformat for alle brukstilfeller. Dette må dokumenteres i endelig kjøreoppskrift.
