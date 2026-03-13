from __future__ import annotations

import hashlib
import os
import sqlite3
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "trening.db"

RESULT_FILES = {
    "uc2": BASE_DIR / "resultat_uc2_booking.txt",
    "uc3": BASE_DIR / "resultat_uc3_oppmote.txt",
    "uc4": BASE_DIR / "resultat_uc4_ukeplan.txt",
    "uc5": BASE_DIR / "resultat_uc5_besokshistorikk.txt",
    "uc6": BASE_DIR / "resultat_uc6_svartelisting.txt",
    "uc7": BASE_DIR / "resultat_uc7_maanedsvinner.txt",
    "uc8": BASE_DIR / "resultat_uc8_trener_sammen.txt",
}


@dataclass(frozen=True)
class PassResult:
    resultater: dict[str, str]
    db_hash: str


def skriv_linjer(*linjer: str) -> None:
    for linje in linjer:
        print(linje)


def ensure_empty_delivery_db() -> None:
    DB_PATH.write_bytes(b"")
    if DB_PATH.stat().st_size != 0:
        raise RuntimeError("Klarte ikke å gjenopprette tom trening.db i leveranseformat.")


def slett_tidligere_artefakter() -> None:
    for path in RESULT_FILES.values():
        if path.exists():
            path.unlink()

    if DB_PATH.exists():
        DB_PATH.unlink()


def kjør_kommando(argv: list[str], forventet_fil: Path | None = None) -> str:
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"

    fullført = subprocess.run(
        argv,
        cwd=BASE_DIR,
        capture_output=True,
        text=True,
        env=env,
        check=False,
    )

    stdout = fullført.stdout
    stderr = fullført.stderr

    if fullført.returncode != 0:
        detaljer = stdout.strip()
        if stderr.strip():
            detaljer = f"{detaljer}\n{stderr.strip()}".strip()
        raise RuntimeError(
            f"Kommandoen {' '.join(argv)} feilet med kode {fullført.returncode}.\n{detaljer}"
        )

    if forventet_fil is not None:
        if not forventet_fil.exists():
            raise RuntimeError(
                f"Kommandoen {' '.join(argv)} fullførte, men laget ikke {forventet_fil.name}."
            )
        filinnhold = forventet_fil.read_text(encoding="utf-8")
        if filinnhold != stdout:
            raise RuntimeError(
                f"Stdout fra {' '.join(argv)} matcher ikke innholdet i {forventet_fil.name}."
            )

    return stdout


def kjør_sql_query(sql_fil: str, output_fil: Path) -> str:
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    try:
        sql = (BASE_DIR / sql_fil).read_text(encoding="utf-8")
        rows = connection.execute(sql).fetchall()
    finally:
        connection.close()

    if rows:
        kolonner = rows[0].keys()
        linjer = [" | ".join(kolonner)]
        linjer.extend(" | ".join(str(rad[kolonne]) for kolonne in kolonner) for rad in rows)
    else:
        linjer = ["Ingen rader."]

    tekst = "\n".join(linjer).rstrip() + "\n"
    output_fil.write_text(tekst, encoding="utf-8")
    return tekst


def verifiser_booking_rad() -> None:
    connection = sqlite3.connect(DB_PATH)
    try:
        rad = connection.execute(
            """
            SELECT COUNT(*)
            FROM deltar_på_time
            WHERE gruppetime_id = 4
              AND bruker_id = 1
              AND påmeldt_tidspunkt = '2026-03-15 19:00:00'
              AND avmeldt_tidspunkt IS NULL
            """
        ).fetchone()
    finally:
        connection.close()

    if rad is None or rad[0] != 1:
        raise RuntimeError("Etter UC2 fant jeg ikke nøyaktig én bookingrad for Johnny på GT4.")


def verifiser_oppmote_rad() -> None:
    connection = sqlite3.connect(DB_PATH)
    try:
        rad = connection.execute(
            """
            SELECT COUNT(*)
            FROM deltar_på_time
            WHERE gruppetime_id = 4
              AND bruker_id = 1
              AND oppmøtt_tidspunkt = '2026-03-17 18:24:00'
            """
        ).fetchone()
    finally:
        connection.close()

    if rad is None or rad[0] != 1:
        raise RuntimeError("Etter UC3 fant jeg ikke nøyaktig én oppmøterad for Johnny på GT4.")


def verifiser_svartelisting() -> None:
    connection = sqlite3.connect(DB_PATH)
    try:
        rad = connection.execute(
            """
            SELECT COUNT(*)
            FROM bruker
            WHERE epost = 'johnny@stud.ntnu.no'
              AND utestengt_til = '2026-04-16 00:00:00'
            """
        ).fetchone()
    finally:
        connection.close()

    if rad is None or rad[0] != 1:
        raise RuntimeError("Etter UC6 ble ikke Johnny svartelistet til forventet tidspunkt.")


def verifiser_ferskhet(pass_start_ns: int) -> None:
    mangler = [path.name for path in RESULT_FILES.values() if not path.exists()]
    if mangler:
        raise RuntimeError(f"Følgende resultatfiler mangler etter kjøringen: {', '.join(mangler)}")

    gamle = [
        path.name
        for path in RESULT_FILES.values()
        if path.stat().st_mtime_ns <= pass_start_ns
    ]
    if gamle:
        raise RuntimeError(
            "Følgende resultatfiler ble ikke nyskrevet i denne kjøringen: "
            + ", ".join(gamle)
        )


def beregn_db_hash() -> str:
    connection = sqlite3.connect(DB_PATH)
    try:
        dump = "\n".join(connection.iterdump()).encode("utf-8")
    finally:
        connection.close()
    return hashlib.sha256(dump).hexdigest()


def les_resultater() -> dict[str, str]:
    return {
        navn: path.read_text(encoding="utf-8")
        for navn, path in RESULT_FILES.items()
    }


def kjør_pass(pass_nummer: int) -> PassResult:
    skriv_linjer(
        f"[pass {pass_nummer}] Sletter gammel trening.db og tidligere resultatfiler.",
    )
    slett_tidligere_artefakter()
    pass_start_ns = time.time_ns()

    skriv_linjer(f"[pass {pass_nummer}] Kjører 91_init_db.py.")
    init_stdout = kjør_kommando([sys.executable, "91_init_db.py"])
    if not DB_PATH.exists():
        raise RuntimeError("91_init_db.py fullførte uten at trening.db ble opprettet.")

    skriv_linjer(f"[pass {pass_nummer}] Kjører UC2 til UC8 i låst rekkefølge.")
    uc2_stdout = kjør_kommando(
        [
            sys.executable,
            "20_uc2_book_gruppetime.py",
            "--epost",
            "johnny@stud.ntnu.no",
            "--aktivitet",
            "Spin60",
            "--tidspunkt",
            "2026-03-17 18:30:00",
            "--referansetid",
            "2026-03-15 19:00:00",
        ]
    )
    RESULT_FILES["uc2"].write_text(uc2_stdout, encoding="utf-8")
    verifiser_booking_rad()

    uc3_stdout = kjør_kommando(
        [
            sys.executable,
            "30_uc3_registrer_oppmote.py",
            "--epost",
            "johnny@stud.ntnu.no",
            "--aktivitet",
            "Spin60",
            "--tidspunkt",
            "2026-03-17 18:30:00",
            "--referansetid",
            "2026-03-17 18:24:00",
        ]
    )
    RESULT_FILES["uc3"].write_text(uc3_stdout, encoding="utf-8")
    verifiser_oppmote_rad()

    kjør_kommando(
        [
            sys.executable,
            "40_uc4_ukeplan.py",
            "--startdato",
            "2026-03-16",
            "--uke",
            "12",
        ],
        forventet_fil=RESULT_FILES["uc4"],
    )

    kjør_sql_query("50_uc5_besokshistorikk.sql", RESULT_FILES["uc5"])

    uc6_stdout = kjør_kommando(
        [
            sys.executable,
            "60_uc6_svartelisting.py",
            "--epost",
            "johnny@stud.ntnu.no",
            "--referansetid",
            "2026-03-18 21:00:00",
        ]
    )
    RESULT_FILES["uc6"].write_text(uc6_stdout, encoding="utf-8")
    verifiser_svartelisting()

    kjør_kommando(
        [
            sys.executable,
            "70_uc7_maanedsvinner.py",
            "--maaned",
            "2026-03",
        ],
        forventet_fil=RESULT_FILES["uc7"],
    )

    kjør_sql_query("80_uc8_trener_sammen.sql", RESULT_FILES["uc8"])

    verifiser_ferskhet(pass_start_ns)
    resultater = les_resultater()
    db_hash = beregn_db_hash()

    skriv_linjer(
        f"[pass {pass_nummer}] Resultatfiler nyskrevet og verifisert.",
        f"[pass {pass_nummer}] DB-hash: {db_hash}",
    )

    if not init_stdout:
        raise RuntimeError("91_init_db.py ga ingen stdout.")

    return PassResult(resultater=resultater, db_hash=db_hash)


def sammenlign_pass(første: PassResult, andre: PassResult) -> None:
    avvik = [
        navn
        for navn in RESULT_FILES
        if første.resultater[navn] != andre.resultater[navn]
    ]
    if avvik:
        raise RuntimeError(
            "Resultatfilene var ikke deterministiske mellom passene: " + ", ".join(avvik)
        )

    if første.db_hash != andre.db_hash:
        raise RuntimeError(
            "Databaseinnholdet var ikke deterministisk mellom passene."
        )
def main() -> int:
    try:
        første = kjør_pass(1)
        andre = kjør_pass(2)
        sammenlign_pass(første, andre)
        ensure_empty_delivery_db()
    except Exception as exc:
        skriv_linjer(f"Reproduksjon feilet: {exc}")
        return 1

    skriv_linjer(
        "Reproduksjon fullført.",
        "Alle resultatfiler ble regenerert fra gjeldende kode.",
        "To fulle pass ga identiske resultatfiler og identisk databasehash.",
        "trening.db er til slutt gjenopprettet som tom leveransefil.",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
