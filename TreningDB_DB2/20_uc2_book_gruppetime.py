from __future__ import annotations

import argparse
import importlib.util
import sys
from pathlib import Path


def load_db_module():
    module_path = Path(__file__).with_name("90_db.py")
    spec = importlib.util.spec_from_file_location("db_helper", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Kunne ikke laste {module_path.name}.")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


db = load_db_module()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Book en gruppetime ved hjelp av SQL-foerst-logikk."
    )
    parser.add_argument("--epost", required=True)
    parser.add_argument("--aktivitet", required=True)
    parser.add_argument("--tidspunkt", required=True)
    parser.add_argument("--referansetid", required=True)
    return parser.parse_args()


def run_booking(args: argparse.Namespace):
    connection = db.connect()
    try:
        with db.transaction(connection):
            connection.execute("DROP TABLE IF EXISTS temp.uc2_input")
            connection.execute(
                """
                CREATE TEMP TABLE uc2_input (
                    epost TEXT NOT NULL,
                    aktivitet TEXT NOT NULL,
                    tidspunkt TEXT NOT NULL,
                    referansetid TEXT NOT NULL
                )
                """
            )
            connection.execute(
                """
                INSERT INTO uc2_input (epost, aktivitet, tidspunkt, referansetid)
                VALUES (?, ?, ?, ?)
                """,
                (args.epost, args.aktivitet, args.tidspunkt, args.referansetid),
            )
            connection.executescript(db.load_sql("20_uc2_book_gruppetime.sql"))
            result = connection.execute(
                "SELECT * FROM uc2_result LIMIT 1"
            ).fetchone()
            if result is None:
                raise RuntimeError("SQL-skriptet returnerte ingen bookingstatus.")
            return result
    finally:
        connection.close()


def main() -> int:
    args = parse_args()
    try:
        result = run_booking(args)
    except Exception as exc:
        db.write_output(f"Booking feilet: {exc}")
        return 1

    if result["success"]:
        db.write_output(
            [
                "Booking opprettet.",
                f"Kode: {result['code']}",
                f"Epost: {args.epost}",
                f"Aktivitet: {args.aktivitet}",
                f"Tidspunkt: {args.tidspunkt}",
                f"Bruker-id: {result['bruker_id']}",
                f"Gruppetime-id: {result['gruppetime_id']}",
                f"Endrede rader: {result['changed_rows']}",
                f"Verifiserte rader: {result['verified_rows']}",
            ]
        )
        return 0

    db.write_output(
        [
            "Booking avvist.",
            f"Kode: {result['code']}",
            f"Grunn: {result['message']}",
            f"Epost: {args.epost}",
            f"Aktivitet: {args.aktivitet}",
            f"Tidspunkt: {args.tidspunkt}",
        ]
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
