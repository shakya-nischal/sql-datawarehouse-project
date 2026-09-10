/*
======================================================================================
Quality Checks
======================================================================================
Script Purpose:
          This script performs quality checks to validate the integrity, consistency,
          and accuracy of the Gold layer. These checks ensure:
          - Uniqueness of surrogate keys in dimension tables.
          - Referential integrity between fact and dimension tables.
          - Validation or relationships in the data model for analytical purposes.
Usage Notes:
    - Run these checks after data loading Silver layer.
    - Investigate and resolve any discrepancies found during the checks.
======================================================================================
*/

-- ===================================================================================
-- Checking 'gold.dim_customers'
-- ===================================================================================
-- Check for Uniqueness of Customer key in gold.dim_customers
-- Expectation: No results
SELECT
  customer_key,
  COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ===================================================================================
-- Checking 'gold.dim_products'
-- ===================================================================================
-- Check for Uniqueness of Product key in gold.dim_products
-- Expectation: No results
SELECT
  product_key,
  COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ===================================================================================
-- Checking 'gold.fact_sales'
-- ===================================================================================
-- Check the data model connectivity between fact and dimensions
-- Expectation: No results

SELECT *
FROM   gold.fact_sales AS f
       LEFT OUTER JOIN
       gold.dim_customers AS c
       ON c.customer_key = f.customer_key
       LEFT OUTER JOIN
       gold.dim_products AS p
       ON p.product_key = f.product_key
WHERE  p.product_key IS NULL;
