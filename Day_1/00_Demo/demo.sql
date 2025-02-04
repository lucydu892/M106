/*Das ist ein
mehrzeilliger Kommentar
*/
SELECT 'Hallo von Demo';

/*
-- Zusammengesetzten Primärschlüssel auf der Tabelle kunden definieren
CREATE TABLE verkauf.kunden (
    kundenid INT IDENTITY(1,1),
    vorname varchar(30),
    nachname varchar(30)
    CONSTRAINT pk_kunden PRIMARY KEY (kundenid, nachname)
);
-- Hinweis: Bei diesem Beispiel wird dem Primärschlüssel explizit ein Name vergeben

/*
Zusammengesetzten Primärschlüssel nachträglich auf der Tabelle kunden definieren, 
falls auf dieser noch kein Primärschlüssel definiert war 
*/
ALTER TABLE verkauf.kunden ADD PRIMARY KEY (kundenid, nachname);
*/