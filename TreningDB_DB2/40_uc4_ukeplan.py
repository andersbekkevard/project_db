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
    parser = argparse.ArgumentParser(description="Hent ukeplan for gruppetimer.")
    parser.add_argument("--startdato", required=True, help="Mandagen som starter uken, på formatet YYYY-MM-DD.")
    parser.add_argument("--uke", required=True, type=int, help="Ukenummer som skal hentes.")
    return parser.parse_args()


def build_output(startdato: str, uke: int, rows: list[object]) -> str:
    if not rows:
        return f"Ingen gruppetimer funnet for uke {uke} fra {startdato}."

    lines = [f"Ukeplan for uke {uke} fra {startdato}:"]
    for row in rows:
        lines.append(
            " | ".join(
                [
                    row["starttidspunkt"],
                    row["sluttidspunkt"],
                    row["senter"],
                    f"Sal {row['salnummer']}",
                    row["aktivitet"],
                    f"Instruktør {row['instruktør']}",
                ]
            )
        )
    return "\n".join(lines)


def main() -> int:
    args = parse_args()

    connection = db.connect()
    try:
        sql = db.load_sql("40_uc4_ukeplan.sql")
        rows = connection.execute(
            sql,
            {
                "startdato": args.startdato,
                "uke": args.uke,
            },
        ).fetchall()
    except Exception as exc:
        db.write_output(f"Kunne ikke hente ukeplan: {exc}")
        return 1
    finally:
        connection.close()

    db.write_output(
        build_output(args.startdato, args.uke, rows),
        output_path="resultat_uc4_ukeplan.txt",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
