/*
Projektarbeit M106
*/


/*Aufgabe 1
Erstelle anhand des Scripts Northwind-SQLServer.sql die Datenbank Northwind.
*/

/*Aufgabe 2
Erstelle ein Backup von der soeben erstellten Northwind-Datenbank in den dafür vorgesehenen Backupfolder deiner SQL-Instanz.
*/
BACKUP DATABASE Northwind
TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\Northwind.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'NORTHWIND-Vollständig Datenbank Sichern', SKIP, STATS = 10
GO


/*Aufgabe 3
Teste dein Backup, indem du die Northwind-Datenbank löschst und anhand des Backups wieder herstellst.
*/
USE master;
GO
DROP DATABASE Northwind;
GO

RESTORE DATABASE Northwind
FROM DISK =  N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\Northwind.bak' 

/*Aufgabe 4
Du willst dir Übersicht über die Produktetabelle erschaffen und möchtest wissen, 
welche Datentypen in der Produktetabelle verwendet werden. 
Erschaffe dir die Übersicht anhand der geeigneten gespeicherten Prozedur.
*/
USE Northwind;
GO
exec sp_columns Products

/*Aufgabe 5
Die Geschäftsleitung hat entschieden, Lohninformationen in der Datenbank zu speichern. 
Die Mitarbeiter der Firma Northwind haben folgende Anstellungen und Jahresgehälter:
Inside Sales Coordinator	80000$
Vice President, Sales		100000$
Sales Representative		80000$
Sales Manager				90000$
Erstelle eine Tabelle payroll_accounting innerhalb eines separaten Schemas names hr mit den Spalten title und salary. 
Du musst dazu keine Primary oder Foreign-Key definieren. Fülle die Tabelle wie erwähnt ab.

*/
CREATE SCHEMA hr AUTHORIZATION dbo;
GO

CREATE TABLE hr.payroll_accounting (
	payroll_accounting_id INT PRIMARY KEY,
	title NVARCHAR(30),
	salary MONEY);


INSERT hr.payroll_accounting VALUES
(1,'Inside Sales Coordinator',	80000),
(2,'Vice President, Sales',	100000),
(3,'Sales Representative',	80000),
(4,'Sales Manager',	90000);
GO

/*Aufgabe 6
Erstelle eine View lohnuebersicht, welche den Vornahmen, Nachnahmen und das Gehalt ausgibt. 
Die Jahresgehälter werden jeden Monat um 30$ erhöht. Mitarbeiter, welche im Jahre 1993 eingestellt wurden, 
erhalten zudem jährlich noch einen Bonus von 1000$. 
Da immer wieder eine Lohnliste erstellt werden muss, machst du eine View.
*/

Create VIEW lohnuebersicht AS
SELECT e.FirstName,e.LastName, 
CASE
	WHEN YEAR(e.HireDate)= 1993 THEN DATEDIFF(MONTH,HIREDATE, GETDATE())*30 + p.salary + DATEDIFF(YEAR,HIREDATE, GETDATE())*1000
	ELSE DATEDIFF(MONTH,HIREDATE, GETDATE())*30 + p.salary
	END 
	AS GEHALT
FROM Employees e
JOIN hr.payroll_accounting p ON e.Title = p.title;
GO

SELECT * FROM lohnuebersicht;

/*Aufgabe 7
Die Mitarbeiter werden jährlich aufgrund ihrer Leistung und der Zielerreichung bewertet. 
Die möglichen Bewertungen sind von A-D. 
Füge bei der Employees-Tabelle eine Spalte valuation mit dem Standartwert B ein. 
Achte darauf, dass nur die Werte A-D eingetragen werden können. 
Fülle diese Werte gleich ab: Alle Mitarbeiter erhalten die Bewertung B, 
einzig Nancy Davolio hat eine A und Robert King hat eine C.

*/
ALTER TABLE employees ADD valutation CHAR DEFAULT('B');
GO
ALTER TABLE employees ADD CHECK(valutation like '[A-D]');
GO

UPDATE Employees
SET valutation ='B';

UPDATE Employees
SET valutation ='A'
WHERE firstname = 'Nancy' AND lastname='Davolio';

UPDATE Employees
SET valutation ='C'
WHERE firstname = 'Robert' AND lastname='King';
GO



/*Aufgabe 8
Die neue Spalte soll von valutation in rating umbenannt werden.
*/
EXEC sp_rename 'dbo.employees.valutation', 'rating', 'COLUMN';--Fehlermeldung
--zuerst den Check löschen
ALTER TABLE Employees
DROP CONSTRAINT CK__Employees__valut__70DDC3D8;



--Nun kann die Prozedur ausgeführt werden
EXEC sp_rename 'dbo.employees.valutation', 'rating', 'COLUMN';

--Den Check wieder erstellen.
ALTER TABLE dbo.Employees
ADD CHECK(rating like '[A-D]');



/*Aufgabe 9
Die Tabelle hr.payroll_accounting soll in hr.salaries umbenannt werden.
*/
EXEC sp_rename 'hr.payroll_accounting', 'salaries';

/*Aufgabe 10
Erstelle von der Tabelle Products eine Kopie mit dem Namen products_backup.

Kontrolliere die Sicherung mit einem Select
*/
SELECT * INTO products_backup FROM Products;

SELECT * FROM products_backup;

/*Aufgabe 11
Lösche den Inhalt der Tabelle products_backup innerhalb einer Transaktion. Schliesse die Transaktion so ab, dass 
die Änderungen nicht ausgeführt werden.
*/
BEGIN TRANSACTION
DELETE FROM products_backup
--testen
SELECT * FROM products_backup


--abschliessen ohne commit
ROLLBACK 

/*Aufgabe 12
Lösche den Inhalt der Tabelle products_backup mit einem DDL-Befehl.
*/
TRUNCATE TABLE products_backup;

SELECT * FROM products_backup;

/*Aufgabe 13
Lösche die gesamte Tabelle products_backup
*/
DROP TABLE products_backup;

/*Aufgabe 14
Erstelle nochmals eine Kopie der Produktetabelle. Ändere den Produktnamen eines beliebten Produktes in der Produkte-Tabelle.
Du möchtest nun diese Anpassung wieder rückgängig machen. Verwende hierzu einen Merge.
Kontrolliere die Änderungen jeweils mit einer Abfrage.
*/
--Erstelle nochmals ein Backup der Produktetabelle.
SELECT * INTO products_backup FROM Products;

--Ändere den Produktnamen eines beliebten Produktes in der Produkte-Tabelle.
UPDATE Products
SET ProductName='Chai Tea'
WHERE ProductName='Chai'




--Kontrolliere die Änderungen jeweils mit einer Abfrage.
SELECT * FROM Products;
SELECT * FROM products_backup;

--Du möchtes nun diese Anpassung wieder rückgängig machen. Verwende hierzu einen Merge.
MERGE products p
USING products_backup pb ON p.productid=pb.productid
WHEN MATCHED THEN
UPDATE SET p.productname=pb.productname;

/*Aufgabe 15
Erstelle einen neues Login und einen User mit dem Namen Test. 
Erteile dem Login nur Leserechte auf der ganzen Northwind-Datenbank, 
indem du ihm die entsprechende Datenbankrolle zuteilst. Teste das neue Login. 
Um die Berechtigungen zu testen, führst du ein SELECT sowie ein UPDATE, INSERT oder DELETE-Statement aus. 
Was stellst du fest?
*/
USE master
GO

CREATE LOGIN test
WITH PASSWORD = 'test', CHECK_POLICY = OFF;

-- Einem Login ein User zuordnen
USE Northwind
GO
CREATE USER test FOR LOGIN test;

-- Erteile dem User nur Leserechte auf der ganzen Northwind-Datenbank indem Du ihm die entsprechende Datenbankrolle zuteilst.
USE Northwind
GO
ALTER ROLE db_datareader ADD MEMBER test;

EXECUTE AS USER = 'test';
GO

SELECT USER;

SELECT * FROM hr.salaries;

UPDATE Products
SET ProductName='Chai Ten'
WHERE ProductName='Chai';

REVERT;

/*Aufgabe 16
Erteile dem User test die UPDATE-Berechtigung und teste die Berechtigung.
*/
REVERT;
SELECT USER_NAME();

GRANT UPDATE ON products TO test;

EXECUTE AS USER = 'test';
GO

UPDATE Products
SET ProductName='Chai Ten'
WHERE ProductName='Chai';

SELECT * FROM Products;

REVERT;
SELECT USER_NAME();

/*Aufgabe 17
Entziehe dem User test sämtliche Berechtigungen. Der User test soll nur auf Objekte im Schema hr und folgende Berechtigungen  SELECT, 
UPDATE, DELTE und INSERT erhalten. 
Die Tabelle Employees soll zuerst aber noch in das Schema hr transferiert werden.
*/
USE Northwind;
GO
ALTER ROLE db_datareader DROP MEMBER test;

REVOKE UPDATE ON products TO test;


ALTER SCHEMA hr Transfer dbo.Employees;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::hr
TO test;

/*Aufgabe 18
Damit die Löhne nicht ausgelesen werden können, musst du eine Default-Maskierung bei der Salary-Tabelle erstellen und austesten.
*/
SELECT * FROM hr.salaries

ALTER TABLE hr.salaries
ALTER COLUMN salary ADD MASKED WITH (FUNCTION = 'default()');

CREATE USER XY WITHOUT LOGIN;

ALTER ROLE db_datareader ADD MEMBER XY;

EXECUTE AS USER ='XY';
GO
SELECT * FROM hr.salaries
REVERT;




/*Aufgabe 19
Berechne den Gesamtumsatz für das Jahr 1997. Der Rabatt soll dabei berücksichtigt werden.
*/

select * from orders

SELECT SUM(Quantity*UnitPrice * (1-Discount)) AS GESAMTUMSATZ  FROM Orders o
JOIN [Order Details] od ON o.OrderID=od.OrderID
WHERE year(o.OrderDate) = 1997


/*Aufgabe 20
Liste die Gesamtbestellsumme (ohne Rabatt) jedes einzelnen Kunden auf.
*/
SELECT c.customerid, SUM(od.unitprice*od.quantity) AS Bestellwert FROM customers c
JOIN orders o ON c.customerid = o.customerid
JOIN [order details] od ON o.orderid = od.orderid
GROUP BY c.customerid;

/*Aufgabe 21
Liste alle Lieferanten auf, die mehr als 4 Produkte liefern.
*/
SELECT s.CompanyName FROM products p
JOIN suppliers s ON p.SupplierID = s.SupplierID
GROUP BY s.CompanyName
HAVING count(distinct p.Productname) > 4;
GO

/*Aufgabe 22
Welcher Mitarbeiter hat am meisten Tofu verkauft? 
Erstelle eine Abfrage, die den Vornamen und den Nachnamen des Mitarbeites ausgibt sowie die Anzahl Tofu, die er verkauft hat.   
*/
SELECT TOP 1 e.FirstName, e.LastName, p.ProductName , sum(od.Quantity) AS 'Anzahl'
FROM Employees e 
JOIN Orders o ON e.EmployeeID = o.EmployeeID    
JOIN [Order Details] od ON o.OrderID = od.OrderID 
JOIN Products p ON od.ProductID = p.ProductID 
WHERE  p.ProductName = 'Tofu' 
GROUP BY e.FirstName, e.LastName, p.ProductName  
ORDER BY Count(p.ProductName) DESC

/*Aufgabe 23
Liste den Nachnamen des Mitarbeiters auf, der am längsten angestellt ist.
*/
SELECT TOP 1 LastName FROM hr.Employees
ORDER BY Hiredate;
-- oder
SELECT LastName FROM Employees
WHERE HireDate = (SELECT MIN(HireDate) FROM hr.Employees);


/*Aufgabe 24
Du musst für jeden Mitarbeiter ein Usernamen generieren. 
Der Username setzt sich aus den ersten 3 Buchstaben des Nachnamens und den ersten 3 Buchstaben des Vornamens zusammen. 
Schreibe das SELECT-Statement, welches dir für jeden Mitarbeiter einen Usernamen generiert 
(alle Buchstaben in Lowercase).
*/
SELECT LOWER(LEFT(Lastname,3)+LEFT(Firstname,3)) FROM [hr].[Employees];
-- oder
SELECT LOWER(SUBSTRING(Lastname,1,3)+SUBSTRING(Firstname,1,3)) FROM [hr.Employees];

/*Aufgabe 25
Du musst für deinen Chef die neuen Personalnummern generieren. 
Er möchte, dass sich die Personalnummer wie folgt zusammensetzt: 
(Einstellungsjahr+Einstellungsmonat+Einstellungstag) multipliziert mit der EmployeeID.
*/
SELECT (YEAR(hiredate)+MONTH(hiredate)+DAY(hiredate))* employeeID FROM [hr].[Employees];

/*
Aufgabe 26
Dein Chef möchte von jedem Mitarbeiter das Alter in Jahren wissen.
*/
SELECT birthdate FROM hr.Employees

SELECT Firstname, Lastname, birthdate, DATEDIFF(MONTH,birthdate,GETDATE()) / 12 FROM hr.Employees
--performance Index

/*
Aufgabe 27
Analysiere die Abfrage über alle Produktenamen. Wirf einen Blick auf den Index in der Spalte der Produktenamen 
und lösche dann diesen Index. Analysiere anschliessend die Abfrage über alle Produktenamen erneut. Was stellst du fest? 
Erstelle den zuvor gelöschten Index zum Abschluss wieder.
*/
SELECT productname FROM Products WHERE ProductName LIKE 'c%'

DROP INDEX [ProductName] ON [dbo].[Products]
GO

CREATE INDEX [ProductName] ON [dbo].[Products] (ProductName)
GO



