/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
-- 3. Date Exploration
-- Find the date of the first and last order
-- How many years of sales are available
SELECT MIN(order_date) AS first_order_date,
       MAX(order_date) AS last_order_date,
       DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_months
FROM   gold.fact_sales;

-- Find the youngest and the oldest customer
SELECT MIN(birthdate) AS oldest_birthdate,
       MAX(birthdate) AS youngest_birthdate
FROM   gold.dim_customers;
