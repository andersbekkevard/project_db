from __future__ import annotations

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


def rebuild_database() -> Path:
    db_path = db.DB_PATH
    if db_path.exists():
        db_path.unlink()

    connection = db.connect(db_path)
    try:
        with db.transaction(connection):
            db.run_sql_file(connection, "10_schema.sql")
            db.run_sql_file(connection, "11_seed_data.sql")
    finally:
        connection.close()

    return db_path


def main() -> int:
    try:
        db_path = rebuild_database()
    except Exception as exc:
        db.write_output(f"Initialisering feilet: {exc}")
        return 1

    db.write_output(
        [
            f"Initialiserte databasen på {db_path}",
            "Kjørte 10_schema.sql",
            "Kjørte 11_seed_data.sql",
        ]
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
