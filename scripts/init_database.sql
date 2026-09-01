/*
==================================================
Create Database and Schemas
==================================================
Script Purpose: This script creates a new database called "DataWarehouse" after checking if it already exists. If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within it: "bronze", "silver", and "gold". It also retrieves the SQL Server version and lists all existing databases.

Warning: Dropping the database will result in the loss of all data contained within it. Ensure that you have backups or that you are working in a safe environment before executing this script.
*/

SELECT @@VERSION AS SQLServerVersion;

SELECT name AS DatabaseName
FROM sys.databases;

USE master;
GO
-- Drop and recreate the DataWarehouse database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    DROP DATABASE DataWarehouse;
    PRINT 'Existing database "DataWarehouse" dropped.';
END;

-- Create the 'Datawarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
