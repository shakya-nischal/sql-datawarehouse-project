/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/
-- 8. Cumulative Analysis
-- Aggregate the data progressively over time.
-- Helps to understand whether our business is growing or declining.
-- ∑[Cumulative Measure]BY[Date Dimension]
-- Running Total Sales By Year
-- Moving Average of Sales By Month
-- Calculate the total sales per month and the running total of sales over time.
-- Default Window Frame: Between Unbounded Preceding and Current Row
-- A normal SUM() collapses rows. A window SUM() calculates across rows while keeping every original row visible.
SELECT order_date,
       total_sales,
       avg_price,
       SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
       AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM   (SELECT   DATETRUNC(year, order_date) AS order_date,
                 SUM(sales_amount) AS total_sales,
                 AVG(price) AS avg_price
        FROM     gold.fact_sales
        WHERE    order_date IS NOT NULL
        GROUP BY DATETRUNC(year, order_date)) AS t;
