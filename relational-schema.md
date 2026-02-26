```sql
bruker(*id*, navn, epost, mobilnummer)

instruktør(*id*, fornavn)

idrettslag(*id*)

tidsrom(*id*, starttidspunkt, sluttidspunkt)

senter(*id*, navn, gateadresse, åpner, stenger, bemann_start, bemann_slutt)

fasilitet(*navn*, beskrivelse, icon)

sal(*rom_nr*, *senter_id*, kapasitet)

gruppetime(*id*, senter_id, rom_nr, kapasitet, uke_nr)

medlemskap(*id*, bruker_id, starttidspunkt)

prikk(*medlemskap_id*, tidspunkt)

spinningsal(*senter_id*, *rom_nr*, *id*)

løpesal(*senter_id*, *rom_nr*, *id*)

flerbrukshall(*senter_id*, *rom_nr*, *id*, type)

spinningsykler(*nr*, senter_id, rom_nr, type) -- er denne weak, hva er PK? FK -> (senter_id, rom_nr) pr nå

tredemølle(*nr*, senter_id, rom_nr, produsent, max_hastighet, max_stigning) -- er denne weak, hva er PK? FK -> (senter_id, rom_nr) pr nå

medlem_av(*bruker_id*, *idrettslag_id*)

fasiliterer(*senter_id*, *fasilitet_navn*)

når(*gruppetime_id*, *tidsrom_id*)

deltar(*gruppetime_id*, *medlemskap_id*, instruktør_id, oppmøtt, avmeldt_tidspunkt) -- instruktør_id er FK -> instruktør

har_sal(*idrettslag_id*, *tidsrom_id*, *senter_id*, *rom_nr*, uke_nr)

```


### Kommentar
Foreløpig usikker på:
- Skal sal være weak, blir samme "reuse of several primary key attrubutes" som vi hadde for medlemskap
- Hvilken måte skal vi løse den "inheritance-distinct" greia nede ved de ulike saltypene? Dette er foreløpig bare en røff skisse
- Den ternary-relasjonen har-sal må vi også kikke på, tror ikke den er helt good.