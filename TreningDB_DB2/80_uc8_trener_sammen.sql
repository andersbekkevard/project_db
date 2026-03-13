WITH samtrening AS (
    SELECT
        b1.epost AS epost_1,
        b2.epost AS epost_2,
        COUNT(*) AS antall_felles_treninger
    FROM deltar_på_time AS d1
    JOIN deltar_på_time AS d2
        ON d1.gruppetime_id = d2.gruppetime_id
       AND d1.bruker_id < d2.bruker_id
    JOIN bruker AS b1
        ON b1.id = d1.bruker_id
    JOIN bruker AS b2
        ON b2.id = d2.bruker_id
    WHERE d1.oppmøtt_tidspunkt IS NOT NULL
      AND d2.oppmøtt_tidspunkt IS NOT NULL
    GROUP BY b1.epost, b2.epost
)
SELECT
    epost_1,
    epost_2,
    antall_felles_treninger
FROM samtrening
ORDER BY antall_felles_treninger DESC, epost_1, epost_2;
