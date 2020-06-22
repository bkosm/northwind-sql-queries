--1 Wypisz wszystkich klientów (Customers), których nazwę firmy rozpoczyna litera ‘C‘, 
--  a ilość znaków składające się na nazwę kraju (Country) jest większa niż 6 (sześć).

SELECT * 
FROM Customers 
WHERE CompanyName LIKE 'C%' AND LEN(Country) > 6;

--2 Wypisz wszystkie identyfikatory zamówień (Order Details) wraz z obliczoną wartością 
--  dla każdego produktu należącego do danego zamówienia (cena jednostkowa, ilość, rabat), 
--  odpowiednio nazwij nowo powstałą kolumnę.

SELECT OrderID
	, UnitPrice * Quantity * Discount AS OverallPrice 
FROM [Order Details];

--3 Rozszerz poprzednie zapytanie tak, aby uzyskać identyfikatory zamówień wraz z wartościami 
--  (kwotami do zapłaty) za całe zamówienia (zapoznaj się z GROUP BY).

SELECT OrderID
	, SUM(UnitPrice * Quantity * Discount) AS OverallPrice 
FROM [Order Details] 
GROUP BY OrderID;

--4 Rozszerz poprzednie zapytanie o wypisywanie liczby unikatowych produktów składających się 
--  na konkretne zamówienie (odpowiednio nazwij nową kolumnę).

select OrderID
	, COUNT(distinct ProductID) as UniqueProducts
	, SUM(UnitPrice * Quantity * Discount) AS OverallPrice 
FROM [Order Details] 
GROUP BY OrderID;

--5 Zaokrąglij uzyskane w poprzednim zapytaniu wartości zamówień do dwóch miejsc po przecinku, 
--  a następnie posortuj wyniki malejąco (od największej do najmniejszej wartości).

select OrderID
	, COUNT(distinct ProductID) as UniqueProducts
	, ROUND(SUM(UnitPrice * Quantity * Discount), 2) AS OverallPrice 
FROM [Order Details] 
GROUP BY OrderID 
ORDER BY OverallPrice DESC;

--6 Wypisz średnie ceny produktów dostarczanych przez poszczególnych dostawców (nazwij nową kolumnę), 
--  posortuj obliczone ceny rosnąco.

SELECT SupplierID
	, AVG(UnitPrice) as AveragePrice 
FROM Products 
GROUP BY SupplierID 
ORDER BY AveragePrice;

--7 Wypisz wszystkie produkty, których nie wycofano (kolumna Discontinued) i ich cena jednostkowa jest mniejsza niż 12.

SELECT ProductName 
FROM Products 
WHERE Discontinued = 0 AND UnitPrice < 12;

--8 Wypisz wartość wszystkich produktów w magazynie (wynikiem powinna być tylko jedna liczba).

SELECT SUM(UnitsInStock * UnitPrice) AS TotalValue 
FROM Products;

--9 Wypisz średnią cenę produktów danej kategorii (dla wszystkich kategorii), jeżeli dana kategoria 
--  zawiera mniej niż 10 różnych produktów (użyj HAVING).

SELECT CategoryID
	, AVG(UnitPrice) AS AvgPrice 
FROM Products 
GROUP BY CategoryID 
HAVING COUNT(ProductID) < 10;

--10 Wypisz średnią, minimalną i maksymalną cenę oraz ilość produktów dla każdej kategorii, 
--   zaokrąglij ceny do dwóch miejsc po przecinku.

SELECT CategoryID
	, ROUND(AVG(UnitPrice), 2) AS AvgPrice
	, ROUND(MIN(UnitPrice), 2) AS MinPrice
	, ROUND(MAX(UnitPrice), 2) AS MaxPrice
	, SUM(UnitsInStock) AS Units
FROM Products
GROUP BY CategoryID;

--11 Wypisz alfabetycznie nazwy firm z Polski, Niemiec i USA (Customers) dodając każdej firmie 
--   z Polski przedrostek ‘PL_’, każdej firmie z Niemiec przedrostek ‘DE_’, a każdej firmie z 
--   USA przedrostek ‘USA_’ (skorzystaj z UNION).

SELECT 'DE_' + CompanyName AS Name 
FROM Customers 
WHERE Country = 'Germany'
UNION
SELECT 'US_' + CompanyName AS Name 
FROM Customers 
WHERE Country = 'USA'
UNION
SELECT 'PL_' + CompanyName AS Name 
FROM Customers 
WHERE Country = 'Poland'
ORDER BY Name;

--12 Wypisz nazwę najtańszego produktu każdego dostawcy (podzapytanie)

SELECT SupplierID
	, ProductName as Cheapest 
FROM Products P
WHERE P.UnitPrice IN (	SELECT MIN(UnitPrice) 
			FROM Products Pi 
			WHERE P.SupplierID = Pi.SupplierID);
