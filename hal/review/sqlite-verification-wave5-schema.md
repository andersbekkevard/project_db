# SQLite Verification Wave 5: `sql/schema.sql`

## 1. DDL execution outcome

- Verified with Python's built-in `sqlite3` module because the `sqlite3` CLI is not installed in this environment.
- Loaded `sql/schema.sql` into an in-memory SQLite database with `PRAGMA foreign_keys = ON`.
- Result: DDL executed successfully.
- Table count after load: 24.
- `PRAGMA foreign_key_check` returned no rows.
- Important SQLite probe: `SELECT date('2026-02-30'), time('18:30'), time('25:00');` returned `('2026-03-02', '18:30:00', NULL)`.
- Consequence: checks like `CHECK (date(dato) IS NOT NULL)` do not guarantee that the original stored text is a real calendar date. SQLite will normalize some invalid dates instead of rejecting them.

## 2. Test matrix of invalid scenarios attempted

| Scenario | Expected under stricter model | Actual result in SQLite |
| --- | --- | --- |
| Duplicate `bruker.epost` | Reject | Accepted |
| Duplicate `bruker.mobilnr` | Reject | Accepted |
| Invalid date `2026-02-30` in `senteråpningstid` | Reject | Accepted |
| Non-hour `tidsblokk.starttid = '18:30'` | Reject | Accepted |
| `senterbemanning` row without matching `senteråpningstid` row | Reject | Accepted |
| `senterbemanning` outside opening hours | Reject | Accepted |
| `senterbesøk` outside opening hours | Reject | Accepted |
| Booking by blacklisted user | Reject | Accepted |
| Same user booked into two classes in same slot | Reject | Accepted |
| Same instructor assigned to multiple classes in same slot | Reject | Accepted |
| Same room used by class and team reservation in same slot | Reject | Accepted |
| Same room registered in multiple subtype tables | Reject if subtype is disjoint | Accepted |
| Class overbooked beyond room capacity | Reject | Accepted |
| `prikk_dato` before booking time | Reject | Accepted |
| Overlapping `medlem` rows for same user | Reject if only one active membership is intended | Accepted |
| Invalid clock time `tidsblokk.starttid = '25:00'` | Reject | Rejected |
| Negative room capacity | Reject | Rejected |
| Booking referencing missing user | Reject | Rejected |
| `avmeldt_tidspunkt < påmeldt_tidspunkt` | Reject | Rejected |
| `spinningsykkel` in non-`spinningsal` | Reject | Rejected |
| `tredemølle` in non-`løpesal` | Reject | Rejected |
| Opening hours with `slutt_tid <= start_tid` | Reject | Rejected |

## 3. Invalid scenarios wrongly accepted by the schema

- Duplicate user identifiers are allowed.
  Evidence: two rows with `epost = 'u1@example.com'` and two rows with `mobilnr = '11111111'` were inserted successfully.
- Invalid calendar input is allowed to be stored as raw text.
  Evidence: `INSERT INTO senteråpningstid ... ('2026-02-30', ...)` succeeded, even though SQLite's own `date('2026-02-30')` normalizes to `2026-03-02`.
- `tidsblokk` is not restricted to the stated one-hour hour-aligned slots.
  Evidence: `('18:30', 3)` inserted successfully.
- Staffing rules are not enforced.
  Evidence: staffing on `2026-03-18` existed with no opening-hours row, and staffing `07:00-13:00` was accepted while opening hours were `08:00-12:00`.
- Visit registration ignores opening hours.
  Evidence: `senterbesøk` at `2026-03-17 23:30:00` was accepted even though that date's opening hours were `08:00-22:00`.
- Blacklisting is not enforced in the schema.
  Evidence: user `2` had `utestengt_til = '2026-03-31 00:00:00'` and was still inserted into `deltar_på_time`.
- Overlap rules are not enforced.
  Evidence: the same user was booked onto two classes at `18:00` weekday `2`; the same instructor was assigned to multiple classes in the same slot; the same room had both class and reservation in the same slot.
- Room subtype exclusivity is not enforced.
  Evidence: room `(1,1)` existed simultaneously in `spinningsal`, `løpesal`, and `flerbrukshall`.
- Capacity is not enforced at booking level.
  Evidence: class `4` in room capacity `1` ended up with `2` rows in `deltar_på_time`.
- Penalty chronology is not enforced.
  Evidence: a row with `påmeldt_tidspunkt = '2026-03-20 09:00:00'` and `prikk_dato = '2026-03-01'` was accepted.
- Membership periods are not restricted beyond per-row start/end order.
  Evidence: the same user got overlapping `medlem` intervals covering `2026-01-01..2026-12-31` and `2026-06-01..2026-12-31`.

Cross-check against `assumptions.md`:

- Already documented there as application-side rules:
  blacklisting, user/instructor overlap, room/class-vs-reservation overlap, opening-time validation, bemanning only while open, and prikk/late-cancellation logic.
- Not documented there, but accepted by schema:
  duplicate user email/mobile, non-hour tidsblokker, weak real-date validation, capacity overbooking, room subtype overlap, and overlapping membership periods.

## 4. Invalid scenarios correctly rejected by the schema

- Invalid wall-clock time such as `25:00` in `tidsblokk`.
- Negative room capacity.
- Foreign-key violations such as booking a nonexistent user.
- `avmeldt_tidspunkt` earlier than `påmeldt_tidspunkt`.
- `spinningsykkel` placed in a room not registered as `spinningsal`.
- `tredemølle` placed in a room not registered as `løpesal`.
- Opening-hours rows where `slutt_tid <= start_tid`.

## 5. Missing restrictions not covered by `assumptions.md`

- User identity uniqueness is missing.
  The use cases identify users by email, so Python-side validation should reject duplicate `epost` and probably duplicate `mobilnr`.
- The one-hour timeslot rule is missing.
  `assumptions.md` states there are 168 slots starting on the hour, but this is not listed as a validation requirement and the schema accepts `18:30`.
- Real calendar validation is missing.
  SQLite accepts some invalid date strings under the current `CHECK (date(...) IS NOT NULL)` pattern, so Python must validate incoming dates before insert/update.
- Capacity enforcement is missing.
  There is no documented application-side rule saying booking and waitlist logic must respect room capacity / maximum participants.
- Room subtype consistency is missing.
  If the ER intent is that a room is exactly one of `spinningsal`, `løpesal`, or `flerbrukshall`, that disjointness currently exists only as an unstated assumption.
- Membership-period consistency is missing.
  If a user should not have overlapping `medlem` periods, that rule currently exists nowhere.

## 6. Proposed additions to `assumptions.md` (as implementation-spec bullets)

- Python must reject creation or update of a `bruker` if `epost` is already in use by another user.
- Python must reject creation or update of a `bruker` if `mobilnr` is already in use by another user, unless the group explicitly decides that duplicate phone numbers are allowed.
- Python must validate all incoming `dato`, `starttid`, `slutt_tid`, `påmeldt_tidspunkt`, `avmeldt_tidspunkt`, `prikk_dato`, and `utestengt_til` values as real ISO dates/times before writing them to SQLite.
- Python must enforce that every `tidsblokk` starts exactly on the hour (`HH:00`) and represents exactly one one-hour slot.
- Python must enforce booking capacity rules: active bookings for a `gruppetime` must not exceed the intended participant limit, and any overflow must be handled as waitlist logic rather than extra `deltar_på_time` rows.
- Python must enforce room subtype consistency if subtype specialization is intended to be disjoint; a room must not simultaneously be a `spinningsal`, `løpesal`, and `flerbrukshall`.
- Python must enforce membership-period consistency if only one active `medlem` interval per user is intended; overlapping periods for the same user must be rejected.

## 7. Bottom-line verdict on whether `schema.sql` is consistent enough for DB1 part c

`sql/schema.sql` is SQLite-executable and structurally sound enough to submit for DB1 part c only if the team explicitly documents the missing business-rule enforcement in `assumptions.md`.

Right now the schema itself is not the main problem; the documentation gap is. Several important rules are already delegated to the application in `assumptions.md`, but this execution wave shows that at least six more restrictions should be added there to make the submission internally consistent and defensible.
