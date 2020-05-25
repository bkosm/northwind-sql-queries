-- 1 Utwórz nowy widok o nazwie ‘Products From USA’ zawierający produkty dostarczane przez dostawców z ‘USA’.
CREATE VIEW "Products from USA" AS
SELECT ProductName
FROM Products
WHERE SupplierID IN (SELECT SupplierID
FROM Suppliers S
WHERE S.Country = 'USA');
-- 2 Wyświetl klientów, którzy nie zakupili żadnego produktu (użyj NOT IN).
SELECT ContactName
FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID
FROM Orders);
-- 3 Wyświetl wszystkie możliwe pary (iloczyn kartezjański) imion i nazwisk pracowników (FirstName, LastName).
SELECT A.FirstName, B.LastName
FROM Employees A CROSS JOIN Employees B;
-- 4 Wyświetl nazwy firm klientów (CompanyName) oraz zamówione przez nie produkty (ProductName).
SELECT c.CompanyName, p.ProductName
FROM Customers c
INNER JOIN [Orders] o on o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od on od.OrderID = o.OrderID
INNER JOIN Products p on p.ProductID = od.ProductID
ORDER BY CompanyName;
-- 5 Wyświetl nazwy firm klientów (CompanyName) oraz należność za wszystkie zamówione produkty, sortując wyniki po wartości należności malejąco.
SELECT c.CompanyName, SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS Total
FROM Customers c
INNER JOIN [Orders] o on o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od on od.OrderID = o.OrderID
INNER JOIN Products p on p.ProductID = od.ProductID
GROUP BY c.CompanyName
ORDER BY Total DESC;
-- 6 Wyświetl nazwy firm klientów, którzy nie złożyli żadnego zamówienia (użyj OUTER JOIN).
SELECT c.CompanyName
FROM Customers c
FULL OUTER JOIN Orders o 
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;
-- 7 Wyświetl łączną ilość zamówień produktów danej kategorii (podając nazwę kategorii).
SELECT c.CategoryName, COUNT(od.ProductID) AS NofOrders
FROM Products p
RIGHT JOIN [Order Details] od
ON p.ProductID = od.ProductID
FULL OUTER JOIN Categories c
ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;
-- 8 Zwiększ o 10% ceny produktom, które zostały zakupione przez co najmniej dziesięciu różnych klientów.
UPDATE Products
SET UnitPrice = UnitPrice * 1.1
WHERE EXISTS (SELECT *
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
WHERE od.ProductID = ProductID
GROUP BY od.ProductID
HAVING COUNT(DISTINCT o.CustomerID) > 10);
-- 9 Zapisz do nowej tabeli o nazwie ‘Customer Product Employee’ informacje o tym kto zamówił produkt (CompanyName), nazwę zamówionego produktu (ProductName) oraz imię i nazwisko pracownika powiązanego z danym zamówieniem (FirstName, LastName) (tylko trzy kolumny, czwartą może być klucz główny).
CREATE TABLE "Customer Product Employee" (
	CompanyName	nvarchar(40) not null,
	ProductName	nvarchar(40) not null,
	FullName	nvarchar(31) not null
);
INSERT INTO "Customer Product Employee"
SELECT c.CompanyName, p.ProductName, e.FirstName + ' ' + e.LastName
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Customers c
ON c.CustomerID = o.CustomerID
INNER JOIN Employees e
ON e.EmployeeID = o.EmployeeID
INNER JOIN Products p
ON p.ProductID = od.ProductID;
-- 10 Skopiuj informacje o dostawcach, którzy nie dostarczają żadnych produktów (Suppliers) do tabeli klientów (Customers).
INSERT INTO Customers
SELECT CAST(s.SupplierID AS nchar(5)), s.CompanyName, s.ContactName, s.ContactTitle, s.Address, s.City, s.Region, s.PostalCode, s.Country, s.Phone, s.Fax
FROM Suppliers s
LEFT JOIN Products p
ON p.SupplierID = s.SupplierID
WHERE p.SupplierID IS NULL;
-- 11 Utwórz nowy widok o nazwie ‘Orders Prices’ zawierający identyfikator zamówienia oraz jego wartość (po uwzględnieniu ilości produktów oraz zniżek).
CREATE VIEW "Orders Prices" AS
SELECT o.OrderID, SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) Total
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID;