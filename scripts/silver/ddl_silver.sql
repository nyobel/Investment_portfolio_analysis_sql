/*
======================================================================================================================
DDL Scripts: Create Silver Tables
======================================================================================================================
Scripts Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables if they 
    already exist.
    Run this script to re-define the DDL structure of 'silver' tables.

======================================================================================================================
*/

IF OBJECT_ID('silver.clients', 'U') IS NOT NULL
	DROP TABLE silver.clients;

CREATE TABLE silver.clients (
	client_id INT PRIMARY KEY,
	name NVARCHAR(100),
	email NVARCHAR(150),
	age INT,
	occupation NVARCHAR(70),
	risk_profile NVARCHAR(50),
	onboard_date DATE,
	region NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO
  
IF OBJECT_ID('silver.portfolios', 'U') IS NOT NULL
	DROP TABLE silver.portfolios;

CREATE TABLE silver.portfolios (
	portfolio_id INT PRIMARY KEY,
	portfolio_name NVARCHAR(100),
	type NVARCHAR(100),
	risk_level NVARCHAR(50),
	manager NVARCHAR(100),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

GO


IF OBJECT_ID('silver.investments', 'U') IS NOT NULL
	DROP TABLE silver.investments;

CREATE TABLE silver.investments (
	investment_id INT PRIMARY KEY,
	client_id INT,
	portfolio_id INT,
	amount_invested DECIMAL(18,2),
	investment_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE(),
	FOREIGN KEY (client_id) REFERENCES silver.clients(client_id),
	FOREIGN KEY (portfolio_id) REFERENCES silver.portfolios(portfolio_id)
);

GO
  
IF OBJECT_ID('silver.portfolio_performance', 'U') IS NOT NULL
	DROP TABLE silver.portfolio_performance;

CREATE TABLE silver.portfolio_performance (
	portfolio_id INT, 
	month INT,
	year INT,
	monthly_return DECIMAL(6,4),
	benchmark_return DECIMAL(6,4),
	dwh_create_date DATETIME2 DEFAULT GETDATE(),
	CONSTRAINT pk_portfolio_performance PRIMARY KEY (portfolio_id, month, year)
);

GO
  
IF OBJECT_ID('silver.transactions', 'U') IS NOT NULL
	DROP TABLE silver.transactions;

CREATE TABLE silver.transactions (
	transaction_id INT PRIMARY KEY,  
	client_id INT,
	portfolio_id INT,
	transaction_type NVARCHAR(50),
	transaction_date DATE,
	amount DECIMAL(18,2),
	dwh_create_date DATETIME2 DEFAULT GETDATE(),
	FOREIGN KEY (client_id) REFERENCES silver.clients(client_id),
	FOREIGN KEY (portfolio_id) REFERENCES silver.portfolios(portfolio_id)
);
