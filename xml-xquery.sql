--1 Wypisz wszystkie informacje o produktach (z tabeli Products) w postaci dokumentu XML (PATH, ROOT, XMLNAMESPACES)

WITH XMLNAMESPACES ('http://put.poznan.pl' AS ns)
SELECT *
FROM Products
FOR XML PATH('Products'), ROOT('Product');

--2 Utwórz nową tabelę o nazwie XmlProducts (nie korzystaj z CREATE TABLE) zawierającą dwie kolumny — identyfikator 
--  produktu oraz wszystkie inne dane zapisane w postaci dokumentu xml (CAST)

WITH XMLNAMESPACES ('http://put.poznan.pl' AS ns)
SELECT ProductID
	, CAST((SELECT P.* FOR XML PATH('Product')) AS XML) AS Data
INTO XmlProducts
FROM Products P;

--3 Utwórz zapytanie zwracające identyfikatory produktów, nazwy produktów oraz dokument XML zawierający nazwy 
-- produktów oraz ceny jednostkowe z tabeli XmlProducts (posortuj wyniki według nazwy produktu).

WITH XMLNAMESPACES ('http://put.poznan.pl' AS ns)
SELECT ProductID
	, Data.value('(//ProductName)[1]', 'varchar(30)') AS ProductName
	, CAST(Data.query('
		for $x in Product
		return <ProductInfo>{($x/ProductName, $x/UnitPrice)}</ProductInfo>') AS XML) AS Result
FROM XmlProducts
ORDER BY ProductName;

--4 Korzystając tylko z tabeli XmlProducts wyświetl identyfikatory produktów, nazwy produktów oraz ceny 
--  jednostkowe, ale uwzględniając tylko produkty wycofane. Dodatkowo dodaj „korzeń” o nazwie <DiscontinuedProducts>

DECLARE @t XML = (SELECT Data FROM XmlProducts FOR XML AUTO);

WITH XMLNAMESPACES ('http://put.poznan.pl' AS ns)
SELECT @t.query('
	for $x in //Product
	where $x/Discontinued = 1
	return <Product>{($x/ProductID, $x/ProductName, $x/UnitPrice, $x/Discontinued)}</Product>
') FOR XML RAW('DiscontinuedProducts');

--5 Skonstruuj zapytanie wyświetlające produkty, których cena jednostkowa jest większa niż 100 (sto), w postaci 
-- pokazanej poniżej (tylko tabela XmlProducts).

DECLARE @t XML = (SELECT DATA FROM XmlProducts FOR XML AUTO);

WITH XMLNAMESPACES ('http://put.poznan.pl' AS ns)
SELECT @t.query('
	for $x in //Product
	where $x/UnitPrice > 100
	return <Produkt id="{data($x/ProductID)}"><Nazwa>{data($x/ProductName)}</Nazwa><Cena>{data($x/UnitPrice)}</Cena></Produkt>
') FOR XML RAW('DrogieProdukty');

--6 Utwórz zapytanie wyświetlające dokument XML zawierający informacje o zamówieniach (tabele Orders oraz Order Details), 
-- których całkowita wartość przekroczyła 15000 (piętnaście tysięcy).

SELECT O.*
	, CAST((	SELECT Z.* FROM [Order Details] AS Z
				WHERE Z.OrderID = O.OrderID
				FOR XML RAW('Detail')) AS XML) 
FROM Orders O
FOR XML RAW('Order'), ROOT('Orders');
