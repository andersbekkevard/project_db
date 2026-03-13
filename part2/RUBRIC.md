# Del 2: Handlingssjekkliste for DB2

Dette er en komprimert arbeidsrubrikk basert på DB2-kriteriene i [`resources/norwegian/project-deliverables.md`](/home/anders/.openclaw/workspace/tmp/.worktrees/project_db/part2-contract-freeze/resources/norwegian/project-deliverables.md).

## SQL først

- [ ] Løs mest mulig i SQL. Bruk Python primært til parameterhåndtering, kjøring og utskrift.
- [ ] Implementer alle åtte brukstilfeller i riktig form: bare SQL der oppgaven sier SQL, og både Python og SQL der oppgaven krever begge deler.
- [ ] Sett inn alle data som oppgaven faktisk nevner, særlig dataperioden 16.-18. mars, spinning på Øya og Dragvoll, og Øya-spesifikke fasiliteter/saler/sykler.
- [ ] Hvis skjemaet endres fra DB1, dokumenter hva som er endret og hvorfor.
- [ ] Bruk `sqlite3`-kompatibel SQL og hold spørringene tydelige nok til at sensor ser hva som skjer.

## Lesbarhet

- [ ] Hold Python-koden forståelig og liten; unngå å flytte logikk til Python som kan uttrykkes klart i SQL.
- [ ] Bruk konsekvente navn på kommandoer, parametere og utskrifter.
- [ ] Sørg for at SQL-script og Python-script kan leses og kjøres uten å tolke skjulte forutsetninger.
- [ ] Hold dokumentasjon og resultatutskrifter konsise og enkle å forstå.

## Reproduserbarhet

- [ ] Lever en tom SQLite-databasefil.
- [ ] Lever initialiseringsscript som gjør databasen komplett fra tom tilstand.
- [ ] Lever en oppskrift som faktisk fungerer på ren oppstart, med eksempelinput for alle relevante brukstilfeller.
- [ ] Test hele kjeden selv: tom database -> initialisering -> kjøring av brukstilfeller -> tekstlige resultater.
- [ ] Sørg for at sensor kan gjenskape de leverte resultatene uten manuelle databaseinngrep.

## Riktig output

- [ ] Lagre tekstlige resultater fra brukerhistorienes spørringer som del av leveransen.
- [ ] Brukstilfelle 4 må være sortert på tid og blande treninger fra ulike sentre i samme output.
- [ ] Brukstilfelle 5 må returnere unike rader med trening, treningssenter og dato/tid.
- [ ] Brukstilfelle 7 må returnere alle vinnere ved delt førsteplass.
- [ ] Brukstilfelle 8 må returnere `epost`, `epost` og `antall felles treninger`.
- [ ] Når oppgaven eksplisitt krever en sjekk, må output gjøre det synlig om sjekken slo inn, særlig for «treningen finnes før dere booker» og «minst tre prikker innen siste 30 dager».

## Poengvekt som styrer prioritering

- [ ] Prioriter SQL-kvalitet først: DB2 gir inntil 35 poeng totalt, hvor 25 er SQL og 10 er tilhørende Python.
- [ ] Ikke ofre reproduserbarhet for kortsiktige snarveier; dette vurderes eksplisitt.
- [ ] Ikke ofre korrekt output for intern kodepreferanse; output gir egne poeng.

## KI-deklarasjon

- [ ] Dokumenter hvordan KI er brukt, hvor den er brukt, og hva som eventuelt er endret etterpå.
- [ ] Skill tydelig mellom KI-generert og egenutviklet materiale i kode og dokumentasjon.
