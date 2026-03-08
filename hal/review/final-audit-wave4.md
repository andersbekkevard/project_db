# Wave 4 Adversarial Audit: DB1 Part 1

Scope reviewed:
- `hal/01-rapport-del1.md`
- `hal/03-foreslaatt-er-mermaid.md`
- `hal/04-schema.sql`
- assignment requirements in `resources-en/project-description.md` and `resources-en/project-deliverables.md`

Validation note:
- `hal/04-schema.sql` parses successfully in `sqlite3` via `python3` `executescript`.

## 1. Rubric-based score estimate

### EER model: **18/30**
Why this is not higher:
- The model covers most required concepts, but the ER figure is not precise enough on keys for several associative entities.
- There is at least one materially wrong cardinality: `GROUP_CLASS ||--o| PENALTY_DOT` in `hal/03-foreslaatt-er-mermaid.md:149` implies at most one dot per class, while multiple users can no-show the same class.
- Structural restrictions are discussed in prose, but not always modeled or expressed consistently in the diagram.

### SQL schema: **6/10**
Why this is not higher:
- The schema is coherent and valid SQL, with reasonable PK/FK usage.
- But it fails to enforce, or clearly align with, some assignment facts that are stated as core business rules, especially capacity depending on hall and 48-hour publishing.
- Several state constraints are left too loose, allowing contradictory booking rows.

### Normal forms: **2/5**
Why this is not higher:
- Most tables are plausibly BCNF.
- The justification for `group_class.max_participants` is the weak point. The assignment states capacity depends entirely on the hall (`resources-en/project-description.md:13-15`), yet the report claims BCNF can still hold if `max_participants` is treated as a session property (`hal/01-rapport-del1.md:256-257`, `324-325`). That is a direct conflict with the given domain semantics.

### d-questions: **4/5**
Why this is not full score:
- All four questions are answered in `hal/01-rapport-del1.md:359-402`.
- The answers are mostly sound.
- Slight deduction because d3 is somewhat hedged instead of being tied cleanly to a concrete lifecycle event in the modeled system.

### Estimated total: **30/50**

Strict interpretation:
- This looks more like a solid-but-flawed mid/high pass than a top submission.

## 2. High-risk flaws likely to lose points

### 1. The ER diagram has a real cardinality error for penalty dots
Evidence:
- `hal/03-foreslaatt-er-mermaid.md:149`

Why this is dangerous:
- A single class can generate zero, one, or many penalty dots, one per absent user.
- The current edge suggests zero-or-one dot per class.
- This is not a cosmetic issue; it is a semantic error in the ER model itself, which directly hits the 30-point EER portion.

Likely point loss:
- EER structure/restrictions/consistency.

### 2. `group_class.max_participants` contradicts the assignment’s own dependency statement
Evidence:
- Assignment: capacity depends entirely on the hall in `resources-en/project-description.md:13-15`
- Schema stores session-local capacity in `hal/04-schema.sql:91-105`
- Report defends this as BCNF in `hal/01-rapport-del1.md:246-257` and `324-325`

Why this is dangerous:
- If max participants really depends entirely on the hall, then storing it in `group_class` introduces a dependency on `room_id`, not on `session_id` alone.
- That makes the BCNF claim vulnerable.
- Worse, the report does not present this as a deliberate lower-normal-form tradeoff; it tries to keep the BCNF claim while also changing the business rule.

Likely point loss:
- Normal forms.
- SQL/schema correctness.
- Possibly EER coherence if the grader reads the report critically.

### 3. The ER diagram does not clearly specify keys for several important relations
Evidence:
- `hal/03-foreslaatt-er-mermaid.md:29-32` (`CENTER_FACILITY`)
- `hal/03-foreslaatt-er-mermaid.md:42-55` (`SPINNING_BIKE`, `TREADMILL`)
- `hal/03-foreslaatt-er-mermaid.md:87-95` (`BOOKING`)
- `hal/03-foreslaatt-er-mermaid.md:116-129` (`SPORTS_TEAM_MEMBERSHIP`, `SPORTS_TEAM_RESERVATION`)

Why this is dangerous:
- The deliverables explicitly require keys and foreign keys to be specified (`resources-en/project-deliverables.md:15-23`, `71-77`).
- The SQL has them, but the ER figure should still communicate identification clearly.
- Right now the diagram hides the composite identification logic in exactly the places where it matters most.

Likely point loss:
- EER points for use of keys and structural clarity.

### 4. Publishing exactly 48 hours before class is not modeled or documented rigorously enough
Evidence:
- Requirement in `resources-en/project-description.md:12-15`
- Schema only checks `published_at <= starts_at` in `hal/04-schema.sql:98-105`
- Report’s non-enforced restriction list in `hal/01-rapport-del1.md:121-128` and `341-349` does not mention the 48-hour rule

Why this is dangerous:
- This is a concrete rule in the assignment, not optional background.
- The schema weakens it to “published sometime before start”.
- Because it is not even called out in the “must be handled in software/trigger” list, the submission currently looks like it simply forgot the rule.

Likely point loss:
- SQL restrictions.
- Possibly EER completeness.

### 5. Booking rows can represent contradictory states
Evidence:
- `hal/04-schema.sql:108-122`

Examples currently allowed:
- `booking_status = 'checked_in'` with `check_in_at IS NULL`
- `booking_status = 'waitlisted'` with `waitlist_position IS NULL`
- `booking_status = 'confirmed'` with non-NULL `canceled_at`
- `booking_status = 'canceled_in_time'` with NULL `canceled_at`

Why this is dangerous:
- The assignment emphasizes correct restrictions, not just table creation (`resources-en/project-deliverables.md:20-23`, `72-77`).
- This table currently stores multiple business concepts in one row without integrity rules tying them together.
- A strict grader can reasonably call this under-constrained.

Likely point loss:
- SQL schema quality.
- Restriction correctness.

### 6. The report overclaims “whole model in BCNF”
Evidence:
- `hal/01-rapport-del1.md:324-325`

Why this is dangerous:
- “Hele modellen er designet for å ligge i BCNF” is too strong when one table is only defendable by changing the domain semantics away from the assignment wording.
- Overclaiming is worse than explicitly saying “this table is intentionally not BCNF because of X”.

Likely point loss:
- Normal form assessment credibility.

## 3. Precise fixes with file/line references

### Fix A: Correct the `GROUP_CLASS` to `PENALTY_DOT` cardinality
Change:
- In `hal/03-foreslaatt-er-mermaid.md:149`, replace the current edge with a one-to-many relationship from `GROUP_CLASS` to `PENALTY_DOT`.

Target outcome:
- One class may cause many dots.
- Each dot belongs to exactly one class.

Why:
- This removes a factual ER error and aligns the diagram with `hal/04-schema.sql:124-132`.

### Fix B: Stop claiming BCNF for `group_class` unless capacity is truly session-specific
Choose one of these two paths and state it explicitly.

Path 1, safer for DB1:
- Remove `max_participants` from `group_class` in `hal/04-schema.sql:91-105`.
- In `hal/01-rapport-del1.md:246-257` and `324-325`, state that maximum registrants are derived from `room.capacity`, matching `resources-en/project-description.md:13-15` and `46-49`.

Path 2, if you insist on per-session caps:
- Keep `max_participants`, but rewrite `hal/01-rapport-del1.md:256-257` and `324-325` to admit that this is a deliberate denormalization or a domain extension beyond the assignment.
- Add a hard constraint in application logic or trigger logic that `max_participants <= room.capacity`.

Adversarial recommendation:
- Path 1 is cleaner and safer for grading.

### Fix C: Add the missing 48-hour publication rule to the documented restrictions
Change:
- Update `hal/01-rapport-del1.md:121-128` and `341-349` to include:
  - a class must be published exactly 48 hours before start, or
  - if modeled more flexibly, explain that this assignment rule is enforced in application logic/triggers.

Optional schema-side support:
- If kept in SQL documentation only, say SQLite DDL cannot express this cleanly with cross-row/time arithmetic and that it must be enforced in program/trigger logic.

Why:
- Right now the rule appears omitted, which is avoidable point loss.

### Fix D: Tighten booking-state integrity
Change:
- Add consistency checks around `booking_status`, `waitlist_position`, `canceled_at`, and `check_in_at` in `hal/04-schema.sql:108-122`.

Minimum useful rules:
- waitlisted implies non-NULL `waitlist_position`
- non-waitlisted implies NULL `waitlist_position`
- checked_in implies non-NULL `check_in_at`
- canceled statuses imply non-NULL `canceled_at`
- non-canceled statuses imply NULL `canceled_at`

Why:
- This is low-effort, high-signal schema hardening that improves the “other necessary restrictions” criterion.

### Fix E: Make composite keys visible in the ER diagram
Change:
- In `hal/03-foreslaatt-er-mermaid.md`, mark identification attributes for:
  - `CENTER_FACILITY`
  - `SPINNING_BIKE`
  - `TREADMILL`
  - `BOOKING`
  - `SPORTS_TEAM_MEMBERSHIP`
  - `SPORTS_TEAM_RESERVATION`

Why:
- The SQL currently carries more identification detail than the ER figure.
- For a DB1 submission, that weakens the ER model’s communicative value.

### Fix F: Tone down or repair the BCNF narrative
Change:
- Rewrite `hal/01-rapport-del1.md:324-325`.

Safer wording:
- “The model is largely in BCNF. If `group_class.max_participants` is retained as a session attribute, this is a deliberate modeling choice that may fall outside strict BCNF under the assignment’s stated dependency that capacity depends on hall.”

Why:
- This reads as intellectually honest and is less likely to provoke a harsher deduction.

## 4. Verdict: is this 10/10 at 2nd-year level?

**No.**

Reason:
- A 10/10 DB1 submission should not contain a plain ER cardinality mistake, should not fight the assignment wording on a central functional dependency, and should not overclaim BCNF where the justification is shaky.
- This is competent work with decent coverage, but it is not airtight.

If submitted as-is, my strict estimate is:
- clearly passable
- probably not top-tier
- not something I would call “safe A-level / 10 out of 10” for a careful grader

## Bottom line

The strongest risks are not breadth or effort. They are precision errors:
- one wrong ER cardinality
- one weak normal-form argument
- one missed explicit business rule
- one under-constrained booking table

Those are exactly the kinds of issues that cost points in DB1 even when the overall solution looks polished.
