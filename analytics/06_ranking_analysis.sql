/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/
-- 6. Ranking Analysis
-- Order the values of dimensions by measure.
-- Top N performers | Bottom N performers
-- Rank[Dimension]By∑[Measure] (Rank Countries by Total Sales, Top 5 products by Quantity)
-- Which 5 products generate the highest revenue?

SELECT   TOP 5 p.product_name,
               SUM(f.price) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_products AS p
         ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- What are the 5 worst-performing products in terms of sales?
SELECT   TOP 5 p.product_name,
               SUM(f.price) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_products AS p
         ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Using Window function 
-- ROW_NUMBER() assigns a unique sequential number — 1, 2, 3, ... — to rows according to the window you define, especially for ranking, finding duplicates, selecting the latest record, and data cleaning.
SELECT *
FROM   (SELECT   p.product_name,
                 SUM(f.sales_amount) AS total_revenue,
                 ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
        FROM     gold.fact_sales AS f
                 LEFT OUTER JOIN
                 gold.dim_products AS p
                 ON f.product_key = p.product_key
        GROUP BY p.product_name) AS t
WHERE  rank_products <= 5;

-- Find the top 10 customers who have generated the highest revenue
SELECT   TOP 10 c.customer_key,
                c.first_name,
                c.last_name,
                SUM(f.price) AS total_revenue
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_customers AS c
         ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the lowest orders placed
SELECT   TOP 3 c.customer_key,
               c.first_name,
               c.last_name,
               COUNT(DISTINCT order_number) AS total_orders
FROM     gold.fact_sales AS f
         LEFT OUTER JOIN
         gold.dim_customers AS c
         ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders;
