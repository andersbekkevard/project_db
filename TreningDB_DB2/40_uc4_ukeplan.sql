WITH parametre AS (
    SELECT
        date(:startdato) AS startdato,
        date(:startdato, '+7 days') AS sluttgrense,
        CAST(:uke AS INTEGER) AS uke
),
ukeplan AS (
    SELECT
        gt.starttidspunkt AS starttidspunkt,
        gt.sluttidspunkt AS sluttidspunkt,
        gt.aktivitetstype AS aktivitet,
        s.navn AS senter,
        gt.sal_nr AS salnummer,
        i.fornavn AS instruktør
    FROM gruppetime AS gt
    JOIN senter AS s
        ON s.id = gt.senter_id
    JOIN instruktør AS i
        ON i.id = gt.instruktør_id
    CROSS JOIN parametre AS p
    WHERE gt.uke_nr = p.uke
      AND date(gt.starttidspunkt) >= p.startdato
      AND date(gt.starttidspunkt) < p.sluttgrense
)
SELECT
    starttidspunkt,
    sluttidspunkt,
    aktivitet,
    senter,
    salnummer,
    instruktør
FROM ukeplan
ORDER BY datetime(starttidspunkt), senter, aktivitet, salnummer;
