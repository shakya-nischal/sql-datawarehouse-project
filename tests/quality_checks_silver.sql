/*
=====================================================================================================
Quality Checks
=====================================================================================================
Script Purpose:
        This script performs various quality checks for data consistency, accuracy, and standarization across
        the 'silver' schemas. It includes checks for:
        - Null or duplicate primary keys.
        - Unwanted spaces in string fields.
        - Data Standarization and consistency.
        - Invalid date ranges and orders.
        - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading silver layer.
    - Investigate and resolve any discrepancies found during the checks.
=====================================================================================================
*/
-- ============================================================================================
-- Checking 'silver.crm_cust_info'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results

SELECT cst_gender
FROM   silver.crm_cust_info
WHERE  cst_gender != TRIM(cst_gender);

-- Data Standardization & Consistency
SELECT DISTINCT cst_gender
FROM   bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM   bronze.crm_cust_info;

SELECT *
FROM   silver.crm_cust_info;

-- ============================================================================================
-- Checking 'silver.crm_prd_info'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results

SELECT prd_id,
       prd_key,
       REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
       prd_nm,
       prd_cost,
       prd_line,
       prd_start_dt,
       prd_end_dt
FROM   bronze.crm_prd_info
WHERE  REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id
                                                           FROM   bronze.erp_px_Cat_g1v2);

SELECT prd_id,
       prd_key,
       REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
       SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key,
       prd_nm,
       ISNULL(prd_cost, 0) AS prd_cost,
       CASE UPPER(TRIM(prd_line)) WHEN 'M' THEN 'Mountain' WHEN 'R' THEN 'Road' WHEN 'T' THEN 'Touring' WHEN 'S' THEN 'Other Sales' ELSE 'n/a' END AS prd_line,
       CAST (prd_start_dt AS DATE) AS prd_start_dt,
       CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM   bronze.crm_prd_info;

SELECT count(prd_id)
FROM   bronze.crm_prd_info;

-- ============================================================================================
-- Checking 'silver.crm_sales_details'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results

-- Check for invalid date orders
SELECT *
FROM   silver.crm_sales_details
WHERE  sls_order_dt > sls_ship_dt
       OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quatity, and Price
-- >> Sales = Quatity * price
-- >> Values must not be NULL, zero, or negative.
SELECT   DISTINCT sls_sales AS old_sls_sales,
                  sls_quantity,
                  sls_price AS old_sls_price,
                  CASE WHEN sls_sales IS NULL
                            OR sls_sales <= 0
                            OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales,
                  CASE WHEN sls_price IS NULL
                            OR sls_price <= 0 THEN sls_sales / NULLIF (sls_quantity, 0) ELSE sls_price END AS sls_price
FROM     silver.crm_sales_details
WHERE    sls_sales != sls_quantity * sls_price
         OR sls_sales IS NULL
         OR sls_quantity IS NULL
         OR sls_price IS NULL
         OR sls_sales <= 0
         OR sls_quantity <= 0
         OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT   DISTINCT sls_sales,
                  sls_quantity,
                  sls_price
FROM     silver.crm_sales_details
WHERE    sls_sales != sls_quantity * sls_price
         OR sls_sales IS NULL
         OR sls_quantity IS NULL
         OR sls_price IS NULL
         OR sls_sales <= 0
         OR sls_quantity <= 0
         OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ============================================================================================
-- Checking 'silver.erp_cust_az12'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results
-- Check brith date 
SELECT DISTINCT bdate
FROM   bronze.erp_cust_az12
WHERE  bdate < '1924-01-01'
       OR bdate > GETDATE();

-- Data Standarization and consistency
SELECT DISTINCT gen AS OriginalGen,
                CASE WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END AS CleanedGen
FROM   bronze.erp_cust_az12;

SELECT cid
FROM   bronze.erp_cust_az12
WHERE  TRIM(cid) NOT LIKE 'NAS%';

SELECT DISTINCT '[' + ISNULL(gen, 'NULL') + ']' AS OriginalGen,
                LEN(gen) AS Length,
                DATALENGTH(gen) AS DataLength
FROM   bronze.erp_cust_az12;

SELECT gen,
       TRIM(gen) AS TrimmedGen,
       UPPER(TRIM(gen)) AS UpperGen
FROM   bronze.erp_cust_az12;

SELECT COLUMN_NAME,
       DATA_TYPE,
       CHARACTER_MAXIMUM_LENGTH
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_SCHEMA = 'bronze'
       AND TABLE_NAME = 'erp_cust_az12';

SELECT DISTINCT gen,
                '[' + gen + ']' AS VisibleGen,
                UPPER(TRIM(gen)) AS CleanValue,
                CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END AS Result
FROM   bronze.erp_cust_az12;

SELECT DISTINCT gen,
                UPPER(TRIM(gen)) AS CleanValue,
                UNICODE(LEFT(TRIM(gen), 1)) AS FirstCharacterCode
FROM   bronze.erp_cust_az12
WHERE  TRIM(gen) <> '';

SELECT UPPER(TRIM(gen)) AS CleanValue,
       CASE WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female' WHEN UPPER(TRIM(gen)) = 'FEMALE' THEN 'Female' WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male' WHEN UPPER(TRIM(gen)) = 'MALE' THEN 'Male' ELSE 'n/a' END AS Result
FROM   bronze.erp_cust_az12
WHERE  TRIM(gen) <> '';

-- there are hidden characters that TRIM() is not removing. TRIM() removes normal spaces, but not every possible whitespace/control character, such as carriage returns or non-breaking spaces. So, using DATALENGTH to count other special characters.
SELECT DISTINCT gen,
                UPPER(TRIM(gen)) AS CleanValue,
                LEN(UPPER(TRIM(gen))) AS CleanLength,
                DATALENGTH(UPPER(TRIM(gen))) AS DataLength,
                '[' + UPPER(TRIM(gen)) + ']' AS VisibleValue
FROM   bronze.erp_cust_az12
WHERE  TRIM(gen) <> '';

SELECT CASE WHEN 'MALE' = 'MALE' THEN 'MATCH' ELSE 'NO MATCH' END AS Test1,
       CASE WHEN UPPER(TRIM('Male')) IN ('M', 'MALE') THEN 'MATCH' ELSE 'NO MATCH' END AS Test2,
       CASE WHEN UPPER(TRIM('Female')) IN ('F', 'FEMALE') THEN 'MATCH' ELSE 'NO MATCH' END AS Test3;

SELECT DISTINCT gen AS OriginalGen,
                CASE WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END AS CleanedGen
FROM   bronze.erp_cust_az12;

-- ============================================================================================
-- Checking 'silver.crm_loc_a101'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results

SELECT DISTINCT cid,
                REPLACE(cid, '-', '') AS new_cid
FROM   bronze.erp_loc_a101
WHERE  REPLACE(cid, '-', '') NOT IN (SELECT cst_key
                                     FROM   silver.crm_cust_info);

-- ============================================================================================
-- Checking 'silver.px_Cat_g1v2'
-- ============================================================================================
-- Check for NULLs or Duplicates
-- Expectation: No Results

SELECT DISTINCT id
FROM   bronze.erp_px_Cat_g1v2
WHERE  id NOT IN (SELECT cat_id
                  FROM   silver.crm_prd_info);

SELECT cat_id
FROM   silver.crm_prd_info;

SELECT *
FROM   bronze.erp_px_Cat_g1v2
WHERE  cat != TRIM(cat)
       OR subcat != TRIM(subcat)
       OR maintenance != TRIM(maintenance);
