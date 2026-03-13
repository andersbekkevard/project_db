DROP TABLE IF EXISTS temp.uc2_result;
DROP TABLE IF EXISTS temp.uc2_training_match;
DROP TABLE IF EXISTS temp.uc2_user_match;
DROP TABLE IF EXISTS temp.uc2_booking_context;
DROP TABLE IF EXISTS temp.uc2_insert_audit;

CREATE TEMP TABLE uc2_result (
    code TEXT NOT NULL,
    success INTEGER NOT NULL,
    message TEXT NOT NULL,
    bruker_id INTEGER,
    gruppetime_id INTEGER,
    changed_rows INTEGER NOT NULL DEFAULT 0,
    verified_rows INTEGER NOT NULL DEFAULT 0
);

CREATE TEMP TABLE uc2_training_match AS
SELECT
    gt.id AS gruppetime_id,
    gt.starttidspunkt,
    gt.senter_id,
    gt.sal_nr
FROM gruppetime AS gt
JOIN uc2_input AS i
    ON gt.aktivitetstype = i.aktivitet
   AND gt.starttidspunkt = i.tidspunkt;

CREATE TEMP TABLE uc2_user_match AS
SELECT
    b.id AS bruker_id,
    b.utestengt_til
FROM bruker AS b
JOIN uc2_input AS i
    ON b.epost = i.epost;

CREATE TEMP TABLE uc2_booking_context AS
SELECT
    i.epost,
    i.aktivitet,
    i.tidspunkt,
    i.referansetid,
    tm.gruppetime_id,
    um.bruker_id,
    tm.starttidspunkt,
    um.utestengt_til,
    s.kapasitet,
    (
        SELECT COUNT(*)
        FROM deltar_på_time AS d
        WHERE d.gruppetime_id = tm.gruppetime_id
          AND d.avmeldt_tidspunkt IS NULL
    ) AS aktive_bookinger,
    EXISTS (
        SELECT 1
        FROM deltar_på_time AS d
        WHERE d.gruppetime_id = tm.gruppetime_id
          AND d.bruker_id = um.bruker_id
    ) AS allerede_booket
FROM uc2_input AS i
JOIN uc2_training_match AS tm ON 1 = 1
JOIN uc2_user_match AS um ON 1 = 1
JOIN gruppetime AS gt
    ON gt.id = tm.gruppetime_id
JOIN sal AS s
    ON s.senter_id = gt.senter_id
   AND s.nr = gt.sal_nr
WHERE (SELECT COUNT(*) FROM uc2_training_match) = 1
  AND (SELECT COUNT(*) FROM uc2_user_match) = 1;

INSERT INTO uc2_result (code, success, message, bruker_id, gruppetime_id)
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM uc2_training_match) = 0 THEN 'UC2_TRENING_FINNES_IKKE'
        WHEN (SELECT COUNT(*) FROM uc2_training_match) > 1 THEN 'UC2_TRENING_TVETYDIG'
        WHEN (SELECT COUNT(*) FROM uc2_user_match) = 0 THEN 'UC2_BRUKER_FINNES_IKKE'
        WHEN (SELECT COUNT(*) FROM uc2_user_match) > 1 THEN 'UC2_BRUKER_TVETYDIG'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE allerede_booket = 1
        ) THEN 'UC2_ALLEREDE_BOOKET'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE utestengt_til IS NOT NULL
              AND datetime(utestengt_til) >= datetime(referansetid)
        ) THEN 'UC2_UTESTENGT'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE datetime(referansetid) > datetime(starttidspunkt)
        ) THEN 'UC2_FOR_SENT'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE aktive_bookinger >= kapasitet
        ) THEN 'UC2_FULLT'
        ELSE 'UC2_BOOKING_OPPRETTET'
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc2_training_match) = 1
         AND (SELECT COUNT(*) FROM uc2_user_match) = 1
         AND NOT EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE allerede_booket = 1
               OR (utestengt_til IS NOT NULL AND datetime(utestengt_til) >= datetime(referansetid))
               OR datetime(referansetid) > datetime(starttidspunkt)
               OR aktive_bookinger >= kapasitet
        ) THEN 1
        ELSE 0
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc2_training_match) = 0 THEN 'Fant ingen gruppetime med oppgitt aktivitet og starttidspunkt.'
        WHEN (SELECT COUNT(*) FROM uc2_training_match) > 1 THEN 'Fant flere gruppetimer med oppgitt aktivitet og starttidspunkt.'
        WHEN (SELECT COUNT(*) FROM uc2_user_match) = 0 THEN 'Fant ingen bruker med oppgitt epost.'
        WHEN (SELECT COUNT(*) FROM uc2_user_match) > 1 THEN 'Fant flere brukere med oppgitt epost.'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE allerede_booket = 1
        ) THEN 'Brukeren er allerede booket paa denne gruppetimen.'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE utestengt_til IS NOT NULL
              AND datetime(utestengt_til) >= datetime(referansetid)
        ) THEN 'Brukeren er utestengt paa referansetidspunktet.'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE datetime(referansetid) > datetime(starttidspunkt)
        ) THEN 'Booking kan ikke registreres etter at gruppetimen har startet.'
        WHEN EXISTS (
            SELECT 1
            FROM uc2_booking_context
            WHERE aktive_bookinger >= kapasitet
        ) THEN 'Gruppetimen er fullbooket.'
        ELSE 'Bookingen ble opprettet.'
    END,
    (SELECT bruker_id FROM uc2_booking_context LIMIT 1),
    (SELECT gruppetime_id FROM uc2_booking_context LIMIT 1);

INSERT INTO deltar_på_time (
    gruppetime_id,
    bruker_id,
    påmeldt_tidspunkt
)
SELECT
    gruppetime_id,
    bruker_id,
    referansetid
FROM uc2_booking_context
WHERE EXISTS (
    SELECT 1
    FROM uc2_result
    WHERE code = 'UC2_BOOKING_OPPRETTET'
);

CREATE TEMP TABLE uc2_insert_audit AS
SELECT
    changes() AS changed_rows,
    (
        SELECT COUNT(*)
        FROM deltar_på_time AS d
        JOIN uc2_booking_context AS c
            ON c.gruppetime_id = d.gruppetime_id
           AND c.bruker_id = d.bruker_id
        WHERE d.påmeldt_tidspunkt = c.referansetid
          AND d.oppmøtt_tidspunkt IS NULL
          AND d.avmeldt_tidspunkt IS NULL
    ) AS verified_rows;

UPDATE uc2_result
SET
    changed_rows = (SELECT changed_rows FROM uc2_insert_audit),
    verified_rows = (SELECT verified_rows FROM uc2_insert_audit),
    success = CASE
        WHEN code = 'UC2_BOOKING_OPPRETTET'
         AND (SELECT changed_rows FROM uc2_insert_audit) = 1
         AND (SELECT verified_rows FROM uc2_insert_audit) = 1 THEN 1
        WHEN code = 'UC2_BOOKING_OPPRETTET' THEN 0
        ELSE success
    END,
    code = CASE
        WHEN code = 'UC2_BOOKING_OPPRETTET'
         AND (SELECT changed_rows FROM uc2_insert_audit) <> 1 THEN 'UC2_FEIL_ENDRINGSANTALL'
        WHEN code = 'UC2_BOOKING_OPPRETTET'
         AND (SELECT verified_rows FROM uc2_insert_audit) <> 1 THEN 'UC2_FEIL_RADVERIFISERING'
        ELSE code
    END,
    message = CASE
        WHEN code = 'UC2_BOOKING_OPPRETTET'
         AND (SELECT changed_rows FROM uc2_insert_audit) <> 1 THEN 'Forventet aa opprette nøyaktig 1 bookingrad.'
        WHEN code = 'UC2_BOOKING_OPPRETTET'
         AND (SELECT verified_rows FROM uc2_insert_audit) <> 1 THEN 'Klarte ikke aa verifisere nøyaktig 1 bookingrad for valgt bruker og gruppetime.'
        ELSE message
    END;
