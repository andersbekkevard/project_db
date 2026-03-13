# Revisjon av skjema-gap for DB2

## Konklusjon

`sql/schema.sql` er nær nok til å modellere senter, saler, utstyr, brukere og bookinger, men det mangler fortsatt noen få kritiske ting for at alle brukstilfeller 1-8 skal være trygt og entydig implementerbare. De største blokkene er:

1. `gruppetime` lagrer ikke et eksplisitt start- og sluttidspunkt, bare `år`, `uke_nr` og en kobling til `time_skjer_i` (`sql/schema.sql` linje 126-206). Dette gjør BT2, BT4, BT5, BT6, BT7 og BT8 unødvendig kompliserte og i noen tilfeller tvetydige.
2. Skjemaet kan markere uteblivelse via `deltar_på_time.prikk_dato`, men kan ikke registrere positivt oppmøte eller faktisk deltakelse (`sql/schema.sql` linje 208-224). Det strider mot kravet om å vite både hvem som møtte og hvem som ikke møtte (`resources/norwegian/project-description.md` linje 19-23 og 36-37).
3. Viktige oppslag i brukstilfellene går via naturlige nøkler som ikke er unike i skjemaet, særlig `bruker.epost` og `senter.navn` (`sql/schema.sql` linje 2-9 og 51-55).
4. `assumptions.md` sier at alle tidsblokker starter på hele klokkeslett og varer én time (linje 10), mens BT2 eksplisitt bruker `17. mars kl. 18.30` (`resources/norwegian/project-description.md` linje 57-60). Det er en direkte inkonsistens mellom antakelsene og brukstilfellene.

## Brukstilfelle for brukstilfelle

### BT1: Legg inn senter, saler, sykler, brukere, trenere og treninger

**Det skjemaet allerede støtter**

- `senter`, `sal`, `spinningsal`, `bruker`, `instruktør`, `aktivitetstype`, `gruppetime` og `time_skjer_i` dekker hovedentitetene som må settes inn (`sql/schema.sql` linje 51-55, 57-71, 101-109, 126-206).
- `senteråpningstid`, `senterbemanning` og `fasiliterer` gjør det mulig å laste åpningstider, bemanning og fasiliteter for Øya (`sql/schema.sql` linje 93-99 og 151-175).

**Gap**

- `spinningsykkel` mangler sykkelnummeret som skal være unikt i salen, selv om oppgaven sier at hver sykkel har et nummer i salen (`resources/norwegian/project-description.md` linje 24-27). Nå finnes bare en global `id` (`sql/schema.sql` linje 177-185).
  Klassifisering: `schema change needed`.
- `gruppetime` mangler eksplisitt dato/tid og varighet. For de konkrete treningene 16.-18. mars blir tidspunktet indirekte spredd over `år`, `uke_nr` og `time_skjer_i`, men ikke lagret som ett faktisk tidspunkt (`sql/schema.sql` linje 126-206).
  Klassifisering: `schema change needed`.
- Det finnes ingen seed-data i skjemaet for nødvendige referanser som spinning-aktivitetene, Øya/Dragvoll, aktuelle tidsblokker, Johnny og treninger i perioden 16.-18. mars, selv om DB2 krever at alle data som er nevnt i oppgaven skal settes inn (`resources/norwegian/project-deliverables.md` linje 43-49 og 80-82).
  Klassifisering: `seed data needed`.
- `bruker.epost` er ikke unik, selv om senere brukstilfeller identifiserer brukere ved e-post (`sql/schema.sql` linje 2-9; `resources/norwegian/project-description.md` linje 57-58, 67-68 og 71-73).
  Klassifisering: `schema change needed`.

### BT2: Booking av `Spin60` 17. mars kl. 18.30 på Øya for `johnny@stud.ntnu.no`

**Det skjemaet allerede støtter**

- `deltar_på_time` kan lagre én booking per bruker per gruppetime med `påmeldt_tidspunkt` (`sql/schema.sql` linje 208-224).
- `bruker.utestengt_til` gir et sted å lagre at en bruker er utestengt (`sql/schema.sql` linje 2-9).

**Gap**

- Oppslaget er ikke entydig nok på skjemanivå fordi både `bruker.epost` og `senter.navn` kan forekomme flere ganger. BT2 bruker e-post, aktivitet og tidspunkt som parametere, så du trenger naturlige nøkler som faktisk er unike.
  Klassifisering: `schema change needed`.
- Selve oppslaget mot en trening må bygges som en sammensatt join mellom `gruppetime`, `time_skjer_i`, `aktivitetstype`, `sal` og `senter`, fordi skjemaet ikke har ett direkte `starttidspunkt` på `gruppetime`.
  Klassifisering: `SQL query needed`.
- Kapasitetskontroll, sjekk mot aktiv utestengelse og kontroll av samtidige bookinger ligger ikke i skjemaet. `assumptions.md` sier også eksplisitt at slike regler må håndteres i applikasjonen (linje 18-29).
  Klassifisering: `Python wrapper needed`.
- Oppgaveteksten nevner ventelister som en reell del av domenet (`resources/norwegian/project-description.md` linje 44-47), men `deltar_på_time` har ingen status eller posisjon for venteliste. Hvis timen er full, finnes det ingen kanonisk måte å lagre "brukeren står på venteliste".
  Klassifisering: `schema change needed`.

### BT3: Registrering av oppmøte for treningen i BT2

**Det skjemaet allerede støtter**

- Det finnes et sted å lagre at en booking eksisterer (`deltar_på_time`) og et sted å lagre senterankomst (`senterbesøk`) (`sql/schema.sql` linje 141-149 og 208-224).

**Gap**

- Det finnes ikke noe felt som representerer faktisk oppmøte på en spesifikk gruppetime. `senterbesøk` peker bare på senter, ikke på trening, og `deltar_på_time` har bare `påmeldt_tidspunkt`, `avmeldt_tidspunkt` og `prikk_dato`.
  Klassifisering: `schema change needed`.
- Når oppgaven krever at systemet skal vite både hvem som var på treningen og hvem som ikke møtte (`resources/norwegian/project-description.md` linje 19-23), er det ikke tilstrekkelig å bare lagre prikk ved uteblivelse.
  Klassifisering: `schema change needed`.
- Selve oppmøteføringen må implementeres som en parameterisert oppdatering mot brukernavn og treningstidspunkt.
  Klassifisering: `SQL query needed`.
- Fem-minuttersregelen før oppstart kan ikke håndheves uten applikasjonslogikk rundt tidspunktet for innskanning eller oppmøteregistrering.
  Klassifisering: `Python wrapper needed`.

### BT4: Ukeplan for uke 12, sortert på tid

**Det skjemaet allerede støtter**

- `gruppetime` har `uke_nr` og `år`, og `time_skjer_i` har ukedag og starttid, så en ukeplan kan i prinsippet bygges (`sql/schema.sql` linje 126-206).

**Gap**

- Ukeplanen må konstrueres via beregning av dato fra år, uke og ukedag, siden skjemaet ikke lagrer det konkrete starttidspunktet direkte.
  Klassifisering: `SQL query needed`.
- `assumptions.md` sier at alle tidsblokker starter `kl.xx:00` og varer én time (linje 10), men BT2 krever en time kl. 18.30. Hvis gruppen følger antakelsen bokstavelig, blir ukeplanen feil for faktiske spinningtimer som starter på halvtimen.
  Klassifisering: `documentation only`.
- Skjemaet lagrer ikke varighet eller sluttid for en gruppetime. Det er nok til enkel sortering på starttid, men ikke nok til å forklare overlapp eller vise hele tidsrommet i ukeplanen.
  Klassifisering: `schema change needed`.

### BT5: Personlig besøkshistorie for Johnny siden 1. januar 2026

**Det skjemaet allerede støtter**

- `bruker`, `gruppetime`, `aktivitetstype` og `senter` gir nok struktur til å skrive et historikk-query hvis deltakelse faktisk er registrert (`sql/schema.sql` linje 2-9, 51-55, 106-139 og 208-224).

**Gap**

- Oppgaven ber om treninger Johnny faktisk har deltatt på (`resources/norwegian/project-description.md` linje 67-70), men skjemaet kan bare vise bookinger eller prikker. Uten positiv oppmøteregistrering blir historikken upålitelig.
  Klassifisering: `schema change needed`.
- Resultatet skal vise dato/tid for treningen, men dato/tid ligger ikke som ett felt i `gruppetime`.
  Klassifisering: `schema change needed`.
- Det må legges inn seed-data som faktisk viser at Johnny har deltatt på noen treninger siden 1. januar 2026.
  Klassifisering: `seed data needed`.
- Selve historikkspørringen må dedupliseres med `DISTINCT` eller en tilsvarende gruppering.
  Klassifisering: `SQL query needed`.

### BT6: Svartelisting etter tre prikker på 30 dager

**Det skjemaet allerede støtter**

- `deltar_på_time.prikk_dato` kan brukes til å telle prikker, og `bruker.utestengt_til` kan brukes til å lagre at brukeren er sperret (`sql/schema.sql` linje 2-9 og 208-224).

**Gap**

- BT6 krever en kontroll av om brukeren har minst tre prikker de siste 30 dagene før svartelisting (`resources/norwegian/project-description.md` linje 71-74). Den kontrollen finnes ikke ferdig i skjemaet og må uttrykkes som et eksplisitt query.
  Klassifisering: `SQL query needed`.
- `assumptions.md` sier at fremtidige bookinger skal fjernes når brukeren blir utestengt (linje 9), men dette krever applikasjonsflyt som først oppdaterer `utestengt_til` og deretter avbestiller fremtidige bookinger.
  Klassifisering: `Python wrapper needed`.
- Siden `gruppetime` ikke har et eksplisitt starttidspunkt, blir det mer komplisert enn nødvendig å avgjøre hvilke bookinger som faktisk ligger i fremtiden.
  Klassifisering: `schema change needed`.

### BT7: Finn personen(e) som har deltatt på flest gruppetimer i en måned

**Det skjemaet allerede støtter**

- `deltar_på_time`, `bruker` og `gruppetime` er de riktige tabellene for en slik statistikk (`sql/schema.sql` linje 2-9, 126-139 og 208-224).

**Gap**

- Kravet gjelder deltakelse, ikke bare booking (`resources/norwegian/project-description.md` linje 75-79). Uten positiv oppmøtelagring kan queryet telle feil brukere.
  Klassifisering: `schema change needed`.
- Månedparameteren blir langt enklere og mer robust hvis treningen har et faktisk `starttidspunkt`. Slik skjemaet står nå må måneden avledes indirekte.
  Klassifisering: `schema change needed`.
- Oppgaven krever seed-data som demonstrerer at queryet virker og også håndterer tie ved behov.
  Klassifisering: `seed data needed`.
- Selve toppliste-queryet må bygges med aggregering og håndtering av delt førsteplass.
  Klassifisering: `SQL query needed`.

### BT8: Finn to studenter som trener sammen

**Det skjemaet allerede støtter**

- Strukturen for å koble flere brukere til samme gruppetime finnes i `deltar_på_time`.

**Gap**

- Også her handler kravet om brukere som faktisk trener sammen, ikke bare booker samme time (`resources/norwegian/project-description.md` linje 80-84). Uten oppmøteregistrering blir resultatet et booking-query, ikke et samtrenings-query.
  Klassifisering: `schema change needed`.
- Begrepet "student" finnes ikke som eksplisitt attributt i skjemaet. Minimumsløsningen er å dokumentere at BT8 avgrenser til e-poster med studentdomene, for eksempel `@stud.ntnu.no`, siden brukstilfellet selv bruker slike adresser.
  Klassifisering: `documentation only`.
- Det må finnes seed-data der minst to brukere faktisk har deltatt på flere av de samme timene.
  Klassifisering: `seed data needed`.
- Selve løsningen er et selv-join-query over deltakelser per gruppetime.
  Klassifisering: `SQL query needed`.

## Minimum levedyktig endringssett

Dette er den minste pakken jeg mener trengs for å gjøre alle brukstilfeller 1-8 implementerbare uten å gjøre `schema.sql` unødvendig stort:

1. Legg til naturlige nøkler som faktisk brukes i DB2:
   - `UNIQUE (epost)` på `bruker`.
   - `UNIQUE (navn)` på `senter`, eller dokumenter et annet entydig oppslagsfelt som brukes konsekvent i alle queries.
2. Gi `gruppetime` et eksplisitt tidspunkt:
   - legg til `starttidspunkt TEXT NOT NULL`,
   - legg til `sluttidspunkt TEXT NOT NULL`,
   - legg til `CHECK (datetime(starttidspunkt) IS NOT NULL)`,
   - legg til `CHECK (datetime(sluttidspunkt) IS NOT NULL)`,
   - legg til `CHECK (datetime(sluttidspunkt) > datetime(starttidspunkt))`.
   Med dette blir BT2, BT4, BT5, BT6 og BT7 mye enklere og mindre feilutsatt. `uke_nr`, `år` og `time_skjer_i` kan beholdes midlertidig hvis gruppen vil minimere refaktorering, men DB2-spørringene bør bruke de eksplisitte tidspunktene.
3. Gi `deltar_på_time` en positiv oppmøtemarkør:
   - legg til `oppmøtt_tidspunkt TEXT`,
   - legg til `CHECK (oppmøtt_tidspunkt IS NULL OR datetime(oppmøtt_tidspunkt) IS NOT NULL)`.
   Da kan BT3 registrere oppmøte, mens BT5, BT7 og BT8 kan telle faktiske deltakelser.
4. Modellér fysisk utstyr slik oppgaven beskriver det:
   - legg til `nr INTEGER NOT NULL` på `spinningsykkel` og gjør det unikt per `(senter_id, sal_nr, nr)`,
   - legg til tilsvarende `nr` på `tredemølle`.
5. Hvis gruppen vil dekke ventelistekravet fra domenebeskrivelsen, legg til en enkel bookingstatus på `deltar_på_time`, for eksempel `status TEXT NOT NULL DEFAULT 'booket'` med en sjekk som tillater `booket`, `venteliste`, `oppmøtt`, `avmeldt`, `uteblitt`. Dette er ikke strengt nødvendig for å få BT1-8 til å kjøre, men det er det tydeligste domenegapet utenfor selve brukstilfellene.
6. Lag ett seed-script som minst setter inn:
   - Øya og Dragvoll,
   - relevante saler og spinningsaler,
   - fasiliteter, åpningstider og bemanning for perioden 16.-18. mars,
   - spinning-aktivitetstyper med beskrivelser,
   - Johnny og minst to andre brukere,
   - instruktører,
   - treninger i perioden 16.-18. mars,
   - bookinger, oppmøter og prikker som demonstrerer BT3, BT5, BT6, BT7 og BT8.

## Inkonsistenser og praktiske risikoer

- `assumptions.md` linje 10 sier at alle tidsblokker starter på hele klokkeslett og varer én time. BT2 krever derimot `17. mars kl. 18.30`. Enten må antakelsen rettes, eller så må gruppen akseptere at den ikke er kanonisk for DB2.
- Oppgaveteksten krever at systemet skal vite både hvem som er på treningen og hvem som ikke møter (`resources/norwegian/project-description.md` linje 19-23), mens dagens skjema bare lagrer uteblivelse som `prikk_dato`. Dette er den viktigste semantiske mangelen i hele skjemaet.
- Oppgaveteksten sier at ventelister er vanlige (`resources/norwegian/project-description.md` linje 44-47), men skjemaet har ingen representasjon av venteliste eller bookingstatus. Det betyr at dagens modell ikke dekker hele domenet, selv om selve brukstilfellene 1-8 kan reddes med et mindre endringssett.
- `assumptions.md` linje 14 sier at `gruppetime`-tabellen resettes hvert år. Det er forenlig med BT5 slik den er formulert for 2026, men det er en skjør antakelse hvis systemet senere skal brukes til historikk eller statistikk over flere år.

## Prioritert risikovurdering

Hvis gruppen skal gjøre minst mulig før DB2, ville jeg prioritert i denne rekkefølgen:

1. Legg til eksplisitt treningstid og oppmøteregistrering.
2. Legg til `UNIQUE` på de naturlige nøklene som brukes i brukstilfellene.
3. Skriv seed-data som faktisk dekker alle eksemplene i BT1-8.
4. Skriv parameteriserte SQL-spørringer for BT2-BT8 og la Python kun håndtere flyt og valideringer som ikke kan uttrykkes rent i SQL.
