/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

-- 9. Performance Analysis
-- Comparing the current value to a target value.
-- Helps measure success and compare performance.
-- Current[Measure] - Target[Measure]
-- Current Sales - Average Sales
-- Current Year Sales - Previous Year Sales
-- Current Sales - Lowest Sales
--------------------------SQL Tasks---------------------------------------------------------
-- Analyze the yearly performance of products by comparing each product's sales to both its average sales performance and the previous year's sales.
WITH     yearly_product_sales
AS       (SELECT   YEAR(f.order_date) AS order_year,
                   p.product_name,
                   SUM(f.sales_amount) AS current_sales
          FROM     gold.fact_sales AS f
                   LEFT OUTER JOIN
                   gold.dim_products AS p
                   ON f.product_key = p.product_key
          WHERE    f.order_date IS NOT NULL
          GROUP BY YEAR(f.order_date), p.product_name)
SELECT   order_year,
         product_name,
         current_sales,
         AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
         current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
         CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg' WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg' ELSE 'Avg' END AS avg_chage,
         -- Year-over-year analysis
         LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
         current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
         CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase' WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease' ELSE 'No Change' END AS py_change
FROM     yearly_product_sales
ORDER BY product_name, order_year;
