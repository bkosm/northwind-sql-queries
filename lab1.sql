--1
select * from Customers where CompanyName like 'C%' and len(Country) > 6;
--2
select OrderID, UnitPrice * Quantity * Discount as OverallPrice from [Order Details];
--3
select OrderID, sum(UnitPrice * Quantity * Discount) as OverallPrice from [Order Details] group by OrderID;
--4
select OrderID, count(distinct ProductID) as UniqueProducts, sum(UnitPrice * Quantity * Discount) as OverallPrice 
from [Order Details] group by OrderID;
--5
select OrderID, 
count(distinct ProductID) as UniqueProducts, 
round(sum(UnitPrice * Quantity * Discount), 2) as OverallPrice 
from [Order Details] group by OrderID order by OverallPrice desc;
--6
select SupplierID, avg(UnitPrice) as AveragePrice 
from Products group by SupplierID order by AveragePrice asc;
--7
select ProductName from Products where Discontinued = 0 and UnitPrice < 12;
