/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
-- 4. Measures Exploration
-- Calculate the key metric of the business (Big Numbers)
-- Highest level of Aggregation | Lowest level of details
-- Find the Total sales
SELECT SUM(price) AS total_sales
FROM   gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity
FROM   gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price
FROM   gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders
FROM   gold.fact_sales;

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM   gold.fact_sales;

-- Find the Total number of products
SELECT COUNT(DISTINCT product_key) AS total_products
FROM   gold.dim_products;

-- Find the Total number of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM   gold.dim_customers;

-- Find the Total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM   gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name,
       SUM(sales_amount) AS measure_values
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name,
       SUM(quantity) AS measure_values
FROM   gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name,
       AVG(price) AS measure_values
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name,
       COUNT(DISTINCT order_number) AS measure_values
FROM   gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name,
       COUNT(DISTINCT product_key) AS measure_values
FROM   gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name,
       COUNT(customer_key) AS measure_values
FROM   gold.dim_customers;
