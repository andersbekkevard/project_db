# SiT Training Domain Research

Research date: 2026-03-08

## Scope and sources

Primary official sources used:

- https://www.sit.no/trening
- https://www.sit.no/trening/vare-treningssenter/gloshaugen-idrettsbygg
- https://www.sit.no/trening/vare-treningssenter/dragvoll-idrettssenter
- https://www.sit.no/trening/vare-treningssenter/moholt-treningssenter
- https://www.sit.no/trening/vare-treningssenter/oya-treningssenter
- https://www.sit.no/trening/vare-treningssenter/dmmh-treningsrom
- https://www.sit.no/trening/gruppetimer
- https://www.sit.no/trening/vare-regler-og-vilkar
- https://ibooking.sit.no/?location=307&type=7&week=%2B2+weeks
- https://ibooking.sit.no/?location=2825&type=7&week=%2B2+weeks

## Facts from official sources

### Business structure

- SiT Training is part of SiT and has a shared training area on `sit.no/trening` with center pages, group lesson pages, and booking/rules pages.
- The official training page lists Trondheim training centers/resources relevant here:
  - Gloshaugen idrettsbygg
  - Dragvoll idrettssenter
  - Moholt treningssenter
  - Oya treningssenter
  - DMMH treningsrom
- `ibooking.sit.no` exposes a location selector with these public booking-location IDs:
  - `306` = Gloshaugen
  - `307` = Dragvoll
  - `402` = DMMH
  - `540` = Moholt
  - `2825` = Oya treningssenter

### Center-level entities and facilities

Observed from official center pages:

| Center | Address | Opening hours | Staffing concept | Officially listed facilities |
| --- | --- | --- | --- | --- |
| Gloshaugen idrettsbygg | Chr. Frederiks gate 20, 7030 Trondheim | Monday-Sunday 05:00-00:00 | Staffed reception. Staffing hours published separately. | Individual training, group classes, weight training, hall, yoga, endurance, shower, sauna, wardrobes, staffed reception |
| Dragvoll idrettssenter | Loholt alle 81, 7049 Trondheim | Monday-Sunday 05:00-00:00 | Staffed reception. Staffing hours published separately. | Individual training, spinning, yoga, squash, hall, sauna, shower, wardrobes, staffed reception |
| Moholt treningssenter | Moholt allmenning 12, 7050 Trondheim | Monday-Sunday 05:00-00:00 | Unstaffed centre with key access | Individual training, unstaffed centre with key access, weight training, endurance |
| Oya treningssenter | Vangslundsgate 2, 7030 Trondheim | Monday-Sunday 05:00-00:00 | Unstaffed centre with key access | Group classes, individual training, endurance, weight training, yoga, klatring, spinning, hall, wardrobes, sauna, shower, unstaffed centre with key access |
| DMMH treningsrom | Thrond Nergaards veg 7, 7044 Trondheim | Monday-Sunday 06:00-23:30 | Appears unstaffed/no separate staffed reception shown | Individual training, unstaffed centre with key access, weight training, wardrobes, endurance |

### Opening-hours and staffing concepts

- SiT distinguishes at least two time concepts:
  - General opening hours for the center.
  - Separate staffing/reception hours for some centers.
- Gloshaugen and Dragvoll publish both center opening hours and staffing hours.
- Moholt and Oya show long opening hours but no separate staffing-hours block on the center pages.
- DMMH shows opening hours but no staffed-reception block.
- Gloshaugen and Dragvoll explicitly state that full access during all opening hours requires an active training membership.
- Gloshaugen has a special booking-terminal note in the rules page: it is the only center explicitly stated to have a physical booking terminal for check-in with a physical card.

### Group training offerings

- The official group lesson page exposes center filters with group-data for:
  - Dragvoll idrettssenter
  - Gloshaugen idrettsbygg
  - Oya treningssenter
  - plus non-Trondheim centers not relevant here
- Official group lesson categories shown on the page:
  - Styrke & Core
  - Spin
  - Body & Mind
  - Kondisjon
  - aktivHverdag
  - Dans
  - Utholdenhet & Styrke

### Spinning variants

Official spin lesson variants visible on `https://www.sit.no/trening/gruppetimer`:

| Variant | Official centers shown |
| --- | --- |
| Spin 4x4 | Oya treningssenter |
| Spin 8x3min | Oya treningssenter |
| Spin45 | Oya treningssenter, Dragvoll idrettssenter |
| Spin60 | Oya treningssenter |

This matters for ER modeling because:

- A lesson template/type can belong to one or many centers.
- Not every center offers every lesson template.
- Spin appears to have named variants, not just a single generic "spinning" activity.

### Booking, attendance, cancellation, waitlist, and blacklisting behavior

Observed from `https://www.sit.no/trening/vare-regler-og-vilkar`:

- Group classes can be booked in the Sit Trening app or when logged in on `sit.no`.
- Active membership is required to book group classes.
- Group-class booking opens 48 hours before start time.
- Group-class booking closes 5 minutes before start time.
- To avoid penalty, cancellation must happen no later than 60 minutes before class start.
- Check-in/attendance confirmation closes 5 minutes before class start.
- A center visit/check-in confirms all bookings in the coming 90 minutes.
- If a member books after already entering the center, the member can confirm in the app, provided there is a registered center visit within the last 90 minutes.
- If arriving later than 5 minutes before class start:
  - the place can be lost,
  - the place can go to someone on the waitlist,
  - the member receives a "not met"/no-show mark ("prikk").
- Waitlist behavior:
  - Members can join a waitlist for full classes.
  - If a place becomes available, the member can receive an SMS with a place.
  - A member can receive a place up to 5 minutes before class start.
  - Waitlists are "washed" 10 minutes before start: people still waiting who have not registered a center visit by then lose their queue position.
  - Members on the waitlist must also cancel no later than 60 minutes before class start if they cannot show up on short notice.
- Penalty / blacklisting behavior:
  - A no-show mark is given for late cancellation or failing to confirm/show up in time.
  - Three no-show marks within 30 days causes suspension from online booking until the first mark becomes older than 30 days.
  - Suspended users can still book via reception/phone/manual help according to the rules page.

### Hall and squash concepts relevant to modeling

Observed from the rules page:

- Squash and hall are treated as bookable resources, distinct from group classes.
- Squash:
  - Can be booked on `sit.no` or in the app.
  - Non-members can also book, but only via the website.
  - Price is stated per 30-minute slot.
  - Booking for a new day opens one week in advance at 21:00.
  - Max 90 minutes per day per member.
- Hall:
  - Members can self-book via website or app.
  - Non-members must contact SiT by email.
  - Booking opens 2 days in advance from 21:00.
  - Halls are free for members.

## ER-model-relevant data points

- `Center` is a strong entity.
- `Center` likely has:
  - center_id
  - name
  - address
  - city
  - open_time / close_time
  - access_mode
  - has_staffing_hours
- `FacilityType` or `Feature` is separate from `Center`.
- Some physical resources are bookable and need their own entities:
  - hall
  - squash court
  - spinning room
  - possibly climbing area
- Distinguish `LessonType` from `LessonOccurrence`.
  - Example lesson types: `Spin45`, `Spin60`, `Spin 4x4`, `Yoga1 | 60`.
  - An occurrence has date, start time, end time, instructor, center, room, capacity/status.
- A many-to-many relationship exists between `Center` and `LessonType`.
- `Instructor` is a separate entity; official booking pages show instructor names per class occurrence.
- Booking rules imply separate entities or status fields for:
  - booking
  - waitlist entry
  - attendance confirmation
  - no_show_mark
  - booking suspension / blacklist window
- Timing thresholds should be modeled as policy/config, not hardcoded in data rows:
  - booking_open_before = 48h for group classes
  - cancellation_deadline = 60m
  - attendance_deadline = 5m
  - waitlist_presence_check = 10m
  - no_show_ban_threshold = 3 marks / 30 days

## Assumptions and inferences

- "Unstaffed centre with key access" likely means members authenticate themselves for entry outside staffed hours, but the exact access-control mechanism is not fully described on every page.
- DMMH probably functions as a simpler gym room rather than a full sports center because the official page title is "treningsrom" and the listed facilities are narrower than Oya/Dragvoll/Gloshaugen.
- Oya likely has at least one dedicated spinning room because live booking pages for SiT use room labels such as `Spinningsal` for spin sessions at other centers, and Oya is listed with spinning as a facility plus several Oya-only spin variants. This is still an inference unless a specific Oya room label is observed.
- "Center visit" and "door/gate entry" appear to be operational events that should likely be modeled separately from attendance confirmation if the assignment wants realistic process semantics.

## Gaps / source limitations

- The public `ibooking.sit.no` endpoint for Oya (`location=2825`) returned an official server-side error on 2026-03-08 instead of a schedule page: `Fant ikke ibooking_memberreg_settings for cid: 1125 and studio_id = 2825`.
- Because of that, live public schedule rows for Oya could not be confirmed from the same official booking surface used for Dragvoll.
