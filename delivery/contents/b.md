b) ER-modellen oversatt til relasjonsdatabaseskjema (tabeller). Spesifiser nøkler og fremmednøkler for hver tabell. For hver tabell skal du forklare hvorfor tabellen er på BCNF, eventuelt forklar hvorfor du velger å ha den på en lavere normalform (du må forklare hvilken). Det holder å levere tabellene som i SQL-en i c), men forklaringene på normalformer skal være som tekst.


RELATIONAL SCHEMA 2.0

bruker(*id*, navn, epost, mobilnr, utestengt_til)
BCNF: Alle attributter er kun funksjonelt avhengige av primærnøkkelen id. 

medlem(*id*, starttid, gyldig_til, bruker_id)
Foreign key: bruker_id -> bruker(id)
BCNF: Alle attributter avhenger kun av id.

medlem_av(*bruker_id*, *idrettslag_id*, starttid)
Foreign key: 
bruker_id -> bruker(id)
idrettslag_id -> idrettslag(id)
BCNF: Sammensatt primærnøkkel der starttid avhenger av hele nøkkelen.

idrettslag(*id*, navn)
BCNF: Alle attributter er funksjonelt avhengige av primærnøkkelen id. 

idrettslag_gruppe(*gruppenavn*, idrettslag_id)
Foreign key: idrettslag_id -> idrettslag(id)
BCNF: idrettslag_id er avhengig av gruppenavn. Refererer til forutsetningene beskrevet i deloppgave a.

gruppereservasjon(*id*, uke_nr, gruppenavn, tidsblokk_starttid, tidsblokk_ukedag, senter_id, sal_nr)
Foreign key: 
(gruppenavn, idrettslag_id) -> idrettslag_gruppe(gruppenavn, idrettslag_id)
(tidsblokk_starttid, tidsblokk ukedag) -> tidsblokk(starttid, ukedag)
(senter_id, sal_nr) -> sal(senter_id, nr)
BCNF: Alle attributter avhenger kun av id. 


tidsblokk(*starttid*, *ukedag*)
BCNF: Sammensatt primærnøkkel, ingen andre attributter.


gruppetime(*id*, uke_nr, år, instruktør_id, aktivitetstype, senter_id, sal_nr)
Foreign key:
instruktør_id -> instruktør(id)
aktivitetstype -> aktivitetstype(navn)
(senter_id, sal_nr) -> sal(senter_id, nr)
BCNF: Alle attributter avhenger kun av id.

senterbesøk(*id*, ankomsttidspunkt, bruker_id, senter_id)
Foreign key: 
bruker_id -> bruker(id)
senter_id -> senter(id)
BCNF: Alle attributter avhenger kun av id.


senter(*id*, navn, gateadresse)
BCNF: Alle attributter avhenger kun av id. 

senteråpningstid(*dato*, *senter_id*, start_tid, slutt_tid)
Foreign key: senter_id -> senter(id)
BCNF: Start_tid og slutt_tid avhenger kun av hele den sammensatte nøkkelen. Dette er den eneste funksjonelle avhengigheten vi har.

senterbemanning(*dato*, *senter_id*, start_tid, slutt_tid)
Foreign key: senter_id -> senter(id)
BCNF: Start_tid og slutt_tid avhenger kun av hele den sammensatte nøkkelen.


fasilitet(*navn*, ikon)
BCNF: Ikon avhenger kun av navn som er primary key

sal(*senter_id*, *nr*, kapasitet)
Foreign key: senter_id -> senter(id)
BCNF: Kapasitet er avhengig av hele primary key. 

spinningsal(*senter_id*, *sal_nr*)
Foreign key: (senter_id, sal_nr) -> sal(senter_id, nr)
BCNF: Kun primærnøkkel, ingen andre attributter,

løpesal(*senter_id*, *sal_nr*)
Foreign key: (senter_id, sal_nr) -> sal(senter_id, nr)
BCNF: Kun primærnøkkel, ingen andre attributter,

flerbrukshall(*senter_id*, *sal_nr*, type)
Foreign key: (senter_id, sal_nr) -> sal(senter_id, nr)
BCNF: Type avhenger av både senter_id og sal_nr, derfor på BCNF.

spinningsykkel(*id*, type, har_bluetooth, senter_id, sal_nr)
Foreign key: (senter_id, sal_nr) -> spinningsal(senter_id, sal_nr)
BCNF: Alle attributter kun avhengig av id

tredemølle(*id*, produsent, maks_hastighet, maks_stigning, senter_id, sal_nr) –CHECK((senter_id, sal_nr in løpesal)
Foreign key: (senter_id, sal_nr) -> løpesal(senter_id, sal_nr)
BCNF: Alle attributter avhenger kun av id


time_skjer_i(*gruppetime_id*, tidsblokk_starttid, tidsblokk_ukedag)
Foreign key:
gruppetime_id -> gruppetime(id)
(tidsblokk_starttid, tidsblokk_ukedag) -> tidsblokk(starttid, ukedag)
BCNF: Alle attributter avhenger kun av gruppetime_id.


deltar_på_time(*gruppetime_id*, *bruker_id*, påmeldt_tidspunkt, avmeldt_tidspunkt, prikk_dato)
Foreign key:
gruppetime_id -> gruppetime(id)
bruker_id -> bruker(id)
BCNF: Sammensatt nøkkel utgjør venstresiden av alle funksjonelle avhengigheter.

fasiliterer(*senter_id*, *fasilitetsnavn*)
Foreign key:
senter_id -> senter(id)
fasilitetsnavn -> fasilitet(navn)
BCNF: Kun sammensatt primærnøkkel, ingen andre attributter. 

instruktør(*id*, fornavn)
BCNF: Fornavn avhenger av id.

aktivitetstype(*navn*, beskrivelse)
BCNF: Beskrivelse avhenger kun av navnet som er primary key.
