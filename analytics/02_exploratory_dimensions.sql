/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT country
FROM   gold.dim_customers;

-- Explore All Categories "The major Divisions"
SELECT   DISTINCT category,
                  subcategory,
                  product_name
FROM     gold.dim_products
ORDER BY 1, 2, 3;
