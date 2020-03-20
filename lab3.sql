-- 1
CREATE VIEW "Products from USA" AS
SELECT ProductName
FROM Products
WHERE SupplierID IN (SELECT SupplierID
FROM Suppliers S
WHERE S.Country = 'USA');
-- 2
SELECT ContactName
FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID
FROM Orders);
-- 3
SELECT A.FirstName, B.LastName
FROM Employees A CROSS JOIN Employees B;
-- 4
SELECT c.CompanyName, p.ProductName
FROM Customers c
INNER JOIN [Orders] o on o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od on od.OrderID = o.OrderID
INNER JOIN Products p on p.ProductID = od.ProductID
ORDER BY CompanyName;
-- 5
SELECT c.CompanyName, SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS Total
FROM Customers c
INNER JOIN [Orders] o on o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od on od.OrderID = o.OrderID
INNER JOIN Products p on p.ProductID = od.ProductID
GROUP BY c.CompanyName
ORDER BY Total DESC;
-- 6
SELECT c.CompanyName
FROM Customers c
FULL OUTER JOIN Orders o 
ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;
-- 7
SELECT c.CategoryName, COUNT(od.ProductID) AS NofOrders
FROM Products p
RIGHT JOIN [Order Details] od
ON p.ProductID = od.ProductID
FULL OUTER JOIN Categories c
ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;
