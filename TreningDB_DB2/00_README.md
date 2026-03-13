# TreningDB_DB2

Denne mappen er pakket for sensur. Kjøringen under er den kanoniske og støttede sensorflyten.

## Krav

- `python3` må være tilgjengelig.
- Ingen `sqlite3`-CLI trengs.
- Stå i denne mappen før du kjører kommandoene under.

## Raskeste verifikasjon

```bash
cd TreningDB_DB2
python3 92_reproduser_alt.py
```

Dette scriptet gjør hele jobben automatisk:

- sletter gammel `trening.db`
- sletter gamle `resultat_*.txt`
- kjører `91_init_db.py`
- kjører UC2, UC3, UC4, UC5, UC6, UC7 og UC8 i låst rekkefølge
- regenererer alle resultatfilene fra gjeldende kode
- kjører hele sekvensen en gang til og sammenligner resultatfiler og databasehash
- gjenoppretter `trening.db` som tom leveransefil til slutt

Forventede resultatfiler etter vellykket kjøring:

- `resultat_uc2_booking.txt`
- `resultat_uc3_oppmote.txt`
- `resultat_uc4_ukeplan.txt`
- `resultat_uc5_besokshistorikk.txt`
- `resultat_uc6_svartelisting.txt`
- `resultat_uc7_maanedsvinner.txt`
- `resultat_uc8_trener_sammen.txt`

## Manuell kjørerekkefølge

Hvis du vil kjøre de parameteriserte brukstilfellene ett for ett, bruk nøyaktig disse kommandoene:

```bash
cd TreningDB_DB2
python3 91_init_db.py
python3 20_uc2_book_gruppetime.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-15 19:00:00"
python3 30_uc3_registrer_oppmote.py --epost johnny@stud.ntnu.no --aktivitet Spin60 --tidspunkt "2026-03-17 18:30:00" --referansetid "2026-03-17 18:24:00"
python3 40_uc4_ukeplan.py --startdato 2026-03-16 --uke 12
python3 60_uc6_svartelisting.py --epost johnny@stud.ntnu.no --referansetid "2026-03-18 21:00:00"
python3 70_uc7_maanedsvinner.py --maaned 2026-03
```

UC5 og UC8 leveres som rene SQL-filer:

- `50_uc5_besokshistorikk.sql`
- `80_uc8_trener_sammen.sql`

Den støttede måten å regenerere deres tekstfiler på er fortsatt `python3 92_reproduser_alt.py`, fordi den bruker Python sin innebygde `sqlite3` og ikke er avhengig av ekstern CLI.

## Leveransekontrakt for databasen

`trening.db` er bevisst tom i den ferdige mappen. Sensor skal ikke starte fra en ferdig seedet database. All oppbygging av databasen skal skje via `python3 91_init_db.py` eller via `python3 92_reproduser_alt.py`.
