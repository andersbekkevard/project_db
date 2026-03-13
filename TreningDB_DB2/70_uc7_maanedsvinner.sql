WITH parametre AS (
    SELECT
        date(:maaned || '-01') AS måned_start,
        date(:maaned || '-01', '+1 month') AS neste_måned
),
deltakelser AS (
    SELECT
        b.epost AS epost,
        b.navn AS navn,
        COUNT(*) AS antall_gruppetimer
    FROM deltar_på_time AS d
    JOIN bruker AS b
        ON b.id = d.bruker_id
    JOIN gruppetime AS gt
        ON gt.id = d.gruppetime_id
    CROSS JOIN parametre AS p
    WHERE d.oppmøtt_tidspunkt IS NOT NULL
      AND datetime(gt.starttidspunkt) >= datetime(p.måned_start)
      AND datetime(gt.starttidspunkt) < datetime(p.neste_måned)
    GROUP BY b.id, b.epost, b.navn
),
toppskår AS (
    SELECT MAX(antall_gruppetimer) AS høyeste_antall
    FROM deltakelser
)
SELECT
    d.epost,
    d.navn,
    d.antall_gruppetimer
FROM deltakelser AS d
JOIN toppskår AS t
    ON d.antall_gruppetimer = t.høyeste_antall
ORDER BY d.epost;
