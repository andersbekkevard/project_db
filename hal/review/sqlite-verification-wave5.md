# SQLite Verification Wave 5

## Scope
- Verified SQLite-friendliness of `hal/04-schema.sql`.
- Cross-checked textual claims in `hal/01-rapport-del1.md` against the actual SQL.
- No existing files were modified. This document is the only new file.

## 1. DDL Execution Check Steps And Outcomes

### Environment check
Attempted to use the `sqlite3` CLI first:

```sh
$ sqlite3 -version
zsh:1: command not found: sqlite3
```

Outcome:
- The `sqlite3` command-line tool is not installed in this repo environment.
- I therefore used Python's built-in `sqlite3` module, which exercises the same SQLite engine family and is sufficient for a local DDL load check.

### In-memory DDL execution
Command used:

```sh
$ python3 - <<'PY'
import sqlite3, pathlib
sql = pathlib.Path('hal/04-schema.sql').read_text()
con = sqlite3.connect(':memory:')
try:
    con.executescript(sql)
    print('DDL_OK')
    tables = [r[0] for r in con.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")]
    print('TABLE_COUNT', len(tables))
    for name in tables:
        print(name)
finally:
    con.close()
PY
```

Observed output:

```text
DDL_OK
TABLE_COUNT 18
activity_type
app_user
booking
center_facility
center_opening_hours
center_staffing_hours
facility
group_class
instructor
penalty_dot
room
spinning_bike
sports_team
sports_team_group
sports_team_membership
sports_team_reservation
training_center
treadmill
```

Outcome:
- `hal/04-schema.sql` executes successfully in SQLite.
- All 18 intended tables are created.
- No syntax errors or SQLite-incompatible DDL constructs were encountered.

### Foreign-key activation and integrity check
Command used:

```sh
$ python3 - <<'PY'
import sqlite3, pathlib
sql = pathlib.Path('hal/04-schema.sql').read_text()
con = sqlite3.connect(':memory:')
con.executescript(sql)
print('foreign_keys pragma:', con.execute('PRAGMA foreign_keys').fetchone()[0])
print('foreign_key_check rows:', con.execute('PRAGMA foreign_key_check').fetchall())
con.close()
PY
```

Observed output:

```text
foreign_keys pragma: 1
foreign_key_check rows: []
```

Outcome:
- `PRAGMA foreign_keys = ON;` in the script is effective for the connection that executed it.
- No FK inconsistencies exist immediately after schema creation.

### Important semantic probe: text-based time comparison
Command used:

```sh
$ python3 - <<'PY'
import sqlite3
con = sqlite3.connect(':memory:')
con.executescript('''
CREATE TABLE t(
  opens_at TEXT NOT NULL,
  closes_at TEXT NOT NULL,
  CHECK(opens_at < closes_at)
);
''')
try:
    con.execute("INSERT INTO t VALUES ('10:00', '9:00')")
    print('INSERT_ACCEPTED')
except Exception as e:
    print(type(e).__name__, e)
finally:
    print(con.execute('SELECT opens_at, closes_at FROM t').fetchall())
    con.close()
PY
```

Observed output:

```text
INSERT_ACCEPTED
[('10:00', '9:00')]
```

Outcome:
- This confirms a real SQLite weakness in the current design: checks like `opens_at < closes_at` are lexical string comparisons, not validated time semantics.
- If data is not always zero-padded and ISO-like, invalid intervals can pass.

## 2. FK / PK / UNIQUE / CHECK Sanity Review

### PK and FK review
- PK usage is structurally sound. Entity tables mostly use surrogate integer PKs, and associative/history tables use composite PKs where that matches the model.
- All declared FKs point to valid parent keys and load cleanly in SQLite.
- The schema is SQLite-friendly in the narrow DDL sense: no unsupported data types, no vendor-specific features, no broken FK declarations.

### UNIQUE review
- `training_center.name`, `facility.name`, `activity_type.name`, `sports_team.name`, `app_user.email`, and `app_user.mobile` have sensible uniqueness constraints.
- `room` correctly uses `UNIQUE(center_id, room_name)`, which matches the report's assumption that room names are only unique within a center.
- `sports_team_group` correctly uses `UNIQUE(team_id, name)`.
- `penalty_dot` uses both surrogate PK `dot_id` and `UNIQUE(user_id, session_id)`. That is consistent if the business rule is "at most one dot per user per class".

### CHECK review
Good:
- Positive-number checks on `capacity`, `bike_no`, `treadmill_no`, `max_speed_kmh`, `max_participants`, and `waitlist_position` are sensible.
- Enum-style checks on `room_type`, `has_bodybike_bluetooth`, and `booking_status` are SQLite-safe.
- Simple interval checks such as `valid_from <= valid_to` are syntactically fine.

Weak or missing:
- Time and datetime columns are plain `TEXT` without format checks. SQLite will accept arbitrary strings.
- Comparisons such as `opens_at < closes_at`, `staffed_from < staffed_to`, `starts_at < ends_at`, and `published_at <= starts_at` depend on lexical ordering of text values.
- `group_class.max_participants` is not constrained against `room.capacity`, even though the report repeatedly discusses room capacity as the limiting rule.
- `booking` allows semantically inconsistent combinations:
  - `waitlist_position` may be set for `confirmed`, `checked_in`, or `no_show`.
  - `canceled_at` may be `NULL` for canceled statuses.
  - `check_in_at` may be present for non-attended statuses.
  - No rule ensures only one of cancel/check-in paths is used.
- `penalty_dot.reason` has a default but no domain check, so any text is accepted.
- Equipment tables do not restrict room compatibility. A treadmill can be attached to a `spinning_room`, and a spinning bike can be attached to `other`.

### Concrete semantic proof of one weak constraint
Command used:

```sh
$ python3 - <<'PY'
import sqlite3, pathlib
sql = pathlib.Path('hal/04-schema.sql').read_text()
con = sqlite3.connect(':memory:')
con.executescript(sql)
con.execute("INSERT INTO training_center(center_id,name,street_address) VALUES (1,'A','Addr')")
con.execute("INSERT INTO room(room_id,center_id,room_name,room_type,capacity) VALUES (1,1,'R1','group_studio',20)")
con.execute("INSERT INTO activity_type(activity_type_id,name,category,description) VALUES (1,'Yoga','class','desc')")
con.execute("INSERT INTO instructor(instructor_id,first_name) VALUES (1,'Ada')")
con.execute("INSERT INTO app_user(user_id,full_name,email,mobile) VALUES (1,'User','u@example.com','123')")
con.execute("INSERT INTO group_class(session_id,activity_type_id,room_id,instructor_id,starts_at,ends_at,published_at,max_participants) VALUES (1,1,1,1,'2026-03-09 10:00','2026-03-09 11:00','2026-03-01 10:00',10)")
con.execute("INSERT INTO booking(user_id,session_id,booked_at,booking_status,waitlist_position) VALUES (1,1,'2026-03-01 09:00','confirmed',3)")
print(con.execute('SELECT user_id, session_id, booking_status, waitlist_position FROM booking').fetchall())
con.close()
PY
```

Observed output:

```text
[(1, 1, 'confirmed', 3)]
```

Outcome:
- The current SQL accepts a confirmed booking with a waitlist position, which is probably not intended.

## 3. Mismatch List Between Report Claims And SQL

### Mismatch 1: booking status vocabulary differs
Report:
- `hal/01-rapport-del1.md` says a booking can be "bekreftet, venteliste, avbestilt eller registrert som oppmøtt / no-show".
- Later it says a booking goes from `booket` to `no_show`.

SQL:
- `booking.booking_status` only allows `confirmed`, `waitlisted`, `canceled_in_time`, `canceled_late`, `checked_in`, `no_show`.

Assessment:
- The report uses three different conceptual vocabularies for the same column: `venteliste`, `avbestilt`, and `booket`.
- The SQL has no `booket` state and splits `avbestilt` into two statuses.

### Mismatch 2: capacity rule is described as room-capacity based, but SQL enforces neither room capacity nor the derived linkage
Report:
- The report states that confirmed bookings must not exceed "kapasiteten i salen" / "salens kapasitet".
- The report also frames `group_class.max_participants` as a denormalized per-session field derived from room capacity unless special cases apply.

SQL:
- The SQL comment says `confirmed bookings <= group_class.max_participants`.
- There is no constraint or trigger ensuring `group_class.max_participants <= room.capacity`.
- There is no trigger enforcing confirmed booking count against either limit.

Assessment:
- The text alternates between room capacity and per-session max participants, but the SQL does not tie them together.
- As written, a class can be published with `max_participants` above room capacity and still be considered valid by the schema.

### Mismatch 3: "schemaet er ... egnet for SQLite" is slightly overstated without a caveat about text-based temporal checks
Report:
- The summary says the schema is suitable for SQLite.

SQL reality:
- It is executable in SQLite, but temporal correctness depends on application-side formatting discipline because dates/times are stored as unconstrained text and compared lexically.

Assessment:
- This is not a DDL failure, but the report should mention that SQLite compatibility here is syntactic and operational, not strong temporal validation.

### Mismatch 4: report implies a cleaner status model than the SQL actually enforces
Report:
- The report describes booking, waitlist, attendance, and cancellation as a tidy unified structure.

SQL:
- The schema does not prevent contradictory combinations such as:
  - `booking_status = 'confirmed'` with `waitlist_position = 3`
  - canceled statuses without `canceled_at`
  - `checked_in` without `check_in_at`

Assessment:
- The report's wording is cleaner than the actual enforcement level in the table definition.

## 4. Concrete Patch Suggestions

### Patch 1: tighten time/date representation
Preferred options:
- Store pure times as zero-padded `HH:MM` and datetimes as ISO-8601 `YYYY-MM-DD HH:MM`, then add format checks.
- Or store datetimes as Unix timestamps / Julian-day-compatible numeric values if you want safer ordering semantics.

Example direction:

```sql
opens_at TEXT NOT NULL CHECK (opens_at GLOB '[0-2][0-9]:[0-5][0-9]'),
closes_at TEXT NOT NULL CHECK (closes_at GLOB '[0-2][0-9]:[0-5][0-9]'),
CHECK (time(opens_at) < time(closes_at))
```

And similarly for `starts_at`, `ends_at`, `published_at`, `staffed_from`, and `staffed_to`, using `datetime(...)` where relevant.

### Patch 2: align booking-status documentation and SQL
- Update the report text to use the exact SQL statuses: `confirmed`, `waitlisted`, `canceled_in_time`, `canceled_late`, `checked_in`, `no_show`.
- Replace the phrase "går fra booket til no_show" with something consistent such as "går fra `confirmed` til `no_show`" if that is the intended workflow.

### Patch 3: add internal consistency checks to `booking`
Suggested table-level checks:

```sql
CHECK (
    (booking_status = 'waitlisted' AND waitlist_position IS NOT NULL)
    OR
    (booking_status <> 'waitlisted' AND waitlist_position IS NULL)
),
CHECK (
    (booking_status IN ('canceled_in_time', 'canceled_late')) = (canceled_at IS NOT NULL)
),
CHECK (
    (booking_status = 'checked_in') = (check_in_at IS NOT NULL)
)
```

This will make the report's "ryddig struktur" claim true in practice.

### Patch 4: enforce the relationship between `group_class.max_participants` and `room.capacity`
Minimum improvement:
- Add a trigger on `group_class` insert/update rejecting rows where `NEW.max_participants` exceeds the room's `capacity`.

Example direction:

```sql
CREATE TRIGGER group_class_capacity_guard
BEFORE INSERT ON group_class
FOR EACH ROW
WHEN NEW.max_participants > (
    SELECT capacity FROM room WHERE room_id = NEW.room_id
)
BEGIN
    SELECT RAISE(ABORT, 'max_participants exceeds room capacity');
END;
```

Equivalent `BEFORE UPDATE` trigger should also be added.

### Patch 5: add a domain check on `penalty_dot.reason`
If only a small set of reasons is valid, declare it:

```sql
reason TEXT NOT NULL DEFAULT 'no_show'
    CHECK (reason IN ('no_show', 'late_cancel'))
```

If free text is intentional, the report should say that explicitly.

### Patch 6: optionally enforce room/equipment compatibility
If business rules require it, add triggers so:
- `spinning_bike.room_id` only references rooms with `room_type = 'spinning_room'`
- `treadmill.room_id` only references rooms with `room_type IN ('running_room', 'gym_area')`

Without that, the current model allows impossible equipment-room combinations.

## Overall Conclusion
- `hal/04-schema.sql` is valid SQLite DDL and loads successfully in an in-memory SQLite database.
- Primary keys, foreign keys, and most uniqueness constraints are structurally consistent.
- The main weaknesses are semantic, not syntactic: unconstrained text-based temporal data, weak cross-column checks in `booking`, and a report/SQL mismatch around status vocabulary and the real capacity rule.
- The report should be revised so its wording matches the SQL exactly, or the SQL should be tightened so the current wording becomes true.
