/*
======================================================================================================================
DDL Scripts: Create Bronze Tables
======================================================================================================================
Scripts Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables if they 
    already exist.
    Run this script to re-define the DDL structure of 'bronze' tables.

DISCLAIMER:
    The tables [investments], [portfolio_performance], and [transactions] were imported as flat files
    due to persistent decimal value incompatibility with BULK INSERT in SQL Server Express and SQL Server Developer.
    The data was successfully loaded using the "Flat File Import Wizard" in SSMS instead.
======================================================================================================================
*/

IF OBJECT_ID('bronze.clients', 'U') IS NOT NULL
	DROP TABLE bronze.clients;
CREATE TABLE bronze.clients (
	client_id INT NOT NULL,        -- Primary Key: client_id
	name NVARCHAR(100) NOT NULL,
	email NVARCHAR(150) NOT NULL,
	age INT NOT NULL,
	occupation NVARCHAR(70) NOT NULL,
	risk_profile NVARCHAR(50) NOT NULL,
	onboard_date DATE NOT NULL,
	region NVARCHAR(50) NOT NULL
);

GO
  
IF OBJECT_ID('bronze.portfolios', 'U') IS NOT NULL
	DROP TABLE bronze.portfolios;
CREATE TABLE bronze.portfolios (
	portfolio_id INT NOT NULL,      -- Primary Key: portfolio_id
	portfolio_name NVARCHAR(100),
	type NVARCHAR(100),
	risk_level NVARCHAR(50),
	manager NVARCHAR(100)
);

GO
-- ======================================================================================
-- Imported as flat file due to bulk insert decimal incompatibility
-- ======================================================================================
IF OBJECT_ID('bronze.investments', 'U') IS NOT NULL
	DROP TABLE bronze.investments;
CREATE TABLE bronze.investments (
	investment_id INT NOT NULL,      -- Primary Key: investment_id
	client_id INT NOT NULL,
	portfolio_id INT NOT NULL,
	amount_invested DECIMAL(18,2) NOT NULL,
	investment_date DATE NOT NULL
);

GO
  
IF OBJECT_ID('bronze.portfolio_performance', 'U') IS NOT NULL
	DROP TABLE bronze.portfolio_performance;
CREATE TABLE bronze.portfolio_performance (
  -- Composite Primary Key: (portfolio_id, month, year)
  -- Uniquely identifies each portfolio's performance per month
	portfolio_id INT NOT NULL, 
	month INT NOT NULL,
	year INT NOT NULL,
	monthly_return DECIMAL(6,4) NOT NULL,
	benchmark_return DECIMAL(6,4) NOT NULL
);

GO
  
IF OBJECT_ID('bronze.transactions', 'U') IS NOT NULL
	DROP TABLE bronze.transactions;
CREATE TABLE bronze.transactions (
	transaction_id INT NOT NULL,      -- Primary Key: transaction_id
	client_id INT NOT NULL,
	portfolio_id INT NOT NULL,
	transaction_type NVARCHAR(50) NOT NULL,
	transaction_date DATE NOT NULL,
	amount DECIMAL(18,2) NOT NULL
);
