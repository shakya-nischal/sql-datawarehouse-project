/*
=============================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=============================================================================================
Script Purpose:
        This stored procedure performs the ETL (Extract, Transform, Load) process to populate
        the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
              - Truncates Silver tables.
              - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters: None
This stored procedure does not accept any parameters or return any values.

Usage Example: EXEC silver.load_silver;
=============================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time AS DATETIME, @end_time AS DATETIME,
    @batch_start_time AS DATETIME, @batch_end_time AS DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=========================================';
        PRINT 'Loading data into silver tables...';
        PRINT '=========================================';
        PRINT '=========================================';
        PRINT 'Loading CRM Tables';
        PRINT '=========================================';
        SET @start_time = GETDATE();
    PRINT ' >> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT ' >> Inserting Data Into: silver.crm_cust_info';

    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gender,
        cst_create_date
    )
    SELECT cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' ELSE 'n/a' END AS cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male' WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female' ELSE 'n/a' END AS cst_gender,
        cst_create_date
    FROM   (SELECT *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM   bronze.crm_cust_info
            WHERE  cst_id IS NOT NULL) AS t
    WHERE  flag_last = 1;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
    PRINT '>> -------------------------------------------';

    SET @start_time = GETDATE();

    PRINT ' >> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT ' >> Inserting Data Into: silver.crm_prd_info';

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT prd_id,
        -- Derived Columns: Create new columns based on calculations or transformations of existing columns
        -------------------------------------------------------
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID from prd_key
        SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key, -- Extract product key from prd_key
        -------------------------------------------------------
        prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost, -- Handle NULL values for product cost
        -------------------------------------------------------
        -- Data Normalization
        -------------------------------------------------------
        CASE UPPER(TRIM(prd_line)) WHEN 'M' THEN 'Mountain' WHEN 'R' THEN 'Road' WHEN 'T' THEN 'Touring' WHEN 'S' THEN 'Other Sales' ELSE 'n/a' END AS prd_line, -- Map product line codes to descriptive values
        -------------------------------------------------------
        -- Data Typecasting
        CAST (prd_start_dt AS DATE) AS prd_start_dt,
        -- Data Enrichment(Add new, relevant data to enhance the dataset for analysis): Calculate prd_end_dt based on prd_start_dt using LEAD function
        CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
    FROM   bronze.crm_prd_info;

    SET @end_time = GETDATE();
    PRINT '>> Load Duration of silver crm prd info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';


    set @start_time = GETDATE();
    PRINT ' >> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    PRINT ' >> Inserting Data Into: silver.crm_sales_details';

    INSERT INTO silver.crm_sales_details (
        sls_order_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT sls_order_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0
                    OR LEN(sls_order_dt) != 8 THEN NULL ELSE CAST (CAST (sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0
                    OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST (CAST (sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0
                    OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST (CAST (sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL
                    OR sls_sales <= 0
                    OR sls_sales != sls_quantity * sls_price THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
        sls_quantity,
        CASE WHEN sls_price IS NULL
                    OR sls_price <= 0 THEN sls_sales / NULLIF (sls_quantity, 0) ELSE sls_price END AS sls_price -- Drive price if original value is invalid
    FROM   bronze.crm_sales_details;
    SET @end_time = GETDATE();
    PRINT '>> Loading duration for silver crm sales details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

    SET @start_time = GETDATE();

    PRINT ' >> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    PRINT ' >> Inserting Data Into: silver.erp_cust_az12';

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT -- Data Transformation
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END AS cid, -- Remove 'NAS' prefix if present
        CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END AS bdate, -- Set future birthdates to NULL
        -- Data Normalization
        CASE WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END AS gen -- Normalize gender values and handle unknown cases
    FROM   bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration for silver erp cust az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

    SET @start_time = GETDATE();

    PRINT ' >> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT ' >> Inserting Data Into: silver.erp_loc_a101';

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT REPLACE(cid, '-', '') AS cid,
        CASE WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('USA', 'US', 'UNITED STATES') THEN 'United States' WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('GERMANY', 'DE') THEN 'Germany' WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('FRANCE') THEN 'France' WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('CANADA') THEN 'Canada' WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('UNITED KINGDOM') THEN 'United Kingdom' WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))) IN ('AUSTRALIA') THEN 'Australia' ELSE 'n/a' END AS cntry
    FROM   bronze.erp_loc_a101;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration for silver erp loc a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

    SET @start_time = GETDATE();

    PRINT ' >> Truncating Table: silver.erp_px_Cat_g1v2';
    TRUNCATE TABLE silver.erp_px_Cat_g1v2;
    PRINT ' >> Inserting Data Into: silver.erp_px_Cat_g1v2';

    INSERT INTO silver.erp_px_Cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT id,
        cat,
        subcat,
        maintenance
    FROM   bronze.erp_px_Cat_g1v2;

    SET @end_time = GETDATE();
    PRINT '>> Load Duration for silver erp px cat g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';

    END TRY
    BEGIN CATCH
        PRINT '=======================================';
        PRINT 'Error occured while loading data into silver tables.'
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT '==========================================';
    END CATCH
END
