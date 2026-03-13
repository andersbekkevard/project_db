# KI-erklæring

Denne mappen ble ferdigstilt med KI-assistanse.

## Hva KI ble brukt til

KI ble brukt til å:

- skrive pakkelagets dokumentasjon i `00_README.md`
- skrive reproduksjonsscriptet `92_reproduser_alt.py`
- formulere denne erklæringen
- kjøre den låste reproduksjonssekvensen og regenerere `resultat_uc2_booking.txt`, `resultat_uc3_oppmote.txt`, `resultat_uc4_ukeplan.txt`, `resultat_uc5_besokshistorikk.txt`, `resultat_uc6_svartelisting.txt`, `resultat_uc7_maanedsvinner.txt` og `resultat_uc8_trener_sammen.txt`

## Hva KI ikke ble brukt til i denne pakken

I denne arbeidsøkten ble ikke kjernelogikken for brukstilfellene i `20_*.py/.sql`, `30_*.py/.sql`, `40_*.py/.sql`, `50_uc5_besokshistorikk.sql`, `60_*.py/.sql`, `70_*.py/.sql`, `80_uc8_trener_sammen.sql`, `90_db.py`, `91_init_db.py`, `10_schema.sql` eller `11_seed_data.sql` endret.

## Hvordan resultatene ble kontrollert

Resultatfilene er ikke håndskrevet. De er generert ved faktisk kjøring fra tom database via `92_reproduser_alt.py`, som:

- sletter gamle resultatfiler
- bygger databasen på nytt fra `91_init_db.py`
- kjører brukstilfellene i låst rekkefølge
- kontrollerer synlige sideeffekter i databasen
- kjører hele sekvensen to ganger og sammenligner både resultatfiler og databasehash
- gjenoppretter tom `trening.db` etterpå

## Ansvarsavgrensning

KI-assistanse fritar ikke for kontroll. Denne erklæringen dokumenterer bare hvor KI faktisk ble brukt i denne pakkingen og hvordan de genererte artefaktene ble verifisert.
