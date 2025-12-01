--***ex1
--WITH YearlySales AS (
--SELECT  YEAR(InvoiceDate) AS SalesYear, SUM(ExtendedPrice) AS TotalRevenue
-- FROM Sales.Invoices AS i JOIN Sales.InvoiceLines AS il 
-- ON i.InvoiceID = il.InvoiceID
-- GROUP BY YEAR(InvoiceDate)),

--cte1 AS (
-- SELECT SalesYear,TotalRevenue, LAG(TotalRevenue) OVER (ORDER BY SalesYear) AS PreviousYearRevenue
--    FROM YearlySales)

--SELECT   SalesYear,TotalRevenue,  ROUND(
-- CASE 
-- WHEN PreviousYearRevenue IS NULL THEN NULL
-- ELSE ((TotalRevenue - PreviousYearRevenue) * 100.0) / PreviousYearRevenue
-- END,
-- 2) AS GrowthPercent
--FROM cte1
--ORDER BY SalesYear;

--***ex2
--WITH RevenuePerCustomer AS (
--SELECT c.CustomerID,c.CustomerName,YEAR(i.InvoiceDate) AS SalesYear,DATEPART(QUARTER, i.InvoiceDate) AS SalesQuarter,
-- SUM(il.ExtendedPrice) AS NetRevenue
-- FROM Sales.Invoices AS i JOIN Sales.InvoiceLines AS il
-- ON i.InvoiceID = il.InvoiceID
-- JOIN Sales.Customers AS c ON i.CustomerID = c.CustomerID
-- GROUP BY c.CustomerID, c.CustomerName, YEAR(i.InvoiceDate), DATEPART(QUARTER, i.InvoiceDate)),

--ct1 AS (
--SELECT *,RANK() OVER (  PARTITION BY SalesYear, SalesQuarter
--                         ORDER BY NetRevenue DESC  ) AS CustomerRank
--FROM RevenuePerCustomer)

--SELECt SalesYear, SalesQuarter, CustomerID, CustomerName,NetRevenue,CustomerRank
--FROM ct1
--WHERE CustomerRank <= 5
--ORDER BY SalesYear, SalesQuarter, CustomerRank;

--***ex3

--SELECT TOP 10 si.StockItemID,si.StockItemName,SUM(il.ExtendedPrice - il.TaxAmount) AS TotalProfit
--FROM Sales.InvoiceLines AS il JOIN Warehouse.StockItems AS si 
--ON il.StockItemID = si.StockItemID
--GROUP BY si.StockItemID, si.StockItemName
--ORDER BY TotalProfit DESC;

--***ex4
--SELECT StockItemID, StockItemName, RecommendedRetailPrice, UnitPrice, RecommendedRetailPrice - UnitPrice AS NominalProfit,
--       ROW_NUMBER() OVER (ORDER BY RecommendedRetailPrice - UnitPrice DESC) AS RankByProfit
--FROM Warehouse.StockItems
--WHERE ValidTo > GETDATE()
--ORDER BY NominalProfit DESC;

--***ex5
--SELECT  s.SupplierID, s.SupplierName, STRING_AGG(CAST(si.StockItemID AS VARCHAR) + '-' + si.StockItemName, ', / ') AS ProductList
--FROM Purchasing.Suppliers AS s JOIN Warehouse.StockItems AS si 
--ON s.SupplierID = si.SupplierID
--GROUP BY s.SupplierID, s.SupplierName
--ORDER BY s.SupplierID;

--***ex6

--SELECT TOP 5 c.CustomerID, c.CustomerName, ct.CityName, sp.StateProvinceName, co.CountryName,SUM(il.ExtendedPrice) AS TotalSpent
--FROM Sales.Customers AS c JOIN Sales.Invoices AS i 
--ON c.CustomerID = i.CustomerID
--JOIN Sales.InvoiceLines AS il ON i.InvoiceID = il.InvoiceID
--JOIN Application.Cities AS ct ON c.DeliveryCityID = ct.CityID
--JOIN Application.StateProvinces AS sp ON ct.StateProvinceID = sp.StateProvinceID
--JOIN Application.Countries AS co ON sp.CountryID = co.CountryID
--GROUP BY  c.CustomerID, c.CustomerName, ct.CityName, sp.StateProvinceName,co.CountryName
--ORDER BY TotalSpent DESC;

--***ex7

--WITH MonthlySales AS (
--SELECT YEAR(i.InvoiceDate) AS SalesYear, MONTH(i.InvoiceDate) AS SalesMonth,SUM(il.ExtendedPrice) AS MonthlyTotal
--FROM Sales.Invoices AS i JOIN Sales.InvoiceLines AS il
--ON i.InvoiceID = il.InvoiceID
--GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)),

--CumulativeSales AS (
--SELECT SalesYear, SalesMonth,MonthlyTotal,
--        SUM(MonthlyTotal) OVER(PARTITION BY SalesYear ORDER BY SalesMonth) AS CumulativeTotal
--FROM MonthlySales)

--SELECT SalesYear,SalesMonth,  MonthlyTotal,CumulativeTotal
--FROM CumulativeSales
--UNION ALL

--SELECT SalesYear, NULL AS SalesMonth, SUM(MonthlyTotal),NULL
--FROM MonthlySales
--GROUP BY SalesYear
--ORDER BY SalesYear, SalesMonth;

--***ex8
--SELECT
--    YEAR(OrderDate) AS OrderYear,
--    COUNT(CASE WHEN MONTH(OrderDate) = 1 THEN OrderID END) AS Jan,
--    COUNT(CASE WHEN MONTH(OrderDate) = 2 THEN OrderID END) AS Feb,
--    COUNT(CASE WHEN MONTH(OrderDate) = 3 THEN OrderID END) AS Mar,
--    COUNT(CASE WHEN MONTH(OrderDate) = 4 THEN OrderID END) AS Apr,
--    COUNT(CASE WHEN MONTH(OrderDate) = 5 THEN OrderID END) AS May,
--    COUNT(CASE WHEN MONTH(OrderDate) = 6 THEN OrderID END) AS Jun,
--    COUNT(CASE WHEN MONTH(OrderDate) = 7 THEN OrderID END) AS Jul,
--    COUNT(CASE WHEN MONTH(OrderDate) = 8 THEN OrderID END) AS Aug,
--    COUNT(CASE WHEN MONTH(OrderDate) = 9 THEN OrderID END) AS Sep,
--    COUNT(CASE WHEN MONTH(OrderDate) = 10 THEN OrderID END) AS Oct,
--    COUNT(CASE WHEN MONTH(OrderDate) = 11 THEN OrderID END) AS Nov,
--    COUNT(CASE WHEN MONTH(OrderDate) = 12 THEN OrderID END) AS Dec
--FROM Sales.Orders
--GROUP BY YEAR(OrderDate)
--ORDER BY OrderYear;


--***ex9
--WITH OrderDates AS (
--SELECT CustomerID, OrderDate, LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrderDate
--FROM Sales.Orders),

--OrderIntervals AS (
--SELECT CustomerID,DATEDIFF(DAY, PreviousOrderDate, OrderDate) AS DaysBetween
--FROM OrderDates
--WHERE PreviousOrderDate IS NOT NULL),

--AverageIntervals AS (
--SELECT CustomerID,AVG(DaysBetween) AS AvgDaysBetweenOrders
--FROM OrderIntervals
--GROUP BY CustomerID),

--LastOrder AS (
--SELECT  CustomerID,MAX(OrderDate) AS LastOrderDate
--FROM Sales.Orders
--GROUP BY CustomerID),

--Final AS (
--SELECT c.CustomerID,c.CustomerName, lo.LastOrderDate,
-- DATEDIFF(DAY, lo.LastOrderDate, GETDATE()) AS DaysSinceLastOrder,ai.AvgDaysBetweenOrders,
-- CASE 
-- WHEN DATEDIFF(DAY, lo.LastOrderDate, GETDATE()) > ai.AvgDaysBetweenOrders * 2 
-- THEN 'At Risk'
-- ELSE 'Active'
--END AS Status
--FROM Sales.Customers AS c JOIN LastOrder AS lo 
--ON c.CustomerID = lo.CustomerID
--JOIN AverageIntervals AS ai ON c.CustomerID = ai.CustomerID)

--SELECT *
--FROM Final
--ORDER BY DaysSinceLastOrder DESC;


--***ex10
--WITH GeneralizedCustomers AS (
--SELECT CustomerID,CustomerCategoryID,
-- CASE
--WHEN CustomerName LIKE 'Wingtip%' THEN 'Wingtip (Generalized)'
--WHEN CustomerName LIKE 'Tailspin%' THEN 'Tailspin (Generalized)'
--ELSE CustomerName
--END AS GeneralizedName
--FROM Sales.Customers),

--CategoryCustomerCounts AS (
--SELECT c.CustomerCategoryID, cc.CustomerCategoryName, COUNT(DISTINCT c.CustomerID) AS UniqueCustomerCount
--FROM GeneralizedCustomers AS c JOIN Sales.CustomerCategories AS cc
--ON c.CustomerCategoryID = cc.CustomerCategoryID
--GROUP BY c.CustomerCategoryID, cc.CustomerCategoryName),

--TotalCustomerCount AS (
--SELECT COUNT(DISTINCT CustomerID) AS TotalCount
--FROM GeneralizedCustomers)

--SELECT ccc.CustomerCategoryName, ccc.UniqueCustomerCount,
--    ROUND(CAST(ccc.UniqueCustomerCount AS FLOAT) / tcc.TotalCount * 100, 2) AS CustomerPercentage,
--CASE
--WHEN CAST(ccc.UniqueCustomerCount AS FLOAT) / tcc.TotalCount > 0.3 THEN N'⚠ סיכון גבוה'
--WHEN CAST(ccc.UniqueCustomerCount AS FLOAT) / tcc.TotalCount > 0.15 THEN N'סיכון בינוני'
--ELSE N'סיכון נמוך'
--END AS RiskLevel
--FROM CategoryCustomerCounts AS ccc
--CROSS JOIN TotalCustomerCount AS tcc
--ORDER BY CustomerPercentage DESC;















