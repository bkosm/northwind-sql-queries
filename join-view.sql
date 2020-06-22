-- 1 Utwórz nowy widok o nazwie ‘Products From USA’ zawierający produkty dostarczane przez dostawców z ‘USA’.

CREATE VIEW "Products from USA" AS
SELECT * 
FROM Products
WHERE SupplierID IN (	SELECT SupplierID 
				        FROM Suppliers
						WHERE Country = 'USA');

-- 2 Wyświetl klientów, którzy nie zakupili żadnego produktu (użyj NOT IN).

SELECT *
FROM Customers
WHERE CustomerID NOT IN (	SELECT CustomerID
							FROM Orders);

-- 3 Wyświetl wszystkie możliwe pary (iloczyn kartezjański) imion i nazwisk pracowników (FirstName, LastName).

SELECT A.FirstName, B.LastName
FROM Employees A CROSS JOIN Employees B;

-- 4 Wyświetl nazwy firm klientów (CompanyName) oraz zamówione przez nie produkty (ProductName).

SELECT C.CompanyName, P.ProductName
FROM Customers C
INNER JOIN Orders O ON O.CustomerID = C.CustomerID
INNER JOIN [Order Details] Od ON Od.OrderID = O.OrderID
INNER JOIN Products P ON P.ProductID = Od.ProductID;

-- 5 Wyświetl nazwy firm klientów (CompanyName) oraz należność za wszystkie zamówione produkty, sortując 
--   wyniki po wartości należności malejąco.

SELECT C.CompanyName, SUM(Od.UnitPrice * Od.Quantity * (1 - Od.Discount)) AS Total
FROM Customers C
INNER JOIN Orders O ON O.CustomerID = C.CustomerID
INNER JOIN [Order Details] Od ON Od.OrderID = O.OrderID
INNER JOIN Products P ON P.ProductID = Od.ProductID
GROUP BY C.CompanyName
ORDER BY Total DESC;

-- 6 Wyświetl nazwy firm klientów, którzy nie złożyli żadnego zamówienia (użyj OUTER JOIN).

SELECT C.CompanyName
FROM Customers C
FULL OUTER JOIN Orders O 
ON C.CustomerID = O.CustomerID
WHERE O.CustomerID IS NULL;

-- 7 Wyświetl łączną ilość zamówień produktów danej kategorii (podając nazwę kategorii).

SELECT C.CategoryName, COUNT(Od.ProductID) AS Orders
FROM Products P
RIGHT JOIN [Order Details] Od
ON Od.ProductID = P.ProductID
FULL OUTER JOIN Categories c
ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName;

-- 8 Zwiększ o 10% ceny produktom, które zostały zakupione przez co najmniej dziesięciu różnych klientów.

UPDATE Products
SET UnitPrice *= 1.1
WHERE EXISTS (	SELECT *
				FROM Orders O
				INNER JOIN [Order Details] Od
				ON o.OrderID = od.OrderID
				HAVING COUNT(DISTINCT O.CustomerID) >= 10);

-- 9 Zapisz do nowej tabeli o nazwie ‘Customer Product Employee’ informacje o tym kto zamówił produkt 
--   (CompanyName), nazwę zamówionego produktu (ProductName) oraz imię i nazwisko pracownika powiązanego 
--   z danym zamówieniem (FirstName, LastName) (tylko trzy kolumny, czwartą może być klucz główny).

CREATE TABLE [Customer Product Employee] (
	CompanyName	VARCHAR(40) NOT NULL,
	ProductName	VARCHAR(40) NOT NULL,
	FullName	VARCHAR(31) NOT NULL
);

INSERT INTO [Customer Product Employee]
SELECT C.CompanyName, P.ProductName, E.FirstName + ' ' + E.LastName
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Customers C ON C.CustomerID = O.CustomerID
INNER JOIN Employees E ON E.EmployeeID = O.EmployeeID
INNER JOIN Products P ON P.ProductID = Od.ProductID;

-- 10 Skopiuj informacje o dostawcach, którzy nie dostarczają żadnych produktów (Suppliers) do tabeli klientów (Customers).

INSERT INTO Customers
SELECT CAST(s.SupplierID AS NCHAR(5))
	, s.CompanyName
	, s.ContactName
	, s.ContactTitle
	, s.Address
	, s.City
	, s.Region
	, s.PostalCode
	, s.Country
	, s.Phone
	, s.Fax
FROM Suppliers S
LEFT JOIN Products P
ON P.SupplierID = S.SupplierID
WHERE P.SupplierID IS NULL;

-- 11 Utwórz nowy widok o nazwie ‘Orders Prices’ zawierający identyfikator zamówienia oraz jego wartość 
-- (po uwzględnieniu ilości produktów oraz zniżek).

CREATE VIEW [Orders Prices] AS
SELECT O.OrderID
	, SUM(Od.UnitPrice * Od.Quantity * (1 - Od.Discount)) AS Total
FROM Orders O
INNER JOIN [Order Details] Od
ON O.OrderID = Od.OrderID
GROUP BY O.OrderID;
