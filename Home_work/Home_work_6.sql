1. Выберите заказчиков из Германии, Франции и Мадрида, выведите их название, страну и адрес.

SELECT [CustomerName],
       [Country], 
       [Address] 
  FROM [Customers]
 WHERE [Country] IN ('Germany','France')
 OR [City] = 'Madrid';

2. Выберите топ 3 страны по количеству заказчиков, выведите их названия и количество записей.

SELECT DISTINCT [Country], 
                COUNT([CustomerName]) AS [Number]
  FROM [Customers]
 GROUP BY [Country]
 ORDER BY [Number] DESC
 LIMIT 3;

3. Выберите перевозчика, который отправил 10-й по времени заказ, выведите его название, и дату отправления.

SELECT t1.[ShipperName], 
       t2.[OrderDate] 
  FROM [Shippers] t1
  JOIN [Orders] t2 ON t1.[ShipperID] = t2.[ShipperID]
 ORDER BY t2.[OrderDate] ASC
 LIMIT 1 OFFSET 9;

4. Выберите самый дорогой заказ, выведите список товаров с их ценами.

WITH [max_price_order] AS (SELECT orders.[OrderID], 
                                  SUM(prod.Price*orders.Quantity) AS [OrderPrice]
                           FROM [OrderDetails] orders
                           JOIN [Products] prod  ON prod.[ProductID] = orders.[ProductID]
                       GROUP BY orders.[OrderID]
                       ORDER BY [OrderPrice] DESC
                       LIMIT 1 )

SELECT ord.[orderID], 
       prod.[ProductName], 
       prod.[Price] 
  FROM [OrderDetails] ord
  JOIN [max_price_order] ON [max_price_order].[OrderID] = ord.[OrderID]
  JOIN [Products] prod ON ord.[ProductID] = prod.[ProductID]

5. Какой товар больше всего заказывали по количеству единиц товара, выведите его название и количество единиц в каждом из заказов.

WITH [max_prod] AS (SELECT [ProductID], 
                           SUM([Quantity]) AS [sum_count]
                      FROM OrderDetails
                     GROUP BY ProductID
                     ORDER BY sum_count DESC
                     LIMIT 1)
SELECT  prod.[ProductName], 
        ord.[OrderID], 
        ord.[Quantity]  
  FROM [OrderDetails] ord
  JOIN [max_prod] ON max_prod.[ProductID] = ord.[ProductID]
  JOIN [Products] prod ON max_prod.[ProductID] = prod.[ProductID]
 ORDER BY ord.[Quantity] DESC

6. Выведите топ 5 поставщиков по количеству заказов, выведите их названия, страну, контактное лицо и телефон.

WITH top AS (SELECT DISTINCT ord.[OrderID],
                             prod.[SupplierID],
                             COUNT() AS [cnt]
               FROM [OrderDetails] ord, [Products] prod
              WHERE ord.[ProductID] = prod.[ProductID]
              GROUP BY prod.[SupplierID]
              ORDER BY cnt DESC
              LIMIT 5 )
SELECT [SupplierName],
       [Country],
       [ContactName],
       [Phone]
  FROM [Suppliers] supp
  JOIN top ON top.[SupplierID] = supp.[SupplierID]

7. Какую категорию товаров заказывали больше всего по стоимости в Бразилии, выведите страну, название категории и сумму.

WITH [br_orders] AS (SELECT ord.[orderID]
                       FROM [Orders] ord, [Customers] cust
                      WHERE ord.[CustomerID] = cust.[CustomerID]
                      AND cust.[Country] = 'Brazil' )
SELECT 'Brazil' AS [country],
       cat.[CategoryName],
       SUM(Quantity*Price) AS Total
  FROM [OrderDetails] ord
  JOIN [br_orders] ON br_orders.[OrderID] = ord.[OrderID]
  JOIN [Products] prod ON ord.[ProductID] = prod.[ProductID]
  JOIN [Categories] cat ON cat.[CategoryID] = prod.[CategoryID]
 GROUP BY cat.[CategoryName]
 ORDER BY [Total] desc
 LIMIT 1

8. Какая разница в стоимости между самым дорогим и самым дешевым заказом из США.

WITH [usa_orders] AS (SELECT ord.[OrderID]
                        FROM [Orders] ord, [Customers] cust
                       WHERE cust.[CustomerID] = ord.[CustomerID]
                       AND cust.[Country] = 'USA' ),
     [sum_ord] AS (SELECT ord.[OrderID],
                          SUM(Quantity*Price) AS Total
                     FROM [OrderDetails] ord
                     JOIN [usa_orders] ON usa_orders.[OrderID] = ord.[OrderID]
                     JOIN [Products] prod ON ord.[ProductID] = prod.[ProductID]
                    GROUP BY ord.[OrderID] )
SELECT MAX(sum_ord.[Total]) - MIN(sum_ord.[Total]) AS USA_orders_diff
  FROM [sum_ord]

9. Выведите количество заказов у каждого их трех самых молодых сотрудников, а также имя и фамилию во второй колонке.

SELECT COUNT(O.[OrderID]) AS Orders,
       E.[FirstName] || ' ' ||  E.[LastName] AS Name
  FROM [Orders] O
  JOIN [Employees] E ON O.[EmployeeID] = E.[EmployeeID] AND E.[BirthDate] >= (
  SELECT [BirthDate]
  FROM [Employees]
  ORDER BY [BirthDate] DESC
  LIMIT 1 OFFSET 2
)
GROUP BY E.[FirstName] || ' ' ||  E.[LastName]

10. Сколько банок крабового мяса всего было заказано.

SELECT SUM([quantity] * 24) AS tins_num
  FROM [OrderDetails] OD
  JOIN [Products] P ON OD.[ProductID] = P.[ProductID]
  AND P.[ProductName] LIKE '%rab%eat%'
