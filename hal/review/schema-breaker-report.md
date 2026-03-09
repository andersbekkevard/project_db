# Schema Breaker Report

## 1. Executive summary

`sql/schema.sql` is not just missing a few polish constraints. It accepts several states that conflict with the assignment text and with the team's own stated modeling assumptions, even before you get into the application-handled timing rules.

The most serious holes are:

- two users can share the same e-mail even though the use cases identify users by e-mail
- a `gruppetime` can exist without any scheduled time at all
- bookings can exceed room capacity with no database resistance
- spin classes can be scheduled in non-spinning rooms, and any center can host any activity type
- sports-team reservations can occupy non-hall rooms
- one physical room can be a spinning room, treadmill room, and multipurpose hall at the same time
- the schema does not actually model the required bike/treadmill numbers per room

Several other bad states are possible too, but the list above is the high-signal subset that should either be fixed in the schema or explicitly pushed into `assumptions.md`.

## 2. Method (how I tried to break it)

I read:

- `resources/norwegian/project-description.md`
- `resources/norwegian/project-deliverables.md`
- `assumptions.md`
- `sql/schema.sql`
- `relational-schema.md`
- `hal/research/sit-domain-research.md`

I then loaded `sql/schema.sql` into throwaway in-memory SQLite databases through Python's `sqlite3` module and tried to insert bad-but-plausible rows. I excluded findings already explicitly delegated to application logic in `assumptions.md`, such as overlap handling, booking deadlines, prikk logic, and opening-hours validation.

## 3. Confirmed breakages the schema accepts

### F1. User e-mail is not unique

Why this is bad:

- the assignment uses e-mail as the booking/check-in user identifier
- `bruker.epost` is `NOT NULL` but not `UNIQUE` in `sql/schema.sql:27-34`
- duplicate e-mails make the required use cases ambiguous

Confirmed bad state:

```sql
INSERT INTO bruker (id, navn, epost, mobilnr)
VALUES (1, 'Alice', 'alice@example.com', '11111111');

INSERT INTO bruker (id, navn, epost, mobilnr)
VALUES (2, 'Mallory', 'alice@example.com', '22222222');
```

Both inserts succeed.

### F2. `tidsblokk` accepts times that are not whole-hour blocks

Why this is bad:

- `assumptions.md` says there are exactly 168 weekly time blocks and that each starts at `xx:00` and lasts exactly one hour
- `tidsblokk` only checks `time(starttid) IS NOT NULL` in `sql/schema.sql:68-74`
- that means `18:30`, `18:30:17`, etc. are accepted as canonical time blocks

Confirmed bad state:

```sql
INSERT INTO tidsblokk (starttid, ukedag)
VALUES ('18:30', 2);
```

This succeeds.

### F3. A group class can exist with no scheduled time at all

Why this is bad:

- `gruppetime` stores week/year/instructor/activity/room, but not its actual time
- the time lives in `time_skjer_i`, but nothing forces every `gruppetime` row to have a matching `time_skjer_i` row
- `time_skjer_i.gruppetime_id` references `gruppetime`, but the reverse dependency is missing in `sql/schema.sql:151-164` and `sql/schema.sql:224-231`

Confirmed bad state:

```sql
INSERT INTO instruktør (id, fornavn) VALUES (1, 'Ina');
INSERT INTO aktivitetstype (navn, beskrivelse) VALUES ('Spin60', 'Spin class');
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'Oya', 'Addr 1');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 1, 20);

INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (10, 12, 2026, 1, 'Spin60', 1, 1);
```

This succeeds even though the class has no time block.

### F4. Room capacity is not enforced against actual bookings

Why this is bad:

- the assignment explicitly says class capacity depends on the room
- `sal.kapasitet` exists, but nothing links it to the number of active rows in `deltar_på_time`
- `deltar_på_time` only enforces one booking per `(gruppetime_id, bruker_id)` in `sql/schema.sql:233-249`

Confirmed bad state:

```sql
INSERT INTO bruker (id, navn, epost, mobilnr) VALUES
  (1, 'Alice', 'alice@example.com', '11111111'),
  (2, 'Bob', 'bob@example.com', '22222222');

INSERT INTO instruktør (id, fornavn) VALUES (1, 'Ina');
INSERT INTO aktivitetstype (navn, beskrivelse) VALUES ('Spin60', 'Spin class');
INSERT INTO tidsblokk (starttid, ukedag) VALUES ('18:00', 2);
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'Oya', 'Addr 1');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 1, 1);

INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (11, 12, 2026, 1, 'Spin60', 1, 1);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (11, '18:00', 2);

INSERT INTO deltar_på_time (gruppetime_id, bruker_id, påmeldt_tidspunkt) VALUES
  (11, 1, '2026-03-15 18:00'),
  (11, 2, '2026-03-15 18:01');
```

All inserts succeed although capacity is `1`.

### F5. Spin classes can be scheduled in non-spinning rooms

Why this is bad:

- the assignment distinguishes spinning rooms and spinning bikes as dedicated physical resources
- `gruppetime` points only to `sal`, not to a room subtype
- nothing in `sql/schema.sql:151-164` enforces that `Spin60` or other spin variants must use a row in `spinningsal`

Confirmed bad state:

```sql
INSERT INTO instruktør (id, fornavn) VALUES (1, 'Ina');
INSERT INTO aktivitetstype (navn, beskrivelse) VALUES ('Spin60', 'Spin class');
INSERT INTO tidsblokk (starttid, ukedag) VALUES ('18:00', 2);
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'Oya', 'Addr 1');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 2, 20);
INSERT INTO løpesal (senter_id, sal_nr) VALUES (1, 2);

INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (12, 12, 2026, 1, 'Spin60', 1, 2);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (12, '18:00', 2);
```

This succeeds. A spin class in a treadmill room is nonsense.

### F6. Any center can host any activity type

Why this is bad:

- the assignment says different centers have different offerings
- the local domain research in `hal/research/sit-domain-research.md` shows concrete center/activity differences, including spin variants only at certain centers
- there is no center-to-activity-offering table and no constraint in `gruppetime`

Confirmed bad state:

```sql
INSERT INTO instruktør (id, fornavn) VALUES (1, 'Ina');
INSERT INTO aktivitetstype (navn, beskrivelse) VALUES ('Spin60', 'Spin class');
INSERT INTO tidsblokk (starttid, ukedag) VALUES ('18:00', 2);
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'DMMH', 'Thrond Nergaards veg 7');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 1, 20);

INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (13, 12, 2026, 1, 'Spin60', 1, 1);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (13, '18:00', 2);
```

This succeeds because the schema has no way to say "this center does not offer this activity."

### F7. Sports-team reservations can occupy the wrong room type

Why this is bad:

- the assignment text says sports-team use concerns hall reservations
- `gruppereservasjon` references generic `sal`, not `flerbrukshall`
- therefore team reservations can take over a spinning room or treadmill room

Confirmed bad state:

```sql
INSERT INTO idrettslag (id, navn) VALUES (1, 'NTNUI');
INSERT INTO idrettslag_gruppe (gruppenavn, idrettslag_id) VALUES ('NTNUI Volleyball', 1);
INSERT INTO tidsblokk (starttid, ukedag) VALUES ('18:00', 2);
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'Oya', 'Addr 1');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 1, 20);
INSERT INTO spinningsal (senter_id, sal_nr) VALUES (1, 1);

INSERT INTO gruppereservasjon (
  id, uke_nr, gruppenavn, tidsblokk_starttid, tidsblokk_ukedag, senter_id, sal_nr
)
VALUES (20, 12, 'NTNUI Volleyball', '18:00', 2, 1, 1);
```

This succeeds even though the reservation is not in a hall.

### F8. Room subtypes are not mutually exclusive

Why this is bad:

- `spinningsal`, `løpesal`, and `flerbrukshall` all independently reference `sal`
- there is no disjointness constraint
- one room can therefore be all three room types simultaneously

Confirmed bad state:

```sql
INSERT INTO senter (id, navn, gateadresse) VALUES (1, 'Oya', 'Addr 1');
INSERT INTO sal (senter_id, nr, kapasitet) VALUES (1, 2, 20);

INSERT INTO spinningsal (senter_id, sal_nr) VALUES (1, 2);
INSERT INTO løpesal (senter_id, sal_nr) VALUES (1, 2);
INSERT INTO flerbrukshall (senter_id, sal_nr, type) VALUES (1, 2, 'Hall');
```

All three inserts succeed. That creates a physically incoherent room classification.

### F9. Bike and treadmill room-local numbers are not modeled at all

Why this is bad:

- the assignment explicitly says each spinning bike has a number in the room
- it also says treadmills in a room have a number for identification
- `spinningsykkel` and `tredemølle` only have a global surrogate `id`; they do not store the room-local number
- because of that, the database cannot enforce or even represent the required business identifier

Precise schema explanation:

- `spinningsykkel` in `sql/schema.sql:202-210` has `(id, type, har_bluetooth, senter_id, sal_nr)` and no bike number
- `tredemølle` in `sql/schema.sql:212-221` has `(id, produsent, maks_hastighet, maks_stigning, senter_id, sal_nr)` and no treadmill number

This is not a cosmetic omission. It means the schema cannot answer "which bike number has bluetooth?" or "which treadmill number is broken?" without inventing new semantics outside the current model.

## 4. Borderline / debatable findings

These are real weaknesses, but I would not put them in the top recommendation list unless you want a stricter schema.

### B1. Center names are not unique

`senter.navn` is not constrained to be unique. That allows two different rows both named `Oya`. The assignment reads as if center names identify real-world centers, so uniqueness is probably intended, but you could argue that `id` is the only required identifier.

### B2. Sports-team affiliation is not tied to a valid membership period

`medlem_av` can be inserted for a user with no row in `medlem`. If `medlem` is meant to represent the required sports-club membership period, this is a hole. If instead `medlem` models something else, the issue becomes ambiguous.

### B3. `flerbrukshall.type` is unrestricted free text

Any string is accepted. That may be fine if you intentionally want open-ended hall labels, but it is also a good place for typos and uncontrolled values.

## 5. Findings that are already covered by assumptions.md and therefore excluded from the final recommendation list

These are defects in the raw schema, but you already documented them as application-side logic or deliberate modeling choices, so they should not be counted as "forgotten".

- booking, late-cancellation, attendance, and prikk timing rules are not enforced in `deltar_på_time`
- blacklisted users can still be inserted into `deltar_på_time`
- the same user can be booked into overlapping group classes
- the same instructor can be assigned to overlapping group classes
- the same room can be overlap-booked across `gruppetime` / `gruppereservasjon`
- center visits, group classes, and group reservations can be placed outside opening hours
- staffing intervals can exist outside opening intervals
- duplicate same-time center visits for the same user at the same center are allowed by design

## 6. ACTIONABLE additions for assumptions.md

- Users shall have unique e-mail addresses in the system; all user-lookup use cases assume e-mail uniquely identifies one user.
- Every `gruppetime` shall have exactly one associated time block before it is considered valid or bookable.
- A class shall not have more active participants than the capacity of its assigned room.
- Spin activity types shall only be scheduled in rooms registered as `spinningsal`.
- Sports-team reservations shall only be scheduled in rooms registered as `flerbrukshall`.
- A room shall belong to at most one of the room subtype tables: `spinningsal`, `løpesal`, or `flerbrukshall`.
- The system shall maintain which activity types each center offers, and class creation shall be rejected when the center does not offer the chosen activity type.
- `tidsblokk.starttid` shall always be on the hour (`MM = 00`, `SS = 00`) to match the stated 168 fixed weekly blocks.
- Spinning bikes shall have a room-local bike number unique within `(senter_id, sal_nr)`.
- Treadmills shall have a room-local treadmill number unique within `(senter_id, sal_nr)`.

## 7. Evidence appendix with concrete SQL examples / inserts that succeeded but should probably fail

The snippets below all succeeded against `sql/schema.sql`.

### Common setup used in several tests

```sql
INSERT INTO bruker (id, navn, epost, mobilnr) VALUES
  (1, 'Alice', 'alice@example.com', '11111111'),
  (2, 'Bob', 'bob@example.com', '22222222');

INSERT INTO instruktør (id, fornavn) VALUES (1, 'Ina');
INSERT INTO aktivitetstype (navn, beskrivelse) VALUES
  ('Spin60', 'Spin class'),
  ('Yoga', 'Yoga class');

INSERT INTO senter (id, navn, gateadresse) VALUES
  (1, 'Oya', 'Addr 1'),
  (2, 'DMMH', 'Thrond Nergaards veg 7');

INSERT INTO sal (senter_id, nr, kapasitet) VALUES
  (1, 1, 1),
  (1, 2, 20),
  (1, 3, 15),
  (2, 1, 20);

INSERT INTO spinningsal (senter_id, sal_nr) VALUES (1, 1);
INSERT INTO løpesal (senter_id, sal_nr) VALUES (1, 2);
INSERT INTO flerbrukshall (senter_id, sal_nr, type) VALUES (1, 3, 'Hall');

INSERT INTO tidsblokk (starttid, ukedag) VALUES
  ('18:00', 2),
  ('19:00', 2);
```

### Duplicate user e-mail

```sql
INSERT INTO bruker (id, navn, epost, mobilnr)
VALUES (3, 'Mallory', 'alice@example.com', '33333333');
```

### Half-hour time block

```sql
INSERT INTO tidsblokk (starttid, ukedag)
VALUES ('18:30', 2);
```

### Class with no time block

```sql
INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (10, 12, 2026, 1, 'Spin60', 1, 1);
```

### Capacity overflow

```sql
INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (11, 12, 2026, 1, 'Spin60', 1, 1);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (11, '18:00', 2);

INSERT INTO deltar_på_time (gruppetime_id, bruker_id, påmeldt_tidspunkt) VALUES
  (11, 1, '2026-03-15 18:00'),
  (11, 2, '2026-03-15 18:01');
```

### Spin class in treadmill room

```sql
INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (12, 12, 2026, 1, 'Spin60', 1, 2);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (12, '18:00', 2);
```

### Spin class at a center with no modeled offering restriction

```sql
INSERT INTO gruppetime (id, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
VALUES (13, 12, 2026, 1, 'Spin60', 2, 1);

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag)
VALUES (13, '19:00', 2);
```

### Sports-team reservation in spinning room

```sql
INSERT INTO idrettslag (id, navn) VALUES (1, 'NTNUI');
INSERT INTO idrettslag_gruppe (gruppenavn, idrettslag_id) VALUES ('NTNUI Volleyball', 1);

INSERT INTO gruppereservasjon (
  id, uke_nr, gruppenavn, tidsblokk_starttid, tidsblokk_ukedag, senter_id, sal_nr
)
VALUES (20, 12, 'NTNUI Volleyball', '18:00', 2, 1, 1);
```

### Same room in multiple subtype tables

```sql
INSERT INTO spinningsal (senter_id, sal_nr) VALUES (1, 2);
INSERT INTO løpesal (senter_id, sal_nr) VALUES (1, 2);
INSERT INTO flerbrukshall (senter_id, sal_nr, type) VALUES (1, 2, 'Hall');
```
