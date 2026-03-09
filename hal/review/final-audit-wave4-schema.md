# Final Audit: Wave 4 Schema Review

## 1. Scope reviewed

Reviewed:

- `resources/norwegian/project-description.md`
- `resources/norwegian/project-deliverables.md`
- `assumptions.md`
- `sql/schema.sql`
- `relational-schema.md` as a secondary consistency check

This audit is limited to the schema and its documented assumptions. `sql/schema.sql` was not modified.

## 2. Verdict: is the schema consistent or not?

Verdict: **not fully consistent**.

The schema is partly internally coherent, but it is **not fully consistent with the assignment specification** and **not fully consistent with `assumptions.md`**. The most important problems are:

- assignment-critical identifiers are not constrained uniquely where the use cases depend on them
- equipment numbering required by the assignment is not modeled faithfully
- time-slot modeling is in tension with the assignment example and is not enforced the way `assumptions.md` claims
- some restrictions that clearly belong in the "documented application logic" bucket are missing from `assumptions.md`

## 3. High-risk inconsistencies / contradictions

### 3.1 `bruker.epost` is not unique even though the use cases identify users by email

- Table: `bruker`
- Columns: `epost`, `mobilnr`
- SQL lines: `sql/schema.sql:27-34`
- Assignment lines: `project-description.md:33`, `:57-62`, `:67-74`

Why this is high risk:

- The assignment says each user is registered with `epostadresse`.
- Multiple use cases identify the target user by email, e.g. `johnny@stud.ntnu.no`.
- `bruker.epost` is `NOT NULL`, but not `UNIQUE`.

Consequence:

- Booking, attendance registration, visit history, and blacklisting become ambiguous if two rows share the same email.
- This is not documented away in `assumptions.md`.

### 3.2 Bike/treadmill numbering is modeled as a generic surrogate key, not as the required per-room number

- Tables: `spinningsykkel`, `tredemølle`
- Columns: `id`
- SQL lines: `sql/schema.sql:202-221`
- Assignment lines: `project-description.md:24-30`

Why this is high risk:

- The assignment explicitly says each bike has "et nr. på hver sykkel i salen" and treadmills "har et nr. for identifikasjon".
- The schema only gives each row a global `id INTEGER PRIMARY KEY`.
- There is no explicit equipment number attribute and no constraint such as uniqueness within `(senter_id, sal_nr)`.

Consequence:

- The schema cannot faithfully represent the domain notion "bike no. 7 in spinning room X".
- A global surrogate key is not equivalent to the required room-local numbering.

### 3.3 The time-block model conflicts with the assignment example and is not enforced as stated in `assumptions.md`

- Table: `tidsblokk`
- Columns: `starttid`, `ukedag`
- SQL lines: `sql/schema.sql:68-74`
- Related tables: `gruppereservasjon` (`sql/schema.sql:136-149`), `time_skjer_i` (`sql/schema.sql:224-231`)
- Assumption lines: `assumptions.md:10-11`
- Assignment lines: `project-description.md:57-60`

Why this is high risk:

- `assumptions.md` says there are exactly 168 weekly blocks, each starting on the hour and lasting exactly one hour.
- The schema does **not** enforce "minute = 00" or one-hour duration. `CHECK (time(starttid) IS NOT NULL)` accepts `18:30`.
- The assignment's own booking example is a class at `17. mars kl. 18.30`.

Consequence:

- If the team relies on the assumption, it contradicts the assignment example.
- If the team relies on the SQL, then the assumption about 168 hour-aligned blocks is false.
- Either way, the model/documentation pair is not internally aligned.

### 3.4 Membership modeling is too weak to determine valid club membership over time

- Tables: `medlem`, `medlem_av`, `idrettslag_gruppe`
- SQL lines: `sql/schema.sql:41-66`
- Assignment lines: `project-description.md:38-43`
- Assumption lines: `assumptions.md:7`

Why this is high risk:

- The assignment says a student must be a member of the sports club to use those reserved sessions.
- `medlem` stores a validity period, but only for `bruker_id`; it is not tied to a specific `idrettslag`.
- `medlem_av` ties a user to an `idrettslag`, but only stores `starttid`; there is no `gyldig_til`.

Consequence:

- The schema cannot answer "was this user a valid member of this sports club at the time of use?" with clear semantics.
- `assumptions.md` claims they have facilitated such checks, but the temporal part is under-modeled.

### 3.5 `relational-schema.md` does not match the implemented SQL for `idrettslag_gruppe`

- File: `relational-schema.md`
- Table described: `idrettslag_gruppe`
- Actual SQL lines: `sql/schema.sql:62-66`

Why this matters:

- `relational-schema.md` says `gruppenavn` is not unique by itself and implies a composite identity with `idrettslag_id`.
- The actual SQL makes `gruppenavn TEXT PRIMARY KEY`.
- This is not a schema bug by itself, but it is a documentation inconsistency around a core identifier.

Consequence:

- Reviewers and graders can get two incompatible stories about the same relation.

## 4. Missing restrictions that are not covered by `assumptions.md`

These are restrictions the assignment implies, the SQL does not enforce, and `assumptions.md` does not clearly delegate/document.

### 4.1 No documented or enforced uniqueness for user email

- Table: `bruker`
- Column: `epost`
- SQL lines: `sql/schema.sql:27-34`

This is the clearest missing restriction because the use cases depend on email as a stable user identifier.

### 4.2 No documented capacity rule for `deltar_på_time` versus `sal.kapasitet`

- Tables: `sal`, `gruppetime`, `deltar_på_time`
- SQL lines: `sql/schema.sql:82-89`, `151-164`, `233-249`
- Assignment lines: `project-description.md:13-15`, `:44-46`

The assignment says a class has a limited number of seats depending on the room. The schema stores `sal.kapasitet`, but neither SQL nor `assumptions.md` explicitly states that enrollment count must not exceed it.

### 4.3 No documented handling of the "class published 48 hours before" rule

- Table set: `gruppetime`, `time_skjer_i`
- SQL lines: `sql/schema.sql:151-164`, `224-231`
- Assignment lines: `project-description.md:13`

The schema has no publication timestamp or explicit documented application rule for when a class becomes available for booking. This may be handled procedurally, but it is not documented as a delegated restriction.

### 4.4 No documented restriction that equipment identifiers must be unique within a room

- Tables: `spinningsykkel`, `tredemølle`
- SQL lines: `sql/schema.sql:202-221`
- Assignment lines: `project-description.md:24-30`

Even if the team intended `id` to stand for the equipment number, the required semantics are not documented and not enforced.

## 5. Restrictions already explicitly delegated to application logic (do not double-count them)

These are genuinely documented in `assumptions.md`, so they should not be scored again as undocumented omissions.

- `senterbemanning` must be within opening hours.
  - `assumptions.md:19`
- A user and an instructor can only participate in one group class per time slot.
  - `assumptions.md:20`
- A banned user must not be allowed to book group classes.
  - `assumptions.md:21`
- Overlap checks for room/instructor/user scheduling are handled in the application.
  - `assumptions.md:22-26`
- Group classes, group reservations, and center visits should only be created within opening hours and staffing rules.
  - `assumptions.md:27-29`
- Prick / late cancellation / no-show logic is handled in the application; the schema stores only the result in `deltar_på_time.prikk_dato`.
  - `assumptions.md:15-16`

## 6. Score / severity-ranked findings

### Severity 1: critical

1. **`bruker.epost` lacks `UNIQUE` although the assignment uses email as the operative identifier**
   - Affects use cases 2, 3, 5, and 6 directly.
   - Tables/columns: `bruker.epost`

2. **Equipment numbering required by the assignment is not modeled faithfully**
   - Tables/columns: `spinningsykkel.id`, `tredemølle.id`
   - Missing explicit per-room `nr` semantics

3. **Time-slot assumptions and schema are not aligned with the assignment example**
   - Tables/columns: `tidsblokk.starttid`, `time_skjer_i.tidsblokk_starttid`
   - `assumptions.md` says only hour-aligned 1-hour slots; assignment example uses `18.30`

### Severity 2: major

4. **Membership over time is under-modeled**
   - Tables/columns: `medlem.gyldig_til`, `medlem.bruker_id`, `medlem_av.starttid`
   - Hard to determine valid club membership at reservation time

5. **Capacity rule is not documented as application logic**
   - Tables: `sal`, `deltar_på_time`
   - The schema stores room capacity but does not document that bookings must respect it

6. **The 48-hour publication rule is not represented or documented**
   - Tables: `gruppetime`, `time_skjer_i`

### Severity 3: moderate

7. **`relational-schema.md` and `schema.sql` disagree about `idrettslag_gruppe` identity**
   - Documentation drift, but potentially confusing in grading

8. **No uniqueness on `idrettslag.navn`**
   - Table/column: `idrettslag.navn`
   - Lower impact because use cases do not query clubs by name, but duplicate club names would still weaken data quality

## 7. Concrete lines/tables/constraints to discuss in the final human report

- `sql/schema.sql:27-34`
  - `bruker(epost)` should be discussed first; the current schema does not guarantee email uniqueness.

- `sql/schema.sql:202-221`
  - `spinningsykkel` and `tredemølle` use only global `id` keys and do not model the assignment's required equipment numbering in the room.

- `sql/schema.sql:68-74`
  - `tidsblokk.starttid` only checks that a valid time exists; it does not enforce the "168 hourly blocks" assumption.

- `assumptions.md:10-11` together with `project-description.md:57-60`
  - This is the clearest assignment-vs-assumption contradiction: one-hour hour-aligned blocks versus a stated booking at `18.30`.

- `sql/schema.sql:41-60`
  - `medlem` and `medlem_av` should be discussed together because membership validity is split in a way that weakens temporal semantics.

- `sql/schema.sql:82-89`, `151-164`, `233-249`
  - The model stores room capacity and enrollments, but the no-overbooking rule is not expressed or documented in `assumptions.md`.

- `relational-schema.md` section for `idrettslag_gruppe` compared with `sql/schema.sql:62-66`
  - Documentation consistency issue worth flagging to the human author before final submission.
