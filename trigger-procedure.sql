-- 1 Skonstruuj procedurę wyświetlającą informacje o zamówieniach dokonanych pomiędzy podanymi datami.

CREATE PROCEDURE zamowieniaMiedzy @Od DATETIME, @Do DATETIME
AS
SELECT * FROM Orders
WHERE OrderDate > @Od AND OrderDate < @Do
ORDER BY OrderDate ASC
GO
--
EXEC zamowieniaMiedzy '1996-10-10', '2000-01-01'

-- 2 Skonstruuj procedurę wyświetlającą informacje o zamówieniach dostarczanych do kraju, którego nazwa 
--   zawiera podaną frazę oraz o wartości większej niż (również) podana.

CREATE PROCEDURE zamowieniaZ @Fraza NVARCHAR(15), @Cena MONEY
AS
SELECT *
FROM Orders O
WHERE O.ShipCountry LIKE '%'+@Fraza+'%' AND EXISTS (    SELECT O.OrderId 
                                                        FROM [Order Details] Od
                                                        INNER JOIN Orders O 															
                                                        ON O.OrderID = Od.OrderID
                                                        GROUP BY O.OrderID
                                                        HAVING SUM(Od.UnitPrice * Od.Quantity * (1 - Od.Discount)) > @Cena)
GO
--
EXEC zamowieniaZ 'USA', 10000

-- 3 Zaprojektuj wyzwalacz wypisujący (PRINT) nazwę produktu oraz nazwę kategorii po każdorazowym dodaniu 
--   nowego produktu do tabeli ‘Products’

CREATE TRIGGER wyswietl
ON Products
AFTER INSERT
AS
DECLARE @produkt NVARCHAR(40), @kategoria NVARCHAR(15)

SELECT @produkt = ProductName FROM INSERTED

SELECT @kategoria = C.CategoryName
FROM INSERTED I, Categories C
WHERE I.CategoryID = C.CategoryID

PRINT 'P:' + @produkt + '; K: ' + CAST(@kategoria AS VARCHAR(40)) + ';'
--
INSERT INTO Products(ProductName, CategoryID)
VALUES ('Produkt', 1)

-- 4 Skonstruuj procedurę ustawiającą rabat (Discount) o podanej wysokości produktom, których wartość 
--   (cena jednostkowa · ilość) jest większa niż podana wartość.

CREATE PROCEDURE ustawRabat @Cena MONEY, @Rabat REAL
AS
UPDATE [Order Details]
SET Discount = @Rabat
WHERE UnitPrice * Quantity > @Cena
GO
--
EXEC ustawRabat 100, 0.2

-- 5 Dodaj nową kolumnę do tabeli ‘Orders’ o nazwie ‘LastModified’ przechowującą datę ostatniej 
--   modyfikacji zamówienia. Następnie zaprojektuj wyzwalacz uaktualniający datę modyfikacji zamówienia w odpowiedzi 
--   na jakąkolwiek zmianę (INSERT, UPDATE, DELETE) w tabeli ‘Order Details’ (dotyczącą danego zamówienia).

ALTER TABLE Orders
ADD LastModified DATETIME;
--
CREATE TRIGGER odswiezModyfikacje
ON [Order Details]
AFTER INSERT, UPDATE, DELETE
AS
DECLARE @TempKey INT = NULL

IF EXISTS (SELECT * FROM INSERTED)
BEGIN
  	SELECT @TempKey = OrderID FROM INSERTED
END
ELSE IF EXISTS (SELECT * FROM UPDATED)
BEGIN
  	SELECT @TempKey = OrderID FROM UPDATED
END
ELSE IF EXISTS (SELECT * FROM DELETED)
BEGIN
	SELECT @TempKey = OrderID FROM DELETED
END

IF (@TempKey != NULL)
BEGIN
    UPDATE Orders
    SET	LastModified = GETDATE()
    WHERE OrderID = @TempKey
END
--
UPDATE [Order Details]
SET Quantity = 2
WHERE OrderID = 10248;

-- 6 Zaprojektuj wyzwalacz, który po dodaniu nowego klienta wypisze (PRINT) informacje o produktach zakupionych przez klientów z tego samego miasta co nowy klient.
CREATE TRIGGER pokazProdukty
ON Customers
AFTER INSERT
AS DECLARE @TempCity NVARCHAR(15), @TempProduct NVARCHAR(40)
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

-- 7 Zaprojektuj wyzwalacz, który przed dodaniem nowego produktu do zamówienia sprawdzi czy liczba zamawianych sztuk nie przekracza bieżącego stanu magazynowego (UnitsInStock). Jeżeli w magazynie nie ma wystarczającej liczby sztuk zamawianego produktu transakcję należy wycofać, w przeciwnym przypadku należy uaktualnić stan magazynowy oraz dodać produkt do zamówienia 
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

-- 8 Skonstruuj procedurę dodającą produkt (o podanej nazwie) do zamówienia klienta (o podanej nazwie firmy). Jeżeli dany klient nie posiada żadnych zamówień, to utwórz nowe przypisując do niego pracownika, który „obsługuje” najmniej zamówień. W przypadku gdy klient posiada zamówienia, to dodaj produkt do tego, które zawiera najmniej produktów. 
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
	FROM (	SELECT TOP 1 EmployeeID, COUNT(OrderID) Amount
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
FROM (	SELECT TOP 1 OD.OrderID, COUNT(OD.ProductID) Minimal
	FROM Orders O
	INNER JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	WHERE O.CustomerID = @CustomerId
	GROUP BY OD.OrderID
	ORDER BY Minimal ASC) Out

INSERT INTO [Order Details] 
VALUES (@OrderId, @ProductId, @UnitPrice, 1, 0)

GO

EXEC dodajProduktDo 'Lonesome Pine Restaurant', 'Chang'
