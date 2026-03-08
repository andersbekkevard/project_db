# Spinning Session Candidates for 2026-03-16 to 2026-03-18

Research date: 2026-03-08

## Scope

- Centers requested: Oya and Dragvoll
- Dates requested: 2026-03-16, 2026-03-17, 2026-03-18
- Goal: structured candidate session data for ER/data modeling

## Source status

- Dragvoll data below is real public schedule data observed from:
  - https://ibooking.sit.no/?location=307&type=7&week=%2B2+weeks
- Oya live data was not publicly retrievable on 2026-03-08 because the official endpoint returned:
  - `Feil: Fant ikke ibooking_memberreg_settings for cid: 1125 and studio_id = 2825`
  - Source URL attempted: https://ibooking.sit.no/?location=2825&type=7&week=%2B2+weeks
- Therefore:
  - Dragvoll rows are marked `real_official`
  - Oya rows are marked `plausible_mock`

## Candidate session rows

| source_status | date | weekday | center_name | booking_location_id | activity_name | activity_family | start_time | end_time | instructor_name | room_name | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| real_official | 2026-03-16 | Monday | Dragvoll idrettssenter | 307 | Spin 4x4 | Spin | 16:30 | 17:15 | Siri Mostad Larsen | NULL | Real public row from `ibooking.sit.no`; room label was not visible in captured HTML block |
| real_official | 2026-03-18 | Wednesday | Dragvoll idrettssenter | 307 | Spin45 | Spin | 16:30 | 17:15 | Ada Jing Rasmussen | Spinningsal | Real public row from `ibooking.sit.no` |
| plausible_mock | 2026-03-16 | Monday | Oya treningssenter | 2825 | Spin60 | Spin | 07:15 | 08:15 | Plausible Instructor A | Spinningsal | Mock row. Chosen to fit Oya's officially listed spin offering and common SiT morning/afternoon scheduling patterns |
| plausible_mock | 2026-03-17 | Tuesday | Oya treningssenter | 2825 | Spin 8x3min | Spin | 16:30 | 17:15 | Plausible Instructor B | Spinningsal | Mock row. Variant is official for Oya on `sit.no/trening/gruppetimer` |
| plausible_mock | 2026-03-18 | Wednesday | Oya treningssenter | 2825 | Spin45 | Spin | 17:30 | 18:15 | Plausible Instructor C | Spinningsal | Mock row. Variant is official for Oya and Dragvoll on `sit.no/trening/gruppetimer` |

## Minimal entity candidates

- `center(center_id, name, booking_location_id)`
- `room(room_id, center_id, name, room_type)`
- `lesson_type(lesson_type_id, name, category)`
- `instructor(instructor_id, full_name)`
- `lesson_occurrence(occurrence_id, lesson_type_id, center_id, room_id, instructor_id, start_ts, end_ts, source_status)`

## Assumptions behind the mock Oya rows

- Oya officially offers spinning plus the variants `Spin 4x4`, `Spin 8x3min`, `Spin45`, and `Spin60` on the group lesson page.
- Oya is a larger center than Moholt/DMMH and officially lists both group classes and spinning, so at least one spin-capable room is plausible.
- Start times were chosen to stay consistent with observed SiT-style scheduling blocks such as 45-minute and 60-minute sessions.
- Instructor names for mock rows are placeholders only and should not be treated as factual.
