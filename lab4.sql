-- 1
CREATE PROCEDURE zamowieniaMiedzy @Od DATETIME, @Do DATETIME
AS
SELECT * FROM Orders
WHERE OrderDate > @Od AND OrderDate < @Do
ORDER BY OrderDate ASC
GO

EXEC zamowieniaMiedzy '1996-10-10', '2000-01-01'
-- 2
CREATE PROCEDURE zamowieniaZ @Fraza NVARCHAR(15), @Cena MONEY
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
-- 4
CREATE PROCEDURE ustawRabat @Cena MONEY, @Rabat REAL
AS
UPDATE [Order Details]
SET Discount = @Rabat
WHERE UnitPrice * Quantity > @Cena
GO

EXEC ustawRabat 100, 0.2
-- 5
ALTER TABLE Orders
ADD LastModified DATETIME;

CREATE TRIGGER odswiezModyfikacje
ON Orders
AFTER INSERT, UPDATE, DELETE
AS
DECLARE @TempKey int
IF EXISTS (SELECT * FROM inserted I) AND EXISTS (SELECT * FROM deleted)
BEGIN
  SELECT @TempKey = I.OrderID FROM inserted I
	UPDATE Orders
	SET	LastModified = GETDATE()
	WHERE OrderID = @TempKey
  SELECT @TempKey = D.OrderID FROM deleted D
	UPDATE Orders
	SET	LastModified = GETDATE()
	WHERE OrderID = @TempKey
END
IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
BEGIN
  SELECT @TempKey = I.OrderID FROM inserted I
	UPDATE Orders
	SET	LastModified = GETDATE()
	WHERE OrderID = @TempKey
END
IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
BEGIN
	SELECT @TempKey = D.OrderID FROM deleted D
	UPDATE Orders
	SET	LastModified = GETDATE()
	WHERE OrderID = @TempKey
END

UPDATE Orders 
SET Freight = 12
WHERE OrderID = 10248;
-- 6
CREATE TRIGGER pokazProdukty
ON Customers
AFTER INSERT
AS
DECLARE @TempCity NVARCHAR(15), @TempProduct NVARCHAR(40)
BEGIN
	SELECT @TempCity = I.City FROM inserted I

	DECLARE cur CURSOR FOR
	SELECT DISTINCT P.ProductName FROM Customers C
	INNER JOIN Orders O
	ON O.CustomerID = C.CustomerID
	INNER JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	INNER JOIN Products P
	ON OD.ProductID = P.ProductID
	WHERE C.City LIKE @TempCity

	OPEN cur

	FETCH NEXT FROM cur INTO @TempProduct;
	WHILE @@FETCH_STATUS = 0
	BEGIN   
		PRINT 'Produkt kupiony w ' + @TempCity + ': ' + @TempProduct
		FETCH NEXT FROM cur INTO @TempProduct;
	END

	CLOSE cur;
	DEALLOCATE cur;
END

INSERT INTO Customers (CustomerID, CompanyName, City)
VALUES ('90837', 'NowySklep', 'Graz')
-- 7
CREATE TRIGGER sprawdzStan
ON [Order Details]
INSTEAD OF INSERT
AS
DECLARE @UnitsOrdered SMALLINT, @ProductId INT, @UnitsInStock SMALLINT
BEGIN
	SELECT @UnitsOrdered = I.Quantity, @ProductId = I.ProductID FROM inserted I

	SELECT @UnitsInStock = P.UnitsInStock
	FROM Products P
	WHERE P.ProductID = @ProductId

	IF @UnitsOrdered > @UnitsInStock
	BEGIN
		PRINT 'Zbyt mala ilosc sztuk na stanie do przeprowadzenia transakcji'
		ROLLBACK TRANSACTION
		RETURN
	END

	UPDATE Products
	SET UnitsInStock = UnitsInStock - @UnitsOrdered
	WHERE ProductID = @ProductId

	INSERT INTO [Order Details]
	SELECT * FROM inserted
END

INSERT INTO [Order Details]
VALUES (10248, 5, 31, 2, 0)
-- 8
CREATE PROCEDURE dodajProduktDo @NazwaFirmy NVARCHAR(40), @NazwaProduktu NVARCHAR(40)
AS
DECLARE @CustomerId NCHAR(5)
DECLARE @ProductId INT
DECLARE @UnitPrice MONEY

SELECT @CustomerId = CustomerID
FROM Customers
WHERE CompanyName LIKE @NazwaFirmy

SELECT @ProductId = ProductID, @UnitPrice = UnitPrice
FROM Products
WHERE ProductName LIKE @NazwaProduktu

IF NOT EXISTS (SELECT * FROM Orders WHERE CustomerID = @CustomerId)
BEGIN
	DECLARE @EmployeeId INT
	DECLARE @LastOrderId INT

	SELECT @EmployeeId = Out.EmployeeID
	FROM (SELECT TOP 1 EmployeeID, COUNT(OrderID) Amount
	FROM Orders
	GROUP BY EmployeeID
	ORDER BY Amount ASC) Out

	SELECT @LastOrderId = MAX(OrderID) 
	FROM Orders

	INSERT INTO Orders(OrderID, CustomerID, EmployeeID, OrderDate)
	VALUES (@LastOrderId+1, @CustomerId, @EmployeeId, GETDATE())

	INSERT INTO [Order Details] 
	VALUES (@LastOrderId+1, @ProductId, @UnitPrice, 1, 0)

	RETURN
END	

DECLARE @OrderId INT

SELECT @OrderId = Out.OrderID
FROM (SELECT TOP 1 OD.OrderID, COUNT(OD.ProductID) Minimal
FROM Orders O
INNER JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
WHERE O.CustomerID = @CustomerId
GROUP BY OD.OrderID
ORDER BY Minimal ASC) Out

INSERT INTO [Order Details] 
VALUES (@OrderId, @ProductId, @UnitPrice, 1, 0)

GO
