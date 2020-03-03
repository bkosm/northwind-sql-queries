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
--8
select sum(UnitsInStock) as TotalUnits from Products;
--9
select CategoryID, avg(UnitPrice) as AvgPrice from Products 
group by CategoryID having count(CategoryID) < 10;
--10
select CategoryID,
round(min(UnitPrice), 2) as MinPrice,
round(avg(UnitPrice), 2) as AvgPrice,
round(max(UnitPrice), 2) as MaxPrice,
min(UnitsInStock) as MinUnits,
avg(UnitsInStock) as AvgUnits,
max(UnitsInStock) as MaxUnits
from Products
group by CategoryID;
--11
select 'DE_' + CompanyName as Name from Customers where Country = 'Germany'
union
select 'US_' + CompanyName as Name from Customers where Country = 'USA'
union
select 'PL_' + CompanyName as Name from Customers where Country = 'Poland' order by Name asc;
--12
select SupplierID, min(UnitPrice) as MinPrice from Products 
where SupplierID = (select SupplierID from Suppliers) 
order by SupplierID;
