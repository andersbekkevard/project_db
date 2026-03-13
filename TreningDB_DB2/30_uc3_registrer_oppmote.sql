DROP TABLE IF EXISTS temp.uc3_result;
DROP TABLE IF EXISTS temp.uc3_training_match;
DROP TABLE IF EXISTS temp.uc3_user_match;
DROP TABLE IF EXISTS temp.uc3_booking_context;
DROP TABLE IF EXISTS temp.uc3_update_audit;

CREATE TEMP TABLE uc3_result (
    code TEXT NOT NULL,
    success INTEGER NOT NULL,
    message TEXT NOT NULL,
    bruker_id INTEGER,
    gruppetime_id INTEGER,
    changed_rows INTEGER NOT NULL DEFAULT 0,
    verified_rows INTEGER NOT NULL DEFAULT 0
);

CREATE TEMP TABLE uc3_training_match AS
SELECT
    gt.id AS gruppetime_id,
    gt.starttidspunkt
FROM gruppetime AS gt
JOIN uc3_input AS i
    ON gt.aktivitetstype = i.aktivitet
   AND gt.starttidspunkt = i.tidspunkt;

CREATE TEMP TABLE uc3_user_match AS
SELECT
    b.id AS bruker_id
FROM bruker AS b
JOIN uc3_input AS i
    ON b.epost = i.epost;

CREATE TEMP TABLE uc3_booking_context AS
SELECT
    i.epost,
    i.aktivitet,
    i.tidspunkt,
    i.referansetid,
    tm.gruppetime_id,
    um.bruker_id,
    tm.starttidspunkt,
    d.oppmøtt_tidspunkt,
    d.avmeldt_tidspunkt
FROM uc3_input AS i
JOIN uc3_training_match AS tm ON 1 = 1
JOIN uc3_user_match AS um ON 1 = 1
LEFT JOIN deltar_på_time AS d
    ON d.gruppetime_id = tm.gruppetime_id
   AND d.bruker_id = um.bruker_id
WHERE (SELECT COUNT(*) FROM uc3_training_match) = 1
  AND (SELECT COUNT(*) FROM uc3_user_match) = 1;

INSERT INTO uc3_result (code, success, message, bruker_id, gruppetime_id)
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM uc3_training_match) = 0 THEN 'UC3_TRENING_FINNES_IKKE'
        WHEN (SELECT COUNT(*) FROM uc3_training_match) > 1 THEN 'UC3_TRENING_TVETYDIG'
        WHEN (SELECT COUNT(*) FROM uc3_user_match) = 0 THEN 'UC3_BRUKER_FINNES_IKKE'
        WHEN (SELECT COUNT(*) FROM uc3_user_match) > 1 THEN 'UC3_BRUKER_TVETYDIG'
        WHEN EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE oppmøtt_tidspunkt IS NOT NULL
              AND avmeldt_tidspunkt IS NULL
        ) THEN 'UC3_ALLEREDE_REGISTRERT'
        WHEN NOT EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE avmeldt_tidspunkt IS NULL
              AND bruker_id IS NOT NULL
              AND gruppetime_id IS NOT NULL
        ) THEN 'UC3_BOOKING_FINNES_IKKE'
        WHEN EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE datetime(referansetid) > datetime(starttidspunkt, '-5 minutes')
        ) THEN 'UC3_FOR_SENT'
        ELSE 'UC3_OPPMOTE_REGISTRERT'
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc3_training_match) = 1
         AND (SELECT COUNT(*) FROM uc3_user_match) = 1
         AND EXISTS (
            SELECT 1
            FROM uc3_booking_context
              WHERE avmeldt_tidspunkt IS NULL
              AND oppmøtt_tidspunkt IS NULL
         )
         AND NOT EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE datetime(referansetid) > datetime(starttidspunkt, '-5 minutes')
         ) THEN 1
        ELSE 0
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc3_training_match) = 0 THEN 'Fant ingen gruppetime med oppgitt aktivitet og starttidspunkt.'
        WHEN (SELECT COUNT(*) FROM uc3_training_match) > 1 THEN 'Fant flere gruppetimer med oppgitt aktivitet og starttidspunkt.'
        WHEN (SELECT COUNT(*) FROM uc3_user_match) = 0 THEN 'Fant ingen bruker med oppgitt epost.'
        WHEN (SELECT COUNT(*) FROM uc3_user_match) > 1 THEN 'Fant flere brukere med oppgitt epost.'
        WHEN EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE oppmøtt_tidspunkt IS NOT NULL
              AND avmeldt_tidspunkt IS NULL
        ) THEN 'Oppmote er allerede registrert for denne bookingen.'
        WHEN NOT EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE avmeldt_tidspunkt IS NULL
              AND bruker_id IS NOT NULL
              AND gruppetime_id IS NOT NULL
        ) THEN 'Fant ingen aktiv booking for brukeren paa valgt gruppetime.'
        WHEN EXISTS (
            SELECT 1
            FROM uc3_booking_context
            WHERE datetime(referansetid) > datetime(starttidspunkt, '-5 minutes')
        ) THEN 'Oppmote maa registreres senest 5 minutter foer start.'
        ELSE 'Oppmote ble registrert.'
    END,
    (SELECT bruker_id FROM uc3_booking_context LIMIT 1),
    (SELECT gruppetime_id FROM uc3_booking_context LIMIT 1);

UPDATE deltar_på_time
SET oppmøtt_tidspunkt = (
    SELECT referansetid
    FROM uc3_booking_context
)
WHERE EXISTS (
    SELECT 1
    FROM uc3_result
    WHERE code = 'UC3_OPPMOTE_REGISTRERT'
)
  AND gruppetime_id = (
    SELECT gruppetime_id
    FROM uc3_booking_context
)
  AND bruker_id = (
    SELECT bruker_id
    FROM uc3_booking_context
)
  AND oppmøtt_tidspunkt IS NULL;

CREATE TEMP TABLE uc3_update_audit AS
SELECT
    changes() AS changed_rows,
    (
        SELECT COUNT(*)
        FROM deltar_på_time AS d
        JOIN uc3_booking_context AS c
            ON c.gruppetime_id = d.gruppetime_id
           AND c.bruker_id = d.bruker_id
        WHERE d.oppmøtt_tidspunkt = c.referansetid
    ) AS verified_rows;

UPDATE uc3_result
SET
    changed_rows = (SELECT changed_rows FROM uc3_update_audit),
    verified_rows = (SELECT verified_rows FROM uc3_update_audit),
    success = CASE
        WHEN code = 'UC3_OPPMOTE_REGISTRERT'
         AND (SELECT changed_rows FROM uc3_update_audit) = 1
         AND (SELECT verified_rows FROM uc3_update_audit) = 1 THEN 1
        WHEN code = 'UC3_OPPMOTE_REGISTRERT' THEN 0
        ELSE success
    END,
    code = CASE
        WHEN code = 'UC3_OPPMOTE_REGISTRERT'
         AND (SELECT changed_rows FROM uc3_update_audit) <> 1 THEN 'UC3_FEIL_ENDRINGSANTALL'
        WHEN code = 'UC3_OPPMOTE_REGISTRERT'
         AND (SELECT verified_rows FROM uc3_update_audit) <> 1 THEN 'UC3_FEIL_RADVERIFISERING'
        ELSE code
    END,
    message = CASE
        WHEN code = 'UC3_OPPMOTE_REGISTRERT'
         AND (SELECT changed_rows FROM uc3_update_audit) <> 1 THEN 'Forventet aa oppdatere nøyaktig 1 bookingrad.'
        WHEN code = 'UC3_OPPMOTE_REGISTRERT'
         AND (SELECT verified_rows FROM uc3_update_audit) <> 1 THEN 'Klarte ikke aa verifisere nøyaktig 1 oppmoterad for valgt booking.'
        ELSE message
    END;
