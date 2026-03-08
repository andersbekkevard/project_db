PRAGMA foreign_keys = ON;

CREATE TABLE training_center (
    center_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    street_address TEXT NOT NULL
);

CREATE TABLE center_opening_hours (
    center_id INTEGER NOT NULL,
    weekday INTEGER NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    opens_at TEXT NOT NULL CHECK (opens_at GLOB '[0-2][0-9]:[0-5][0-9]'),
    closes_at TEXT NOT NULL CHECK (closes_at GLOB '[0-2][0-9]:[0-5][0-9]'),
    PRIMARY KEY (center_id, weekday, opens_at),
    FOREIGN KEY (center_id) REFERENCES training_center(center_id),
    CHECK (time(opens_at) < time(closes_at))
);

CREATE TABLE center_staffing_hours (
    center_id INTEGER NOT NULL,
    weekday INTEGER NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    staffed_from TEXT NOT NULL CHECK (staffed_from GLOB '[0-2][0-9]:[0-5][0-9]'),
    staffed_to TEXT NOT NULL CHECK (staffed_to GLOB '[0-2][0-9]:[0-5][0-9]'),
    PRIMARY KEY (center_id, weekday, staffed_from),
    FOREIGN KEY (center_id) REFERENCES training_center(center_id),
    CHECK (time(staffed_from) < time(staffed_to))
);

CREATE TABLE facility (
    facility_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE center_facility (
    center_id INTEGER NOT NULL,
    facility_id INTEGER NOT NULL,
    PRIMARY KEY (center_id, facility_id),
    FOREIGN KEY (center_id) REFERENCES training_center(center_id),
    FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
);

CREATE TABLE room (
    room_id INTEGER PRIMARY KEY,
    center_id INTEGER NOT NULL,
    room_name TEXT NOT NULL,
    room_type TEXT NOT NULL CHECK (
        room_type IN (
            'spinning_room',
            'running_room',
            'group_studio',
            'sports_hall',
            'gym_area',
            'multipurpose_hall',
            'other'
        )
    ),
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    FOREIGN KEY (center_id) REFERENCES training_center(center_id),
    UNIQUE (center_id, room_name)
);

CREATE TABLE spinning_bike (
    room_id INTEGER NOT NULL,
    bike_no INTEGER NOT NULL CHECK (bike_no > 0),
    bike_model TEXT,
    has_bodybike_bluetooth INTEGER NOT NULL DEFAULT 0 CHECK (has_bodybike_bluetooth IN (0, 1)),
    PRIMARY KEY (room_id, bike_no),
    FOREIGN KEY (room_id) REFERENCES room(room_id)
);

CREATE TABLE treadmill (
    room_id INTEGER NOT NULL,
    treadmill_no INTEGER NOT NULL CHECK (treadmill_no > 0),
    manufacturer TEXT NOT NULL,
    max_speed_kmh REAL NOT NULL CHECK (max_speed_kmh > 0),
    max_incline_pct REAL NOT NULL CHECK (max_incline_pct >= 0),
    PRIMARY KEY (room_id, treadmill_no),
    FOREIGN KEY (room_id) REFERENCES room(room_id)
);

CREATE TABLE activity_type (
    activity_type_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE instructor (
    instructor_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL
);

CREATE TABLE app_user (
    user_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    mobile TEXT NOT NULL UNIQUE
);

CREATE TABLE group_class (
    session_id INTEGER PRIMARY KEY,
    activity_type_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    instructor_id INTEGER NOT NULL,
    starts_at TEXT NOT NULL,
    ends_at TEXT NOT NULL,
    published_at TEXT NOT NULL,
    FOREIGN KEY (activity_type_id) REFERENCES activity_type(activity_type_id),
    FOREIGN KEY (room_id) REFERENCES room(room_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id),
    UNIQUE (room_id, starts_at),
    CHECK (datetime(starts_at) IS NOT NULL),
    CHECK (datetime(ends_at) IS NOT NULL),
    CHECK (datetime(published_at) IS NOT NULL),
    CHECK (datetime(ends_at) > datetime(starts_at)),
    CHECK (datetime(published_at) = datetime(starts_at, '-48 hours'))
);

CREATE TABLE booking (
    user_id INTEGER NOT NULL,
    session_id INTEGER NOT NULL,
    booked_at TEXT NOT NULL,
    canceled_at TEXT,
    check_in_at TEXT,
    booking_status TEXT NOT NULL CHECK (
        booking_status IN ('confirmed', 'waitlisted', 'canceled_in_time', 'canceled_late', 'checked_in', 'no_show')
    ),
    waitlist_position INTEGER,
    PRIMARY KEY (user_id, session_id),
    FOREIGN KEY (user_id) REFERENCES app_user(user_id),
    FOREIGN KEY (session_id) REFERENCES group_class(session_id),
    CHECK (datetime(booked_at) IS NOT NULL),
    CHECK (canceled_at IS NULL OR datetime(canceled_at) IS NOT NULL),
    CHECK (check_in_at IS NULL OR datetime(check_in_at) IS NOT NULL),
    CHECK (waitlist_position IS NULL OR waitlist_position > 0),
    CHECK (
        (booking_status = 'waitlisted' AND waitlist_position IS NOT NULL)
        OR
        (booking_status <> 'waitlisted' AND waitlist_position IS NULL)
    ),
    CHECK (
        (booking_status IN ('canceled_in_time', 'canceled_late') AND canceled_at IS NOT NULL)
        OR
        (booking_status NOT IN ('canceled_in_time', 'canceled_late') AND canceled_at IS NULL)
    ),
    CHECK (
        (booking_status = 'checked_in' AND check_in_at IS NOT NULL)
        OR
        (booking_status <> 'checked_in' AND check_in_at IS NULL)
    )
);

CREATE TABLE penalty_dot (
    dot_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    session_id INTEGER NOT NULL,
    awarded_at TEXT NOT NULL,
    reason TEXT NOT NULL DEFAULT 'no_show' CHECK (reason IN ('no_show', 'late_cancel')),
    FOREIGN KEY (user_id) REFERENCES app_user(user_id),
    FOREIGN KEY (session_id) REFERENCES group_class(session_id),
    UNIQUE (user_id, session_id),
    CHECK (datetime(awarded_at) IS NOT NULL)
);

CREATE TABLE sports_team (
    team_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE sports_team_group (
    group_id INTEGER PRIMARY KEY,
    team_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    FOREIGN KEY (team_id) REFERENCES sports_team(team_id),
    UNIQUE (team_id, name)
);

CREATE TABLE sports_team_membership (
    user_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    valid_from TEXT NOT NULL,
    valid_to TEXT,
    PRIMARY KEY (user_id, group_id, valid_from),
    FOREIGN KEY (user_id) REFERENCES app_user(user_id),
    FOREIGN KEY (group_id) REFERENCES sports_team_group(group_id),
    CHECK (date(valid_from) IS NOT NULL),
    CHECK (valid_to IS NULL OR date(valid_to) IS NOT NULL),
    CHECK (valid_to IS NULL OR date(valid_from) <= date(valid_to))
);

CREATE TABLE sports_team_reservation (
    group_id INTEGER NOT NULL,
    room_id INTEGER NOT NULL,
    weekday INTEGER NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    starts_at TEXT NOT NULL CHECK (starts_at GLOB '[0-2][0-9]:[0-5][0-9]'),
    ends_at TEXT NOT NULL CHECK (ends_at GLOB '[0-2][0-9]:[0-5][0-9]'),
    PRIMARY KEY (group_id, room_id, weekday, starts_at),
    FOREIGN KEY (group_id) REFERENCES sports_team_group(group_id),
    FOREIGN KEY (room_id) REFERENCES room(room_id),
    CHECK (time(starts_at) < time(ends_at))
);

-- Restriksjoner som må håndteres i applikasjon eller triggere:
-- 1) Ingen overlappende group_class for samme instructor
-- 2) Ingen overlappende booking for samme user
-- 3) confirmed bookings kan ikke overstige room.capacity for gruppetimen
-- 4) booking nektes ved >= 3 prikker siste 30 dager
-- 5) avbestilling senest 1 time før starts_at
-- 6) check-in senest 5 minutter før starts_at for å telle som gyldig oppmøte
-- 7) sports_team_reservation må ikke kollidere med andre reservasjoner eller gruppetimer i samme room
