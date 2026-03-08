PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS bruker;
DROP TABLE IF EXISTS idrettslag;
DROP TABLE IF EXISTS medlem;
DROP TABLE IF EXISTS medlem_av;
DROP TABLE IF EXISTS idrettslag_gruppe;
DROP TABLE IF EXISTS tidsblokk;
DROP TABLE IF EXISTS senter;
DROP TABLE IF EXISTS sal;
DROP TABLE IF EXISTS spinningsal;
DROP TABLE IF EXISTS løpesal;
DROP TABLE IF EXISTS flerbrukshall;
DROP TABLE IF EXISTS fasilitet;
DROP TABLE IF EXISTS fasiliterer;
DROP TABLE IF EXISTS instruktør;
DROP TABLE IF EXISTS aktivitetstype;
DROP TABLE IF EXISTS gruppereservasjon;
DROP TABLE IF EXISTS gruppetime;
DROP TABLE IF EXISTS senterbesøk;
DROP TABLE IF EXISTS senteråpningstid;
DROP TABLE IF EXISTS senterbemanning;
DROP TABLE IF EXISTS spinningsykkel;
DROP TABLE IF EXISTS tredemølle;
DROP TABLE IF EXISTS time_skjer_i;
DROP TABLE IF EXISTS deltar_på_time;

CREATE TABLE IF NOT EXISTS bruker (
    id INTEGER PRIMARY KEY,
    navn TEXT NOT NULL,
    epost TEXT NOT NULL,
    mobilnr TEXT NOT NULL,
    utestengt_til TEXT,
    CHECK (utestengt_til IS NULL OR datetime(utestengt_til) IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS idrettslag (
    id INTEGER PRIMARY KEY,
    navn TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS medlem (
    id INTEGER PRIMARY KEY,
    starttid TEXT NOT NULL,
    gyldig_til TEXT NOT NULL,
    bruker_id INTEGER NOT NULL,
    FOREIGN KEY (bruker_id) REFERENCES bruker(id),
    CHECK (date(starttid) IS NOT NULL),
    CHECK (date(gyldig_til) IS NOT NULL),
    CHECK (date(gyldig_til) >= date(starttid))
);

CREATE TABLE IF NOT EXISTS medlem_av (
    bruker_id INTEGER NOT NULL,
    idrettslag_id INTEGER NOT NULL,
    starttid TEXT NOT NULL,
    PRIMARY KEY (bruker_id, idrettslag_id),
    FOREIGN KEY (bruker_id) REFERENCES bruker(id),
    FOREIGN KEY (idrettslag_id) REFERENCES idrettslag(id),
    CHECK (datetime(starttid) IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS idrettslag_gruppe (
    gruppenavn TEXT PRIMARY KEY,
    idrettslag_id INTEGER NOT NULL,
    FOREIGN KEY (idrettslag_id) REFERENCES idrettslag(id)
);

CREATE TABLE IF NOT EXISTS tidsblokk (
    starttid TEXT NOT NULL,
    ukedag INTEGER NOT NULL,
    PRIMARY KEY (starttid, ukedag),
    CHECK (time(starttid) IS NOT NULL),
    CHECK (ukedag BETWEEN 1 AND 7)
);

CREATE TABLE IF NOT EXISTS senter (
    id INTEGER PRIMARY KEY,
    navn TEXT NOT NULL,
    gateadresse TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sal (
    senter_id INTEGER NOT NULL,
    nr INTEGER NOT NULL,
    kapasitet INTEGER NOT NULL,
    PRIMARY KEY (senter_id, nr),
    FOREIGN KEY (senter_id) REFERENCES senter(id),
    CHECK (kapasitet > 0)
);

CREATE TABLE IF NOT EXISTS spinningsal (
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    PRIMARY KEY (senter_id, sal_nr),
    FOREIGN KEY (senter_id, sal_nr) REFERENCES sal(senter_id, nr)
);

CREATE TABLE IF NOT EXISTS løpesal (
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    PRIMARY KEY (senter_id, sal_nr),
    FOREIGN KEY (senter_id, sal_nr) REFERENCES sal(senter_id, nr)
);

CREATE TABLE IF NOT EXISTS flerbrukshall (
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    type TEXT NOT NULL,
    PRIMARY KEY (senter_id, sal_nr),
    FOREIGN KEY (senter_id, sal_nr) REFERENCES sal(senter_id, nr)
);

CREATE TABLE IF NOT EXISTS fasilitet (
    navn TEXT PRIMARY KEY,
    ikon TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fasiliterer (
    senter_id INTEGER NOT NULL,
    fasilitetsnavn TEXT NOT NULL,
    PRIMARY KEY (senter_id, fasilitetsnavn),
    FOREIGN KEY (senter_id) REFERENCES senter(id),
    FOREIGN KEY (fasilitetsnavn) REFERENCES fasilitet(navn)
);

CREATE TABLE IF NOT EXISTS instruktør (
    id INTEGER PRIMARY KEY,
    fornavn TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS aktivitetstype (
    navn TEXT PRIMARY KEY,
    beskrivelse TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS gruppereservasjon (
    id INTEGER PRIMARY KEY,
    uke_nr INTEGER NOT NULL,
    gruppenavn TEXT NOT NULL,
    tidsblokk_starttid TEXT NOT NULL,
    tidsblokk_ukedag INTEGER NOT NULL,
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    FOREIGN KEY (gruppenavn) REFERENCES idrettslag_gruppe(gruppenavn),
    FOREIGN KEY (tidsblokk_starttid, tidsblokk_ukedag) REFERENCES tidsblokk(starttid, ukedag),
    FOREIGN KEY (senter_id, sal_nr) REFERENCES sal(senter_id, nr),
    CHECK (uke_nr BETWEEN 1 AND 53),
    CHECK (tidsblokk_ukedag BETWEEN 1 AND 7)
);

CREATE TABLE IF NOT EXISTS gruppetime (
    id INTEGER PRIMARY KEY,
    uke_nr INTEGER NOT NULL,
    år INTEGER NOT NULL,
    instruktør_id INTEGER NOT NULL,
    aktivitetstype TEXT NOT NULL,
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    FOREIGN KEY (instruktør_id) REFERENCES instruktør(id),
    FOREIGN KEY (aktivitetstype) REFERENCES aktivitetstype(navn),
    FOREIGN KEY (senter_id, sal_nr) REFERENCES sal(senter_id, nr),
    CHECK (uke_nr BETWEEN 1 AND 53),
    CHECK (år BETWEEN 1900 AND 9999)
);

CREATE TABLE IF NOT EXISTS senterbesøk (
    id INTEGER PRIMARY KEY,
    ankomsttidspunkt TEXT NOT NULL,
    bruker_id INTEGER NOT NULL,
    senter_id INTEGER NOT NULL,
    FOREIGN KEY (bruker_id) REFERENCES bruker(id),
    FOREIGN KEY (senter_id) REFERENCES senter(id),
    CHECK (datetime(ankomsttidspunkt) IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS senteråpningstid (
    dato TEXT NOT NULL,
    senter_id INTEGER NOT NULL,
    start_tid TEXT NOT NULL,
    slutt_tid TEXT NOT NULL,
    PRIMARY KEY (dato, senter_id),
    FOREIGN KEY (senter_id) REFERENCES senter(id),
    CHECK (date(dato) IS NOT NULL),
    CHECK (time(start_tid) IS NOT NULL),
    CHECK (time(slutt_tid) IS NOT NULL),
    CHECK (time(slutt_tid) > time(start_tid))
);

CREATE TABLE IF NOT EXISTS senterbemanning (
    dato TEXT NOT NULL,
    senter_id INTEGER NOT NULL,
    start_tid TEXT NOT NULL,
    slutt_tid TEXT NOT NULL,
    PRIMARY KEY (dato, senter_id),
    FOREIGN KEY (senter_id) REFERENCES senter(id),
    CHECK (date(dato) IS NOT NULL),
    CHECK (time(start_tid) IS NOT NULL),
    CHECK (time(slutt_tid) IS NOT NULL),
    CHECK (time(slutt_tid) > time(start_tid))
);

CREATE TABLE IF NOT EXISTS spinningsykkel (
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL,
    har_bluetooth INTEGER NOT NULL,
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    FOREIGN KEY (senter_id, sal_nr) REFERENCES spinningsal(senter_id, sal_nr),
    CHECK (har_bluetooth IN (0, 1))
);

CREATE TABLE IF NOT EXISTS tredemølle (
    id INTEGER PRIMARY KEY,
    produsent TEXT NOT NULL,
    maks_hastighet REAL NOT NULL,
    maks_stigning REAL NOT NULL,
    senter_id INTEGER NOT NULL,
    sal_nr INTEGER NOT NULL,
    FOREIGN KEY (senter_id, sal_nr) REFERENCES løpesal(senter_id, sal_nr),
    CHECK (maks_hastighet > 0),
    CHECK (maks_stigning >= 0)
);

CREATE TABLE IF NOT EXISTS time_skjer_i (
    gruppetime_id INTEGER PRIMARY KEY,
    tidsblokk_starttid TEXT NOT NULL,
    tidsblokk_ukedag INTEGER NOT NULL,
    FOREIGN KEY (gruppetime_id) REFERENCES gruppetime(id),
    FOREIGN KEY (tidsblokk_starttid, tidsblokk_ukedag) REFERENCES tidsblokk(starttid, ukedag),
    CHECK (tidsblokk_ukedag BETWEEN 1 AND 7)
);

CREATE TABLE IF NOT EXISTS deltar_på_time (
    gruppetime_id INTEGER NOT NULL,
    bruker_id INTEGER NOT NULL,
    påmeldt_tidspunkt TEXT NOT NULL,
    avmeldt_tidspunkt TEXT,
    prikk_dato TEXT,
    PRIMARY KEY (gruppetime_id, bruker_id),
    FOREIGN KEY (gruppetime_id) REFERENCES gruppetime(id),
    FOREIGN KEY (bruker_id) REFERENCES bruker(id),
    CHECK (datetime(påmeldt_tidspunkt) IS NOT NULL),
    CHECK (avmeldt_tidspunkt IS NULL OR datetime(avmeldt_tidspunkt) IS NOT NULL),
    CHECK (prikk_dato IS NULL OR date(prikk_dato) IS NOT NULL),
    CHECK (
        avmeldt_tidspunkt IS NULL
        OR datetime(avmeldt_tidspunkt) >= datetime(påmeldt_tidspunkt)
    )
);