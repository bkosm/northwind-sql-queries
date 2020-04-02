-- 1
CREATE PROCEDURE zamowieniaMiedzy @Od DATETIME, @Do DATETIME
AS
SELECT * FROM Orders
WHERE OrderDate > @Od AND OrderDate < @Do
ORDER BY OrderDate ASC
GO
EXEC zamowieniaMiedzy '1996-10-10', '2000-01-01'
-- 2
CREATE PROCEDURE zamowieniaZ @fraza NVARCHAR(15), @cena MONEY
AS
SELECT *
FROM Orders o
WHERE o.ShipCountry LIKE '%'+@Fraza+'%' AND EXISTS (SELECT o.OrderId
FROM [Order Details] od
INNER JOIN Orders o 
ON o.OrderID = od.OrderID
GROUP BY o.OrderID
HAVING SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) > @Cena)
GO
EXEC zamowieniaZ 'USA', 10000
-- 3
CREATE TRIGGER wyswietl
ON Products
AFTER INSERT
AS DECLARE
@produkt NVARCHAR(40),
@kategoria INT;

BEGIN
SELECT @produkt = ProductName FROM INSERTED
SELECT @kategoria = CategoryID FROM INSERTED

PRINT 'P:' + @produkt + '; K: ' + CAST(@kategoria AS VARCHAR(40)) + ';'
END
INSERT INTO Products(ProductName, CategoryID)
VALUES ('Produkt', 1)
