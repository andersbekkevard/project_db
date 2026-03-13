PRAGMA foreign_keys = ON;
BEGIN;

INSERT INTO senter (id, navn, gateadresse) VALUES
    (1, 'Øya', 'Elgeseter gate 10'),
    (2, 'Gløshaugen', 'Høgskoleringen 1'),
    (3, 'Dragvoll', 'Loholt alle 81'),
    (4, 'Moholt', 'Moholt allmenning 12'),
    (5, 'DMMH', 'Thrond Nergaards veg 7');

INSERT INTO fasilitet (navn, ikon) VALUES
    ('Garderobe', 'locker'),
    ('Dusj', 'shower'),
    ('Badstue', 'sauna'),
    ('Spinningsal', 'bike'),
    ('Løpesal', 'treadmill');

INSERT INTO fasiliterer (senter_id, fasilitetsnavn) VALUES
    (1, 'Garderobe'),
    (1, 'Dusj'),
    (1, 'Badstue'),
    (1, 'Spinningsal'),
    (1, 'Løpesal');

INSERT INTO sal (senter_id, nr, kapasitet) VALUES
    (1, 1, 4),
    (1, 2, 6),
    (3, 1, 12);

INSERT INTO spinningsal (senter_id, sal_nr) VALUES
    (1, 1),
    (3, 1);

INSERT INTO løpesal (senter_id, sal_nr) VALUES
    (1, 2);

INSERT INTO senteråpningstid (dato, senter_id, start_tid, slutt_tid) VALUES
    ('2026-03-16', 1, '06:00:00', '23:00:00'),
    ('2026-03-17', 1, '06:00:00', '23:00:00'),
    ('2026-03-18', 1, '06:00:00', '23:00:00'),
    ('2026-03-16', 3, '06:00:00', '23:00:00'),
    ('2026-03-17', 3, '06:00:00', '23:00:00'),
    ('2026-03-18', 3, '06:00:00', '23:00:00');

INSERT INTO senterbemanning (dato, senter_id, start_tid, slutt_tid) VALUES
    ('2026-03-16', 1, '08:00:00', '21:00:00'),
    ('2026-03-17', 1, '08:00:00', '21:00:00'),
    ('2026-03-18', 1, '08:00:00', '21:00:00'),
    ('2026-03-16', 3, '08:00:00', '21:00:00'),
    ('2026-03-17', 3, '08:00:00', '21:00:00'),
    ('2026-03-18', 3, '08:00:00', '21:00:00');

INSERT INTO spinningsykkel (id, nr, type, har_bluetooth, senter_id, sal_nr) VALUES
    (1, 1, 'Keiser M3i', 1, 1, 1),
    (2, 2, 'Keiser M3i', 1, 1, 1),
    (3, 3, 'Keiser M3i', 1, 1, 1),
    (4, 4, 'Keiser M3i', 1, 1, 1);

INSERT INTO tredemølle (id, nr, produsent, maks_hastighet, maks_stigning, senter_id, sal_nr) VALUES
    (1, 1, 'Life Fitness', 20.0, 15.0, 1, 2);

INSERT INTO bruker (id, navn, epost, mobilnr, utestengt_til) VALUES
    (1, 'Johnny Student', 'johnny@stud.ntnu.no', '90000001', NULL),
    (2, 'Kari Student', 'kari@stud.ntnu.no', '90000002', NULL),
    (3, 'Ola Student', 'ola@stud.ntnu.no', '90000003', NULL),
    (4, 'Emma Student', 'emma@stud.ntnu.no', '90000004', NULL);

INSERT INTO medlem (id, starttid, gyldig_til, bruker_id) VALUES
    (1, '2026-01-01', '2026-12-31', 1),
    (2, '2026-01-01', '2026-12-31', 2),
    (3, '2026-01-01', '2026-12-31', 3),
    (4, '2026-01-01', '2026-12-31', 4);

INSERT INTO instruktør (id, fornavn) VALUES
    (1, 'Siri'),
    (2, 'Ada');

INSERT INTO aktivitetstype (navn, beskrivelse) VALUES
    ('Spin45', '45 minutters spinningtime'),
    ('Spin60', '60 minutters spinningtime'),
    ('Spinning Intervall', 'Spinning med intervaller');

INSERT INTO tidsblokk (starttid, ukedag) VALUES
    ('17:30:00', 1),
    ('19:30:00', 1),
    ('07:30:00', 2),
    ('18:30:00', 2),
    ('17:30:00', 3),
    ('19:30:00', 3);

-- GT1..GT6 er de låste forretningsnøklene som resten av bølgene bygger på.
INSERT INTO gruppetime (
    id,
    uke_nr,
    år,
    instruktør_id,
    aktivitetstype,
    senter_id,
    sal_nr,
    starttidspunkt,
    sluttidspunkt
) VALUES
    (1, 12, 2026, 1, 'Spin45', 1, 1, '2026-03-16 17:30:00', '2026-03-16 18:15:00'),
    (2, 12, 2026, 2, 'Spin60', 3, 1, '2026-03-16 19:30:00', '2026-03-16 20:30:00'),
    (3, 12, 2026, 2, 'Spin45', 3, 1, '2026-03-17 07:30:00', '2026-03-17 08:15:00'),
    (4, 12, 2026, 1, 'Spin60', 1, 1, '2026-03-17 18:30:00', '2026-03-17 19:30:00'),
    (5, 12, 2026, 1, 'Spin45', 1, 1, '2026-03-18 17:30:00', '2026-03-18 18:15:00'),
    (6, 12, 2026, 2, 'Spinning Intervall', 3, 1, '2026-03-18 19:30:00', '2026-03-18 20:30:00');

INSERT INTO time_skjer_i (gruppetime_id, tidsblokk_starttid, tidsblokk_ukedag) VALUES
    (1, '17:30:00', 1),
    (2, '19:30:00', 1),
    (3, '07:30:00', 2),
    (4, '18:30:00', 2),
    (5, '17:30:00', 3),
    (6, '19:30:00', 3);

INSERT INTO deltar_på_time (
    gruppetime_id,
    bruker_id,
    påmeldt_tidspunkt,
    oppmøtt_tidspunkt,
    avmeldt_tidspunkt,
    prikk_dato
) VALUES
    -- Johnny har tre prikker og én faktisk deltakelse før brukstilfellene kjøres.
    (1, 1, '2026-03-13 17:00:00', NULL, NULL, '2026-03-16'),
    (3, 1, '2026-03-14 07:00:00', NULL, NULL, '2026-03-17'),
    (5, 1, '2026-03-16 17:00:00', '2026-03-18 17:24:00', NULL, NULL),
    (6, 1, '2026-03-16 19:00:00', NULL, NULL, '2026-03-18'),

    -- GT4 starter med tre aktive bookinger slik at Johnny kan ta siste ledige plass i UC2.
    (4, 2, '2026-03-15 18:00:00', '2026-03-17 18:24:00', NULL, NULL),
    (4, 3, '2026-03-15 18:05:00', '2026-03-17 18:23:00', NULL, NULL),
    (4, 4, '2026-03-15 18:10:00', NULL, NULL, NULL),

    -- Kari og Ola deler førsteplass i mars og trener sammen tre ganger.
    (2, 2, '2026-03-14 19:00:00', '2026-03-16 19:24:00', NULL, NULL),
    (2, 3, '2026-03-14 19:05:00', '2026-03-16 19:25:00', NULL, NULL),
    (5, 2, '2026-03-16 17:05:00', '2026-03-18 17:23:00', NULL, NULL),
    (5, 3, '2026-03-16 17:10:00', '2026-03-18 17:22:00', NULL, NULL),

    -- Emma gir nok fellesdeltakelse til å bevise historikk og samtrening uten å vinne måneden.
    (2, 4, '2026-03-14 19:10:00', '2026-03-16 19:26:00', NULL, NULL),
    (5, 4, '2026-03-16 17:15:00', '2026-03-18 17:21:00', NULL, NULL);

COMMIT;
