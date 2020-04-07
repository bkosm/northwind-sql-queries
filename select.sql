--1 Wypisz wszystkich klientów (Customers), których nazwę firmy rozpoczyna litera ‘C‘, a ilość znaków składające się na nazwę kraju (Country) jest większa niż 6 (sześć).
select * from Customers where CompanyName like 'C%' and len(Country) > 6;
--2 Wypisz wszystkie identyfikatory zamówień (Order Details) wraz z obliczoną wartością dla każdego produktu należącego do danego zamówienia (cena jednostkowa, ilość, rabat), odpowiednio nazwij nowo powstałą kolumnę.
select OrderID, UnitPrice * Quantity * Discount as OverallPrice from [Order Details];
--3 Rozszerz poprzednie zapytanie tak, aby uzyskać identyfikatory zamówień wraz z wartościami (kwotami do zapłaty) za całe zamówienia (zapoznaj się z GROUP BY ).
select OrderID, sum(UnitPrice * Quantity * Discount) as OverallPrice from [Order Details] group by OrderID;
--4 Rozszerz poprzednie zapytanie o wypisywanie liczby unikatowych produktów składających się na konkretne zamówienie (odpowiednio nazwij nową kolumnę).
select OrderID, count(distinct ProductID) as UniqueProducts, sum(UnitPrice * Quantity * Discount) as OverallPrice 
from [Order Details] group by OrderID;
--5 Zaokrąglij uzyskane w poprzednim zapytaniu wartości zamówień do dwóch miejsc po przecinku, a następnie posortuj wyniki malejąco (od największej do najmniejszej wartości).
select OrderID, 
count(distinct ProductID) as UniqueProducts, 
round(sum(UnitPrice * Quantity * Discount), 2) as OverallPrice 
from [Order Details] group by OrderID order by OverallPrice desc;
--6 Wypisz średnie ceny produktów dostarczanych przez poszczególnych dostawców (nazwij nową kolumnę), posortuj obliczone ceny rosnąco.
select SupplierID, avg(UnitPrice) as AveragePrice 
from Products group by SupplierID order by AveragePrice asc;
--7 Wypisz wszystkie produkty, których nie wycofano (kolumna Discontinued) i ich cena jednostkowa jest mniejsza niż 12.
select ProductName from Products where Discontinued = 0 and UnitPrice < 12;
--8 Wypisz wartość wszystkich produktów w magazynie (wynikiem powinna być tylko jedna liczba).
select sum(UnitsInStock) as TotalUnits from Products;
--9 Wypisz średnią cenę produktów danej kategorii (dla wszystkich kategorii), jeżeli dana kategoria zawiera mniej niż 10 różnych produktów (użyj HAVING).
select CategoryID, avg(UnitPrice) as AvgPrice from Products 
group by CategoryID having count(CategoryID) < 10;
--10 Wypisz średnią, minimalną i maksymalną cenę oraz ilość produktów dla każdej kategorii, zaokrąglij ceny do dwóch miejsc po przecinku.
select CategoryID,
round(min(UnitPrice), 2) as MinPrice,
round(avg(UnitPrice), 2) as AvgPrice,
round(max(UnitPrice), 2) as MaxPrice,
min(UnitsInStock) as MinUnits,
avg(UnitsInStock) as AvgUnits,
max(UnitsInStock) as MaxUnits
from Products
group by CategoryID;
--11 Wypisz alfabetycznie nazwy firm z Polski, Niemiec i USA (Customers) dodając każdej firmie z Polski przedrostek ‘PL_’, każdej firmie z Niemiec przedrostek ‘DE_’, a każdej firmie z USA przedrostek ‘USA_’ (skorzystaj z UNION).
select 'DE_' + CompanyName as Name from Customers where Country = 'Germany'
union
select 'US_' + CompanyName as Name from Customers where Country = 'USA'
union
select 'PL_' + CompanyName as Name from Customers where Country = 'Poland' order by Name asc;
--12 Wypisz nazwę najtańszego produktu każdego dostawcy (podzapytanie)
select SupplierID, ProductName as Cheapest from Products as out where out.UnitPrice in 
(select min(UnitPrice) from Products as inn where out.SupplierID = inn.SupplierID);
