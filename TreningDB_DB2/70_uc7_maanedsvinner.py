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
    parser = argparse.ArgumentParser(description="Finn den eller de mest aktive deltakerne i en måned.")
    parser.add_argument("--maaned", required=True, help="Måned på formatet YYYY-MM.")
    return parser.parse_args()


def build_output(maaned: str, rows: list[object]) -> str:
    if not rows:
        return f"Ingen registrerte oppmøter funnet i {maaned}."

    lines = [f"Månedens vinnere for {maaned}:"]
    for row in rows:
        lines.append(f"{row['epost']} | {row['navn']} | {row['antall_gruppetimer']} oppmøter")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()

    connection = db.connect()
    try:
        sql = db.load_sql("70_uc7_maanedsvinner.sql")
        rows = connection.execute(sql, {"maaned": args.maaned}).fetchall()
    except Exception as exc:
        db.write_output(f"Kunne ikke hente månedsvinner: {exc}")
        return 1
    finally:
        connection.close()

    db.write_output(
        build_output(args.maaned, rows),
        output_path="resultat_uc7_maanedsvinner.txt",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
