```mermaid
erDiagram
    TRAINING_CENTER {
        int center_id PK
        string name UK
        string street_address
    }

    CENTER_OPENING_HOURS {
        int center_id PK,FK
        int weekday PK
        time opens_at PK
        time closes_at
    }

    CENTER_STAFFING_HOURS {
        int center_id PK,FK
        int weekday PK
        time staffed_from PK
        time staffed_to
    }

    FACILITY {
        int facility_id PK
        string name UK
        string description
    }

    CENTER_FACILITY {
        int center_id PK,FK
        int facility_id PK,FK
    }

    ROOM {
        int room_id PK
        int center_id FK
        string room_name
        string room_type
        int capacity
    }

    SPINNING_BIKE {
        int room_id PK,FK
        int bike_no PK
        string bike_model
        boolean has_bodybike_bluetooth
    }

    TREADMILL {
        int room_id PK,FK
        int treadmill_no PK
        string manufacturer
        decimal max_speed_kmh
        decimal max_incline_pct
    }

    ACTIVITY_TYPE {
        int activity_type_id PK
        string name UK
        string category
        string description
    }

    INSTRUCTOR {
        int instructor_id PK
        string first_name
    }

    APP_USER {
        int user_id PK
        string full_name
        string email UK
        string mobile UK
    }

    GROUP_CLASS {
        int session_id PK
        int activity_type_id FK
        int room_id FK
        int instructor_id FK
        datetime starts_at
        datetime ends_at
        datetime published_at
    }

    BOOKING {
        int user_id PK,FK
        int session_id PK,FK
        datetime booked_at
        datetime canceled_at
        datetime check_in_at
        string booking_status
        int waitlist_position
    }

    PENALTY_DOT {
        int dot_id PK
        int user_id FK
        int session_id FK
        datetime awarded_at
        string reason
    }

    SPORTS_TEAM {
        int team_id PK
        string name UK
    }

    SPORTS_TEAM_GROUP {
        int group_id PK
        int team_id FK
        string name
    }

    SPORTS_TEAM_MEMBERSHIP {
        int user_id PK,FK
        int group_id PK,FK
        date valid_from PK
        date valid_to
    }

    SPORTS_TEAM_RESERVATION {
        int group_id PK,FK
        int room_id PK,FK
        int weekday PK
        time starts_at PK
        time ends_at
    }

    TRAINING_CENTER ||--o{ CENTER_OPENING_HOURS : has
    TRAINING_CENTER ||--o{ CENTER_STAFFING_HOURS : has
    TRAINING_CENTER ||--o{ ROOM : contains

    TRAINING_CENTER ||--o{ CENTER_FACILITY : offers
    FACILITY ||--o{ CENTER_FACILITY : listed_in

    ROOM ||--o{ SPINNING_BIKE : contains
    ROOM ||--o{ TREADMILL : contains

    ACTIVITY_TYPE ||--o{ GROUP_CLASS : class_type
    INSTRUCTOR ||--o{ GROUP_CLASS : teaches
    ROOM ||--o{ GROUP_CLASS : hosts

    APP_USER ||--o{ BOOKING : makes
    GROUP_CLASS ||--o{ BOOKING : receives

    APP_USER ||--o{ PENALTY_DOT : receives
    GROUP_CLASS ||--o{ PENALTY_DOT : caused_by

    SPORTS_TEAM ||--o{ SPORTS_TEAM_GROUP : has
    APP_USER ||--o{ SPORTS_TEAM_MEMBERSHIP : holds
    SPORTS_TEAM_GROUP ||--o{ SPORTS_TEAM_MEMBERSHIP : includes

    SPORTS_TEAM_GROUP ||--o{ SPORTS_TEAM_RESERVATION : reserves
    ROOM ||--o{ SPORTS_TEAM_RESERVATION : reserved_in
```

## Kommentar til modellen
- Jeg bruker **én generell `ROOM`-entitet** i stedet for subtype-hierarki for `spinningsal`, `løpesal` og `flerbrukshall`.
- Dette gjør modellen enklere å lese og lettere å oversette til SQLite-tabeller.
- Spesialutstyr (`SPINNING_BIKE`, `TREADMILL`) modelleres som egne entiteter med komposittidentifikasjon innenfor rom.
- `BOOKING` er en assosiativ entitet mellom `APP_USER` og `GROUP_CLASS`, fordi relasjonen har egne attributter.
- `PENALTY_DOT` er skilt ut fra booking fordi den representerer en sanksjonshendelse som systemet må kunne telle over tid.
- Sportslag er skilt fra ordinære gruppetimer, siden dette er to ulike forretningsprosesser.
