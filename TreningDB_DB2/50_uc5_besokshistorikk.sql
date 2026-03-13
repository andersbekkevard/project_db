WITH johnny AS (
    SELECT id
    FROM bruker
    WHERE epost = 'johnny@stud.ntnu.no'
),
historikk AS (
    SELECT DISTINCT
        gt.aktivitetstype AS "trening",
        s.navn AS "treningssenter",
        gt.starttidspunkt AS "dato_tid"
    FROM deltar_på_time AS d
    JOIN johnny AS j
        ON j.id = d.bruker_id
    JOIN gruppetime AS gt
        ON gt.id = d.gruppetime_id
    JOIN senter AS s
        ON s.id = gt.senter_id
    WHERE d.oppmøtt_tidspunkt IS NOT NULL
      AND datetime(gt.starttidspunkt) >= datetime('2026-01-01 00:00:00')
)
SELECT
    trening AS "trening",
    treningssenter AS "treningssenter",
    dato_tid AS "dato_tid"
FROM historikk
ORDER BY datetime(dato_tid), trening, treningssenter;
