-- We have these tables in the database:
-- Customers: customer data
-- Employees: all employee information
-- Offices: sales office information
-- Orders: customers' sales orders
-- OrderDetails: sales order line for each sales order
-- Payments: customers' payment records
-- Products: a list of scale model cars
-- ProductLines: a list of product line categories

SELECT 'Customers' AS table_name,
       13 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM customers 
  
  UNION ALL

SELECT 'Employees' AS table_name,
       8 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM employees 
  
  UNION ALL
 
SELECT 'Offices' AS table_name,
       9 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM offices 
  
 UNION ALL
  
SELECT 'Orders' AS table_name,
       7 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM orders 
  
 UNION ALL 
 
SELECT 'OrderDetails' AS table_name,
       5 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM orderdetails 
  
 UNION ALL 
 
SELECT 'Payments' AS table_name,
       4 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM payments
  
 UNION ALL 
 
SELECT 'Products' AS table_name,
       9 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM products
  
 UNION ALL 
  
SELECT 'ProductLines' AS table_name,
       4 AS number_of_attribute,
	   COUNT(*) AS number_of_rows
  FROM productlines;
  
-- Question 1: Which Products Should We Order More of or Less of?  
  
WITH 

low_stock_table AS (
SELECT productCode, ROUND(SUM(quantityOrdered)*1.0/(SELECT quantityInStock
                                                      FROM products AS p
                                                     WHERE p.productCode =   
                                                           o.productCode),2)
                                                        AS low_stock
  FROM orderdetails AS o 
 GROUP BY productCode
 ORDER BY low_stock DESC
 LIMIT 10
),

product_to_restock AS (
SELECT productCode, SUM(quantityOrdered*priceEach) AS product_performance
  FROM orderdetails
 WHERE productCode IN (SELECT productCode FROM low_stock_table)
 GROUP BY productCode
 ORDER BY product_performance DESC
 LIMIT 10
)

SELECT productCode,productName,productLine
  FROM products
 WHERE productCode IN (SELECT productCode FROM product_to_restock);
 
--In the first part of this project, we explored products. 
--Now we'll explore customer information by answering the second question: 
--how should we match marketing and communication strategies to customer behaviors? 
--This involves categorizing customers: finding the VIP (very important person) 
--customers and those who are less engaged.
--VIP customers bring in the most profit for the store. 
--Less-engaged customers bring in less profit.

WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT c.contactLastName, c.contactFirstName, c.city,
        c.country, ppct.profit
   FROM customers AS c
   JOIN profit_per_customer_table AS ppct
     ON c.customerNumber = ppct.customerNumber
  ORDER BY ppct.profit DESC
  LIMIT 5;
  
--  Finding the Less Engaged Customers - Top 5  
  
  WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT c.contactLastName, c.contactFirstName, c.city,
        c.country, ppct.profit
   FROM customers AS c
   JOIN profit_per_customer_table AS ppct
     ON c.customerNumber = ppct.customerNumber
  ORDER BY ppct.profit 
  LIMIT 5;
  
  
-- Customer Lifetime Value (LTV) Average
  
  WITH profit_per_customer_table AS (
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)
 
 SELECT AVG(ppct.profit) AS "The Average of Customer Lifetime Value (LTV)"
   FROM profit_per_customer_table AS ppct;
   
   -- Looking for the results, it is possible to see that the 
   -- highest performance products are Classic and Vintage Cars
   -- making then the priority for restocking. Also, as we found the more loyal
   -- and the worts customers, the company could split then in 2 groups and do different
   -- marketing strategies for then.
   -- To finish, the LTV of a new costumer is $39000. In this way, the company may try to achieve
   -- at least a 20% operational margin for each new client, limiting is expendure to attract
   -- new customers.