/*
============================================================
Create Database and Schemas
============================================================
Script Purpose:
	This script creates a new database named 'InvestmentPortfolios' after checking if the database 
	already exists.
	If the database exists, it is dropped and recreated. Additionally, the script creates three
	schemas within the database, namely: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'InvestmentsPortfolio' database if it exists.
	All data in the database will be permanently deleted. Proceed cautiously and ensure proper 
	before running this script.

*/

USE master;
GO

-- Drop and recreate the 'InvestmentPortfolios' database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'InvestmentPortfolios')
BEGIN
	ALTER DATABASE InvestmentPortfolios SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE InvestmentPortfolios;
END;
GO

--Create 'InvestmentPortfolios' database
CREATE DATABASE InvestmentPortfolios;
GO

USE InvestmentPortfolios;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
