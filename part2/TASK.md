# Del 2: Leveransekontrakt

Dette dokumentet fryser kontrakten for DB2 basert på tre kanoniske kilder: [`resources/norwegian/project-description.md`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/resources/norwegian/project-description.md), [`resources/norwegian/project-deliverables.md`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/resources/norwegian/project-deliverables.md) og [`sql/schema.sql`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/sql/schema.sql). Alt under er enten direkte sitatnært eller presis paraphrase fra disse filene.

## Tverrgående rammer

- DB2 skal implementeres i SQL og Python med `sqlite3`.
- Sensor skal kunne starte fra en tom SQLite-database og kjøre initialiseringsprogrammene dere leverer.
- Del 2 favoriserer SQL framfor Python: hvis noe kan løses greit i SQL, er det den foretrukne løsningen.
- Datagrunnlaget for innsetting skal dekke en tre dagers periode fra 16. mars til og med 18. mars, og i denne perioden bare aktiviteter av typen «Spinning» på Øya og Dragvoll.
- Det skal settes inn fasiliteter, saler og noen sykler for Øya. Oppgaven sier uttrykkelig at dette ikke trengs for de andre sentrene.
- Domeneregelene som er eksplisitt nevnt i oppgaveteksten er: publisering 48 timer før gruppetime, oppmøte senest 5 minutter før, avbestilling senest 1 time før, og utestengelse ved 3 prikker i løpet av 30 dager inntil første prikk er eldre enn 30 dager.

## Brukstilfeller

| # | Brukstilfelle | Leveres som | Obligatoriske parametere | Påkrevde sideeffekter | Forventet resultat / output |
| --- | --- | --- | --- | --- | --- |
| 1 | Legg inn treningssenter, saler, noen sykler, noen brukere, noen trenere og treninger som nevnt over. | SQL | Ingen parametere er oppgitt. | Oppretter datagrunnlaget som resten av del 2 skal kjøres på. Datagrunnlaget må følge avgrensningen 16.-18. mars, bare spinning på Øya og Dragvoll, og fasiliteter/saler/sykler for Øya. | Et SQL-script som kan kjøres mot tom database og sette inn nødvendige rader uten manuell etterbehandling. Oppgaven krever ikke egen tekstlig output her. |
| 2 | Booking av trening «Spin60» tirsdag 17. mars kl. 18.30 på Øya for bruker `johnny@stud.ntnu.no`. | Python og SQL | `brukernavn`, `aktivitet`, `tidspunkt` skal være parametere. | Må sjekke at treningen finnes før booking utføres. Må registrere booking når parameterne peker på en gyldig trening. | Et tekstlig resultat som viser om bookingen ble utført. Eksakt output-format er ikke spesifisert i kildene. |
| 3 | Registrering av oppmøte for treningen i brukstilfelle 2. | Python og SQL | `brukernavn` og `hvilken trening` skal være parametere. | Må registrere oppmøte for valgt bruker og valgt trening. | Et tekstlig resultat som viser om oppmøtet ble registrert. Eksakt output-format er ikke spesifisert i kildene. |
| 4 | Ukeplan for alle treninger registrert i uke 12. | Python og SQL | `startdag` og `uke` skal være parametere som settes før queryet kjøres. | Ingen vedvarende sideeffekt; dette er en lesespørring. | En samlet ukeplan for alle treninger, sortert på tid slik at treninger fra ulike sentre flettes i samme output. |
| 5 | Personlig besøkshistorie for `johnny@stud.ntnu.no` siden 1. januar 2026. | SQL | Ingen parametere er eksplisitt krevd; bruker og startdato er fastsatt i oppgaven. | Databasen må inneholde treninger for Johnny slik at queryet faktisk returnerer historikk. | Resultatet skal bestå av unike rader og skrive ut hvilken trening, hvilket treningssenter og dato/tid for treningen. |
| 6 | Svartelisting av `johnny@stud.ntnu.no` etter tre prikker. | Python og SQL | Ingen parametere er eksplisitt krevd utover den faste brukeren i teksten. | Må sjekke at det finnes minst tre prikker innen siste 30 dager før brukeren svartelistes. | Et tekstlig resultat som viser om svartelisting ble utført. Eksakt output-format er ikke spesifisert i kildene. |
| 7 | Finn personen/personene som har deltatt på flest gruppetimer i en gitt måned. | Python og SQL | `måned` skal være parameter. | Databasen må inneholde deltakelsesdata som viser at queryet virker, inkludert eventuell delt førsteplass. | Output skal returnere den eller de personene som har høyest antall gruppetimer i valgt måned. Kildene sier ikke hvilke identitetsfelt som må skrives ut. |
| 8 | Finn to studenter som trener sammen. | SQL | Ingen parametere er eksplisitt krevd. | Databasen må inneholde deltakelsesdata som gjør at queryet faktisk finner felles treninger. | Output skal være `epost`, `epost` og `antall felles treninger` for studentpar som trener sammen. |

## Avklarte ambiguiteter som skal bevares i kontrakten

- Brukstilfelle 4 sier både «uke 12» og «fra 16.mars til 23.mars». Dette er ikke helt presist som ukeavgrensning og må dokumenteres som en uklarhet i implementasjonen, ikke skjules.
- Brukstilfelle 3 sier at «hvilken trening» er parameter, men oppgaven spesifiserer ikke om dette skal være intern id, aktivitet + tidspunkt, eller en annen nøkkel.
- Brukstilfelle 2 bruker Øya i eksempelet, men krever bare `brukernavn`, `aktivitet` og `tidspunkt` som parametere. Hvis flere treninger deler aktivitet og tidspunkt på ulike sentre, sier kildene ikke hvordan kollisjonen skal løses.
- Brukstilfelle 1 sier «noen sykler», «noen brukere» og «noen trenere», men gir ikke eksakte minimumstall.
- For brukstilfelle 2, 3, 6 og 7 er semantikken klar, men tekstene spesifiserer ikke detaljert output-format utover at tekstlige resultater skal leveres.
