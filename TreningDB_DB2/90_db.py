from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Iterable, Iterator

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "trening.db"


def resolve_path(path: str | Path) -> Path:
    candidate = Path(path)
    if candidate.is_absolute():
        return candidate
    return BASE_DIR / candidate


def load_sql(path: str | Path) -> str:
    return resolve_path(path).read_text(encoding="utf-8")


def connect(db_path: str | Path = DB_PATH) -> sqlite3.Connection:
    connection = sqlite3.connect(resolve_path(db_path))
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON;")
    return connection


@contextmanager
def transaction(connection: sqlite3.Connection) -> Iterator[sqlite3.Connection]:
    try:
        yield connection
    except Exception:
        connection.rollback()
        raise
    else:
        connection.commit()


def run_sql_file(connection: sqlite3.Connection, path: str | Path) -> None:
    connection.executescript(load_sql(path))


def format_output(lines: str | Iterable[str]) -> str:
    if isinstance(lines, str):
        text = lines
    else:
        text = "\n".join(lines)
    return text.rstrip() + "\n"


def write_output(lines: str | Iterable[str], output_path: str | Path | None = None) -> str:
    text = format_output(lines)
    print(text, end="")
    if output_path is not None:
        resolve_path(output_path).write_text(text, encoding="utf-8")
    return text
