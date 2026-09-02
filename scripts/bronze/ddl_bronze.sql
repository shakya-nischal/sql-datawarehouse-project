/* 
=======================================================================
DDL Script: Create Bronze Tables
=======================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables if they already exists.
    Run this script to re-define the DDL structure of 'bronze' tables
=======================================================================
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_cust_info;
    PRINT 'Existing table "bronze.crm_cust_info" dropped.';
END;

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gender NVARCHAR(50),
    cst_create_date DATE,
);
GO

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_prd_info;
    PRINT 'Existing table "bronze.crm_prd_info" dropped.';
END;

CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_sales_details;
    PRINT 'Existing table "bronze.crm_sales_details" dropped.';
END;

CREATE TABLE bronze.crm_sales_details(
    sls_order_num INT,
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
);
GO

ALTER TABLE bronze.crm_sales_details
ALTER COLUMN sls_order_num NVARCHAR(50);

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_cust_az12;
    PRINT 'Existing table "bronze.erp_cust_az12" dropped.';
END;

CREATE TABLE bronze.erp_cust_az12(
    cid INT,
    bdate DATE,
    gen NVARCHAR(50),
);
GO

ALTER TABLE bronze.erp_cust_az12
ALTER COLUMN cid NVARCHAR(50);

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_loc_a101;
    PRINT 'Existing table "bronze.erp_loc_a101" dropped.';
END;

CREATE TABLE bronze.erp_loc_a101(
    cid INT,
    cntry NVARCHAR(50),
);
GO

ALTER TABLE bronze.erp_loc_a101
ALTER COLUMN cid NVARCHAR(50);

IF OBJECT_ID('bronze.erp_px_Cat_g1v2', 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_px_Cat_g1v2;
    PRINT 'Existing table "bronze.erp_px_Cat_g1v2" dropped.';
END;

CREATE TABLE bronze.erp_px_Cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
);
GO
