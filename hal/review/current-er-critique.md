# Critique of the Current ER Diagram

## Scope

This critique is based on the current ER artifacts, especially:

- `er_diagrams/SitTrening_nikolai_endring.png`
- `er_diagrams/er-description.md`
- `er_diagrams/er_mermaid.md`
- `relational-schema.md`
- `resources-en/project-description.md`
- `resources-en/project-deliverables.md`

The goal here is not to redesign everything from scratch, but to identify what is already good, what is unclear or incorrect, and what would likely lose points under a standard DB1 rubric for ER modeling, constraints, and translation readiness.

## What Works Well

### 1. The model covers most of the assignment domain

The current diagram clearly tries to cover the main parts of the problem:

- users
- memberships
- training centers
- rooms
- facilities
- group sessions
- instructors
- sports teams
- sports-team reservations
- spinning bikes
- treadmills
- attendance / booking-related information

That breadth is a strength. It shows that the group has read the task and tried to model more than just the obvious booking part.

### 2. Room specialization is a reasonable idea

The specialization from `sal` to `spinningssal`, `løpesal`, and `flerbrukshall` is conceptually sensible. It reflects that some room-specific equipment only belongs in certain room types. Using EER specialization here is defendable.

### 3. Equipment is modeled as separate entities

Modeling `spinningsykkel` and `tredemølle` as entities rather than attributes is correct. These are individual objects with their own identifying number and properties, so entity modeling is appropriate.

### 4. Activity type is separated from individual session

Separating `aktivitetstype` from `gruppetime` is also a good direction. The assignment asks for activity descriptions, while actual sessions vary by time, room, and instructor. That distinction is important.

### 5. The team-reservation part is at least attempted explicitly

Many student solutions ignore the sports-team reservation requirement. This model does not. That is a plus, even though the current solution is still not fully clear.

## Main Problems

## 1. Structural constraints are mostly missing or unclear

This is the biggest grading risk.

The current diagram shows very few readable min-max constraints. In a DB1 course, the ER model is expected to communicate at least the key participation/cardinality restrictions clearly, for example:

- Can a user have more than one membership over time?
- Must every group session occur in exactly one room?
- Must every group session have exactly one activity type?
- Must every group session have exactly one instructor?
- Can a room belong to more than one center?
- Can a bike number repeat across rooms?

Several of these may be intended, but the diagram does not communicate them reliably.

Under the rubric, this would likely cost points on:

- structure and coherence
- use of restrictions
- ease of understanding

## 2. Weak entities are overused and in some places unjustified

The current model treats several concepts as weak entities or identifying relationships:

- `medlem` / `medlemskap`
- `sal`
- `gruppetime`
- `prikk`

This looks more like notation-driven modeling than concept-driven modeling.

### Why this is a problem

A weak entity should normally be used when an entity has no full key of its own and is identified through its owner plus a partial key. That is not convincingly the case for several of these entities:

- A room can usually be identified by `(senter_id, rom_nr)` without needing weak-entity notation in the conceptual model.
- A group session should usually have its own identity, or at least a clear natural identifier such as `(room, start_time)`.
- A membership is not naturally a weak entity here. It is a normal concept with its own lifecycle.

When weak notation is used too broadly, the model becomes harder to understand and harder to map cleanly to relations.

This is likely to cost points because it suggests uncertainty about when weak entities are actually appropriate.

## 3. Time is modeled in a fragmented and inconsistent way

The assignment is fundamentally time-based, but the current model splits time across too many constructs:

- `Dato`
- `reservasjonstid`
- `uke_nr`
- `år`
- `start_tid` / `slutt_tid`
- arrival, cancellation, sign-up timestamps as relationship attributes

This creates several problems.

### Opening hours and staffing

`Dato` is connected to `treningssenter` via `er_åpent` and `er_bemannet`. That is awkward conceptually.

For part 1, the cleaner conceptual approach is usually:

- recurring weekly opening hours per center, or
- a schedule entity with weekday + time interval

Using a full date entity for ordinary opening hours overmodels the problem and still does not clearly express the weekly nature of the schedule.

### Group sessions

`gruppetime` is identified partly through room and then also has `uke_nr` and `år`, while `reservasjonstid` separately stores weekday and start/end time. This makes the actual occurrence of a session harder to reason about.

For a booking system, the key fact is usually that a session happens at a specific date-time interval. The current model spreads that over multiple entities and attributes.

### Sports-team reservations

The reservation side has similar issues. The model hints at recurring weekly reservations, but the exact semantics are unclear:

- Is a reservation for one specific week?
- For every week in a semester?
- For all future weeks?
- Can two groups reserve the same room at the same reservation time?

Those are central business rules, but the ER currently leaves them ambiguous.

## 4. Booking, attendance, cancellation, no-show, and dots are collapsed into one relationship

`deltar_på_time` currently carries:

- `påmeldt_tidspunkt`
- `avmeldt_tidspunkt`
- `møtt_opp`
- `prikk_gitt`

This is too much process state inside one many-to-many relationship.

Conceptually, this should be treated as a booking/registration entity, because it has its own lifecycle and attributes. In database design terms, once a relationship has multiple timestamps, status fields, and business behavior, it is usually better modeled as an associative entity.

### Consequences of the current design

- It becomes unclear whether a user who cancelled is still “participating”.
- It becomes unclear whether `møtt_opp` is allowed to be null.
- `prikk_gitt` is derivation-like business logic mixed into participation.
- Waiting list support is missing.

This is a significant issue because booking/attendance is central to the assignment and several use cases depend on it.

## 5. Waiting list support is missing

The assignment explicitly states that many sessions become full and end up with waiting lists. The current ER does not clearly model this.

You could argue that waiting list logic might be handled later in software, but for a strong part 1 submission it should at least be representable in the model, for example by:

- a booking entity with `status`
- optional `waitlist_position`
- timestamp ordering

Omitting this completely is a noticeable gap relative to the problem description.

## 6. Session capacity is duplicated without a visible constraint

`sal` has `kapasitet`, and `gruppetime` also has `kapasitet`.

The assignment says the number of places depends entirely on the hall. If so, storing capacity on both entities is redundant unless there is a documented reason, such as historical override. No such reason is shown.

This is a classic conceptual modeling issue:

- either session capacity is derived from the room
- or session capacity is stored separately because sessions may override room capacity

The current model seems to want both, but it does not state the rule.

That ambiguity can later lead to update anomalies and BCNF/normalization discussion problems.

## 7. Keys for equipment are under-specified

The current diagram shows `nr` for bikes and treadmills, but it is unclear whether:

- the number is unique only within a room, or
- unique within a center, or
- globally unique

The assignment text strongly suggests the numbering is local to the hall. If so, `nr` alone is not a sufficient conceptual key.

For a correct model, you need either:

- composite identity, e.g. `(room, equipment_no)`, or
- a surrogate key plus a `UNIQUE(room_id, equipment_no)` constraint

As drawn, this would likely lose points on key use and translation quality.

## 8. The sports-team area is not fully aligned with the requirement

The assignment says the system should register which groups of sports teams have reserved various halls during a week, and that students must be members of the sports team to use those hours.

The current diagram includes:

- `idrettslag`
- `idrettslag_gruppe`
- `tilhører`
- `medlem_av_idrettslag`
- `har_reservert`

This is a good start, but several things remain unclear:

- Is membership in the sports team time-bounded?
- Can one team belong to multiple groups?
- Does a reservation belong to a team or a team group?
- Is the reservation for a single occurrence or a recurring weekly slot?
- How are actual attendances to team reservations registered, if at all?

Because this part is not modeled crisply, it risks looking like an unfinished extension rather than an integrated part of the domain.

## 9. The `besøker_treningssenter` relationship is underspecified

The top-left relationship between user and center with `ankomst_tidspunkt` suggests self-training visits or check-ins. That is relevant to the assignment, but the current model leaves too much unspecified:

- Is a visit tied to a date or just a timestamp?
- Can a user visit multiple centers per day?
- Is departure time needed?
- Is this only for free training, or also for users attending group sessions?

At the moment it looks detached from the rest of the model.

## 10. Some important assignment constraints are not represented or documented

Not all constraints can or should be enforced in pure ER, but a strong submission should either represent them or explicitly document that they must be handled in software.

Important missing or weakly documented constraints include:

- session is published 48 hours before it starts
- cancellation deadline is 1 hour before start
- arrival deadline is 5 minutes before start
- three dots within 30 days lead to blacklisting
- instructor cannot teach overlapping sessions
- user cannot book overlapping sessions
- sports-team user must also be a valid SiT member

Some of these belong in application logic, but the current ER does not clearly separate “modeled in ER” from “must be implemented outside ER”.

Under the assignment rubric, that matters.

## Ambiguities and Naming Issues

## 1. `medlem` is semantically muddy

The assignment talks about users and memberships. The current diagram uses `bruker` and `medlem`, where `medlem` seems to mean a SiT membership record, not a person. That is understandable internally, but it is not immediately clear to a reader.

`medlemskap` would be clearer than `medlem`.

## 2. Language and naming style are not fully consistent

The repository mixes Norwegian and English across artifacts. The project brief allows either language, but not mixed language within the submission. For grading, the final document should choose one language and use it consistently.

There are also naming-style inconsistencies:

- `uke_nr` vs `starttid`
- `har_gruppetime` vs `deltar_på_time`
- singular/plural entity naming is inconsistent in some places

This is not the biggest problem, but it affects readability.

## 3. `reservasjonstid` is too generic

This entity name says “reservation time”, but in practice it seems to mean a reusable weekly time slot. A more precise name would make the model easier to understand.

## 4. `idrettslag_gruppe` needs a clearer real-world explanation

The term may be valid, but the ER alone does not explain whether this means:

- a category of sports teams,
- an umbrella organization,
- or the actual group that reserves the hall.

That should be clear from the diagram itself or from short textual assumptions.

## Over-modeling

The current design has some signs of over-modeling:

- `Dato` as an entity for opening/staffing
- multiple weak entities where normal entities would suffice
- separate reusable time-slot structures even where a direct date-time on session/reservation would be simpler

In DB1, over-modeling is a real risk because it makes the ER harder to read and harder to map cleanly to relations.

## Under-modeling

At the same time, some important things are under-modeled:

- booking as a first-class concept
- waiting list
- blacklisting period or at least a clean dot mechanism
- overlap constraints and temporal rules
- exact reservation semantics for sports-team room use

This combination is the main quality problem: some peripheral pieces are modeled in detail, while some core workflow concepts are still too implicit.

## What Would Likely Cost Points

If graded under the stated DB1 criteria, the current ER would likely lose points in the following areas.

### Structure and coherence

- Core concepts are present, but the time model and participation model are not cleanly organized.
- Some entities look notation-driven rather than domain-driven.

### Use of keys

- Weak entities are used where stronger key design would be clearer.
- Equipment keys are not clearly correct.
- Session identification is not convincingly specified.

### Use of restrictions

- Cardinalities and participation constraints are not communicated clearly enough.
- Important business rules are missing or only implied.

### Ease of understanding

- The diagram is ambitious, but not concise.
- A grader has to infer too much about time, booking states, and reservations.

## Overall Assessment

The current ER is not a bad starting point. It has good coverage of the problem space and includes several concepts that weaker submissions would skip. The main issue is not lack of effort; it is lack of conceptual discipline.

The redesign should aim for:

- fewer weak entities
- clearer keys
- a cleaner time model
- booking modeled as an associative entity with its own attributes
- explicit support for waiting list / no-show / dots
- clearer cardinalities and total/partial participation
- a simpler, more defensible sports-reservation structure

If those changes are made, the submission can move from “ambitious but messy” to “clear and strong”, which matters a lot in a graded DB1 deliverable.
