DROP TABLE IF EXISTS temp.uc6_result;
DROP TABLE IF EXISTS temp.uc6_user_match;
DROP TABLE IF EXISTS temp.uc6_recent_prikk;
DROP TABLE IF EXISTS temp.uc6_blacklist_context;
DROP TABLE IF EXISTS temp.uc6_update_audit;

CREATE TEMP TABLE uc6_result (
    code TEXT NOT NULL,
    success INTEGER NOT NULL,
    message TEXT NOT NULL,
    bruker_id INTEGER,
    changed_rows INTEGER NOT NULL DEFAULT 0,
    verified_rows INTEGER NOT NULL DEFAULT 0,
    recent_prikk_count INTEGER NOT NULL DEFAULT 0,
    beregnet_utestengt_til TEXT
);

CREATE TEMP TABLE uc6_user_match AS
SELECT
    b.id AS bruker_id
FROM bruker AS b
JOIN uc6_input AS i
    ON b.epost = i.epost;

CREATE TEMP TABLE uc6_recent_prikk AS
SELECT
    d.prikk_dato
FROM deltar_på_time AS d
JOIN uc6_user_match AS u
    ON u.bruker_id = d.bruker_id
CROSS JOIN uc6_input AS i
WHERE (SELECT COUNT(*) FROM uc6_user_match) = 1
  AND d.prikk_dato IS NOT NULL
  AND date(d.prikk_dato) BETWEEN date(i.referansetid, '-30 days') AND date(i.referansetid)
ORDER BY date(d.prikk_dato);

CREATE TEMP TABLE uc6_blacklist_context AS
SELECT
    i.epost,
    i.referansetid,
    u.bruker_id,
    (SELECT COUNT(*) FROM uc6_recent_prikk) AS recent_prikk_count,
    (
        SELECT MIN(prikk_dato)
        FROM uc6_recent_prikk
    ) AS forste_prikk_dato,
    datetime(
        date(
            (
                SELECT MIN(prikk_dato)
                FROM uc6_recent_prikk
            ),
            '+31 days'
        )
    ) AS beregnet_utestengt_til
FROM uc6_input AS i
JOIN uc6_user_match AS u ON 1 = 1
WHERE (SELECT COUNT(*) FROM uc6_user_match) = 1;

INSERT INTO uc6_result (
    code,
    success,
    message,
    bruker_id,
    recent_prikk_count,
    beregnet_utestengt_til
)
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM uc6_user_match) = 0 THEN 'UC6_BRUKER_FINNES_IKKE'
        WHEN (SELECT COUNT(*) FROM uc6_user_match) > 1 THEN 'UC6_BRUKER_TVETYDIG'
        WHEN (SELECT COUNT(*) FROM uc6_recent_prikk) < 3 THEN 'UC6_FOR_FAA_PRIKK'
        ELSE 'UC6_SVARTELISTET'
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc6_user_match) = 1
         AND (SELECT COUNT(*) FROM uc6_recent_prikk) >= 3 THEN 1
        ELSE 0
    END,
    CASE
        WHEN (SELECT COUNT(*) FROM uc6_user_match) = 0 THEN 'Fant ingen bruker med oppgitt epost.'
        WHEN (SELECT COUNT(*) FROM uc6_user_match) > 1 THEN 'Fant flere brukere med oppgitt epost.'
        WHEN (SELECT COUNT(*) FROM uc6_recent_prikk) < 3 THEN 'Brukeren har ikke minst 3 prikker i de siste 30 dagene.'
        ELSE 'Brukeren ble svartelistet.'
    END,
    (SELECT bruker_id FROM uc6_blacklist_context LIMIT 1),
    COALESCE((SELECT recent_prikk_count FROM uc6_blacklist_context LIMIT 1), 0),
    (SELECT beregnet_utestengt_til FROM uc6_blacklist_context LIMIT 1);

UPDATE bruker
SET utestengt_til = (
    SELECT beregnet_utestengt_til
    FROM uc6_blacklist_context
)
WHERE EXISTS (
    SELECT 1
    FROM uc6_result
    WHERE code = 'UC6_SVARTELISTET'
)
  AND id = (
    SELECT bruker_id
    FROM uc6_blacklist_context
);

CREATE TEMP TABLE uc6_update_audit AS
SELECT
    changes() AS changed_rows,
    (
        SELECT COUNT(*)
        FROM bruker AS b
        JOIN uc6_blacklist_context AS c
            ON c.bruker_id = b.id
        WHERE datetime(b.utestengt_til) = datetime(c.beregnet_utestengt_til)
    ) AS verified_rows;

UPDATE uc6_result
SET
    changed_rows = (SELECT changed_rows FROM uc6_update_audit),
    verified_rows = (SELECT verified_rows FROM uc6_update_audit),
    success = CASE
        WHEN code = 'UC6_SVARTELISTET'
         AND (SELECT changed_rows FROM uc6_update_audit) = 1
         AND (SELECT verified_rows FROM uc6_update_audit) = 1 THEN 1
        WHEN code = 'UC6_SVARTELISTET' THEN 0
        ELSE success
    END,
    code = CASE
        WHEN code = 'UC6_SVARTELISTET'
         AND (SELECT changed_rows FROM uc6_update_audit) <> 1 THEN 'UC6_FEIL_ENDRINGSANTALL'
        WHEN code = 'UC6_SVARTELISTET'
         AND (SELECT verified_rows FROM uc6_update_audit) <> 1 THEN 'UC6_FEIL_RADVERIFISERING'
        ELSE code
    END,
    message = CASE
        WHEN code = 'UC6_SVARTELISTET'
         AND (SELECT changed_rows FROM uc6_update_audit) <> 1 THEN 'Forventet aa oppdatere nøyaktig 1 bruker ved svartelisting.'
        WHEN code = 'UC6_SVARTELISTET'
         AND (SELECT verified_rows FROM uc6_update_audit) <> 1 THEN 'Klarte ikke aa verifisere nøyaktig 1 svartelistet bruker.'
        ELSE message
    END;
