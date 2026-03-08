c) Et SQL-script som konstruerer databasen med tabellene. Husk å spesifiser primær- og fremmednøkler, samt andre nødvendige restriksjoner. Dokumenter restriksjoner som ikke uttrykkes i relasjonsdatabaseskjemaet og derfor må håndteres i applikasjonsprogrammene. 

Det er to restriksjoner som risikerer å gå tapt i oversettelsen fra ER-diagram til relasjonsdatabaseskjemaet.

Den ene er kardinalitetskrav.
En mange-til-en-relasjon der deltakelsen på mange-siden er total, løses ved å legge primærnøkkelen fra en-siden inn som en fremmednøkkel i tabellen på mange-siden, og definere denne som NOT NULL. Dette sikrer både referanseintegritet og kravet om total deltakelse.

Den andre er at skjemaet ikke sikrer at hver entitet i relasjonen sal forekommer i nøyaktig én av relasjonene spinningsal, løpesal eller flerbrukssal. Dette må derfor kontrolleres i applikasjonslaget.


SQL: see @sql/schema.sql
