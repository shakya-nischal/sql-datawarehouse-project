/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/
-- 7. Change-Over-Time Analysis
-- Analyze how a measure evolves over-time.
-- Helps track trends & identify seasonality in your data.
-- Analyze Sales Performance Over Time
-- Changes over years: A high-level overview insights that helps with strategic decision-making.

SELECT   YEAR(order_date) AS order_year,
         SUM(sales_amount) AS total_sales,
         COUNT(DISTINCT customer_key) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

SELECT   YEAR(order_date) AS order_year,
         MONTH(order_date) AS order_month,
         SUM(sales_amount) AS total_sales,
         COUNT(DISTINCT customer_key) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

SELECT   DATETRUNC(MONTH, order_date) AS order_date,
         SUM(sales_amount) AS total_sales,
         COUNT(DISTINCT customer_key) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);

SELECT   FORMAT(order_date, 'yyyy') AS order_date,
         SUM(sales_amount) AS total_sales,
         COUNT(DISTINCT customer_key) AS total_customers,
         SUM(quantity) AS total_quantity
FROM     gold.fact_sales
WHERE    order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy')
ORDER BY FORMAT(order_date, 'yyyy');
