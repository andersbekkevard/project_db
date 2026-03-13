# Wave 2.5: Adversarial hardening av verifikasjonsporten for DB2

## Formål

Dette notatet angriper den nåværende verifikasjonsplanen med vilje. Målet er å finne måter en implementasjon kan passere de planlagte kontrollene og likevel være funksjonelt feil eller poengsvak mot rubrikken.

Fokus er på fire risikoklasser som allerede er nevnt i briefen:

- falsk reproduserbarhet
- booking- eller oppmøtelogikk som skriver til feil rader
- resultatfiler som ser riktige ut, men kommer fra gammel tilstand
- SQL/Python-drift som fortsatt demoer riktig, men taper rubrikkpoeng

## Kontroller som allerede er relativt robuste

Følgende elementer er gode byggesteiner og bør beholdes:

- Kravet om `rm -f trening.db` før `91_init_db.py` er en reell beskyttelse mot løsninger som bare virker mot en ferdig utviklerdatabase.
- Ekstra negative kjøringer for UC2, UC3 og UC6 er riktig retning fordi de prøver å verifisere domenereglene, ikke bare happy path.
- Kravet om `diff` mellom nygenererte `resultat_*.txt` og leverte filer er et nyttig vern mot håndredigerte resultatfiler.

Disse kontrollene er likevel ikke sterke nok alene. De sier for lite om årsak, radpresisjon og hvorvidt SQL faktisk er sannhetskilden.

## Falske pass-scenarier

### 1. Falsk reproduserbarhet via ferdigskrevne eller stale resultatfiler

Hvordan den kan passere:

- `92_reproduser_alt.py` kan skrive faste tekstblokker til `resultat_*.txt` uten å kjøre de egentlige brukstilfellene.
- Scriptet kan lese fra en gammel `trening.db` eller en intern maldatabase og likevel produsere forventet tekst.
- `diff` vil fortsatt bli grønn hvis de leverte resultatfilene ble laget fra samme gamle tilstand.

Hvorfor dette er farlig:

- Porten bekrefter bare at tekstfilene matcher hverandre, ikke at de kommer fra den nåværende koden kjørt fra ren tilstand.
- En slik løsning kan demoes fint, men er ikke reproduserbar for sensor i en ren mappe.

Hvordan porten bør strammes inn:

- Slett både `trening.db` og alle `resultat_*.txt` før `92_reproduser_alt.py` kjøres.
- Kjør `92_reproduser_alt.py` to ganger fra ren tilstand og krev identisk databaseinnhold og identiske resultatfiler begge ganger.
- Legg inn autonome etterkontroller som leser databasen etter reproduksjonskjøringen og verifiserer at UC2/UC3/UC6 faktisk har satt forventede sideeffekter.
- Verifiser at resultatfilenes modifikasjonstid er nyere enn starttidspunktet for kjøringen, slik at gamle filer ikke kan gjenbrukes.

Hvilke implementasjonskrav som bør låses:

- `92_reproduser_alt.py` må kalle de samme inngangspunktene som README beskriver, ikke en alternativ snarvei.
- Resultatfilene skal skrives fra ferske queryresultater, ikke fra hardkodede tekstmaler.

### 2. UC2 eller UC3 kan treffe feil radsett og likevel se riktig ut

Hvordan den kan passere:

- UC3 kan gjøre `UPDATE deltar_på_time SET oppmøtt_tidspunkt = ? WHERE bruker_id = ?` og dermed markere flere av Johnnys bookinger som oppmøtt.
- UC2 kan slå opp trening på aktivitet alene eller på en for bred join og dermed booke feil `gruppetime`.
- Den planlagte kontrollen ser primært etter at Johnny + GT4 ser riktig ut etterpå, ikke at ingen andre rader ble endret.

Hvorfor dette er farlig:

- En bred `UPDATE` eller feil `INSERT` kan forurense historikk, månedsvinner og "trener sammen" uten at den første demoen avslører det.
- Feilen gir typisk riktige terminalmeldinger og én synlig korrekt rad, men skjulte bivirkninger i resten av tabellen.

Hvordan porten bør strammes inn:

- Ta et snapshot av `deltar_på_time` før og etter UC2 og UC3 og krev at nøyaktig én rad endres per brukstilfelle.
- Verifiser at den endrede raden peker på korrekt intern kombinasjon av `bruker.id` og `gruppetime.id`.
- Legg til en kontroll som eksplisitt feiler hvis mer enn én rad får nytt `oppmøtt_tidspunkt` eller hvis mer enn én bookingrad opprettes.
- Gjør årsakskontrollen autonom: verifiser først at oppslaget av trening gir nøyaktig én match før selve innsettingen eller oppdateringen skjer.

Hvilke implementasjonskrav som bør låses:

- All skrivelogikk skal gå mot interne nøkler, ikke tekstfelt direkte.
- UC2 og UC3 skal eksplisitt feile hvis treningsoppslaget gir `0` eller `>1` rader.
- Etter skrivesteg skal løsningen kontrollere at `changes()` er lik `1`.

### 3. Negative tester kan bli grønne av feil grunn

Hvordan den kan passere:

- UC2s negative test kan avvises fordi Johnny allerede er booket, ikke fordi referansetiden er for sen.
- UC3s negative test kan avvises fordi booking mangler eller fordi feil trening ble slått opp, ikke fordi 5-minuttersfristen slo inn.
- UC6s negative test kan avvises fordi Emma ikke finnes eller fordi prikkgrunnlaget ikke ble lest riktig.

Hvorfor dette er farlig:

- Porten blir grønn uten å bevise den domeneregelen den påstår å teste.
- Dette maskerer implementasjoner som gir generiske feil eller sjekker i feil rekkefølge.

Hvordan porten bør strammes inn:

- Kjør hver negativ test på en fersk databasekopi med eksplisitte precondition-sjekker rett før kommandoen kjøres.
- Verifiser før UC2-negativ at Johnny finnes, at GT4 finnes, at Johnny ikke allerede er booket på GT4, og at eneste avvisningsgrunn er tidsregelen.
- Verifiser før UC3-negativ at bookingraden eksisterer og at oppmøte ennå ikke er registrert.
- Verifiser før UC6-negativ at Emma finnes og har færre enn tre prikker i relevant 30-dagersvindu.
- Krev distinkte feilmeldinger eller feilkoder per avvisningsårsak, ikke bare en generell "avvist".

Hvilke implementasjonskrav som bør låses:

- Wrapperne skal returnere spesifikk årsak når en kontroll stopper flyten.
- Domenekontroller skal evalueres i en definert rekkefølge som kan verifiseres.

### 4. SQL-vs-Python-drift kan gi korrekt demo, men fortsatt tape rubrikkpoeng

Hvordan den kan passere:

- Python kan hente rå rader og gjøre sortering, deduplisering, opptelling og vinnerlogikk etterpå.
- SQL-filene kan eksistere for syns skyld, men være tynne wrappers rundt en rå `SELECT`.
- Tier 3-lesing alene er for svak hvis den ikke kobles til konkrete forbud og kontrollerbare tegn.

Hvorfor dette er farlig:

- Løsningen kan se korrekt ut i terminalen, men bryter direkte med SQL-først-kravet og kan tape mange poeng.
- Risikoen er størst i UC4, UC5, UC7 og UC8 fordi disse lett kan "reddes" i Python uten at demooutput avslører det.

Hvordan porten bør strammes inn:

- Lås at SQL-filene for UC4, UC5, UC7 og UC8 skal inneholde hovedlogikken for `ORDER BY`, `DISTINCT`, `GROUP BY`, telling og utvelgelse av vinnere/par.
- Gjør en lett statisk kontroll av Python-wrapperne som flagger lokal sortering, gruppering, telling eller deduplisering av resultatrader.
- Koble Tier 3 til konkrete sjekkpunkter: hvis Python bruker `sorted`, `Counter`, manuelle mengder for unikhet eller post-filtrering av queryrader i disse brukstilfellene, skal porten ikke være grønn uten eksplisitt begrunnelse.

Hvilke implementasjonskrav som bør låses:

- Python skal begrenses til parameterbinding, kjøring, transaksjonsstyring og utskrift.
- SQL skal være den eneste kilden til forretningsregler og resultatsett for UC4, UC5, UC7 og UC8.

### 5. Bookinger kan feilaktig telles som oppmøte uten at seed-data avslører det

Hvordan den kan passere:

- UC5, UC7 eller UC8 kan bruke alle rader i `deltar_på_time` i stedet for bare rader med faktisk oppmøte.
- Hvis seed-data tilfeldigvis har samme personer som både er booket og møtt i de sentrale eksemplene, vil output se riktig ut.
- Etter UC2 og UC3 kan demonstrasjonen fortsatt bli pen selv om queryene i praksis teller bookinger.

Hvorfor dette er farlig:

- Dette gir direkte faglig feil resultat i historikk, månedsvinner og fellestrening, men feilen kan skjules av et lite og symmetrisk demosett.
- Det er også en klassisk kilde til rubrikktap fordi output blir "riktig nok" i demo, men semantisk feil.

Hvordan porten bør strammes inn:

- Introduser en adversarial kontrollrad i testkjøringen: minst én booking uten `oppmøtt_tidspunkt` som ikke skal telle i UC5, UC7 eller UC8.
- Kjør UC5, UC7 og UC8 både før og etter at en slik ren bookingrad legges inn, og krev uendret output.
- Verifiser eksplisitt at queryene filtrerer på faktisk oppmøte, ikke bare deltakelsesradens eksistens.

Hvilke implementasjonskrav som bør låses:

- UC5, UC7 og UC8 skal eksplisitt kreve `oppmøtt_tidspunkt IS NOT NULL`.
- Hvis en statuskolonne senere innføres, skal bare `oppmøtt` telle som deltakelse i disse brukstilfellene.

## Høyest prioriterte hardening-endringer

Hvis bare noen få ting skal styrkes før implementasjon, er dette de mest verdifulle:

1. Legg til tabellsnapshot før og etter UC2 og UC3, slik at feil radoppdateringer ikke kan skjules.
2. Gjør negative tester årsakssikre med precondition-sjekker og distinkte feilkoder.
3. Tving `92_reproduser_alt.py` til å kjøre fra slettet database og slettede resultatfiler, og verifiser både databasebivirkninger og filenes ferskhet.
4. Legg inn minst én adversarial booking-uten-oppmøte som må ignoreres av UC5, UC7 og UC8.
5. Lås eksplisitt at SQL, ikke Python, skal utføre sortering, deduplisering, telling og vinnerutvelgelse i de relevante brukstilfellene.

## Konklusjon

Den nåværende briefen er et godt utgangspunkt, men den er fortsatt for lett å spille. Den største systematiske svakheten er at porten i flere tilfeller bekrefter "riktig utseende" i output, uten å bevise riktig årsak, riktig radpresisjon eller riktig plassering av logikk mellom SQL og Python.

Hvis punktene over låses før implementasjon, blir det betydelig vanskeligere å få en falsk grønn pakke som senere faller i sensur.
