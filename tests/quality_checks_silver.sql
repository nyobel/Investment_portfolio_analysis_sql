/*
================================================================================================
Quality Checks Silver Schema
================================================================================================
Scripts Purpose:
  This script performs various quality checks for data consistency, accuracy, and standardization
  across the 'silver' schema. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid dates.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks for data loading Silver Layer
  - Investigate and resolve any discrepancies found during the checks
*/

-- ----------------------------------------------------------
-- Quality Checks: Silver Clients Table
-- ----------------------------------------------------------
-- Check for duplicate or nulls on the primary key
SELECT
	client_id,
	COUNT(*)
FROM silver.clients
GROUP BY client_id
HAVING COUNT(*) > 1 OR client_id IS NULL

-- Check for blanks or nulls
SELECT * FROM silver.clients
WHERE TRIM(email) = '' OR email IS NULL
OR TRIM(name) = '' OR name IS NULL
OR TRIM(occupation) = '' OR occupation IS NULL
OR TRIM(region) = '' OR region IS NULL

-- Check for whitespaces
SELECT * FROM silver.clients
WHERE TRIM(email) != email
OR TRIM(name) != name
OR TRIM(occupation) != occupation
OR TRIM(region) != region
  
-- Check for future dates
SELECT * FROM silver.clients
WHERE onboard_date > GETDATE()
  
-- Check for uniqueness
SELECT DISTINCT risk_profile 
FROM silver.clients

SELECT DISTINCT region
FROM silver.clients
  
-- ----------------------------------------------------------
-- Quality Checks: Silver Investments Table
-- ----------------------------------------------------------
-- Check for unique primary key and nulls or empty spaces
SELECT 
	investment_id,
	COUNT(*)
FROM silver.investments
GROUP BY investment_id
HAVING COUNT(*) > 1 OR investment_id IS NULL OR investment_id = '' -- none


-- Check for null or blank client_id and portfolio_id
SELECT * FROM silver.investments
WHERE client_id IS NULL OR client_id = ''
OR portfolio_id IS NULL OR portfolio_id = '' OR portfolio_id NOT BETWEEN 1 AND 6 -- none

-- Check for negative amount_invested or nulls or blanks
SELECT * FROM silver.investments
WHERE amount_invested < 0 OR amount_invested IS NULL --none

-- Check for invalid dates
SELECT * FROM silver.investments
WHERE investment_date > GETDATE() -- none

SELECT DISTINCT b.portfolio_id
FROM silver.investments b
LEFT JOIN silver.portfolios s
  ON b.portfolio_id = s.portfolio_id
WHERE s.portfolio_id IS NULL;

SELECT * FROM silver.investments

-- ----------------------------------------------------------
-- Quality Checks: Silver Portfolios Table
-- ----------------------------------------------------------
-- Check for whitespaces

SELECT * FROM silver.portfolios
WHERE TRIM(portfolio_name) != portfolio_name OR
	  TRIM(type) != type OR
	  TRIM(risk_level) != risk_level OR
	  TRIM(manager) != manager -- none

SELECT * FROM silver.portfolios

-- ----------------------------------------------------------
-- Quality Checks: Silver Portfolio Performance  Table
-- ----------------------------------------------------------
-- Check for unique composite key(portfolio_id, month, year)
SELECT 
portfolio_id, month, year,
COUNT(*)
FROM silver.portfolio_performance
GROUP BY portfolio_id, month, year
HAVING COUNT(*) > 1 -- none

-- Check for null or missing keys
SELECT * FROM silver.portfolio_performance
WHERE portfolio_id IS NULL OR month IS NULL OR year IS NULL -- none

SELECT * FROM silver.portfolio_performance
WHERE monthly_return IS NULL OR benchmark_return IS NULL-- none

-- Check for invalid returns
SELECT * FROM silver.portfolio_performance
WHERE monthly_return < -1 OR monthly_return > 1
	OR benchmark_return < -1 OR benchmark_return > 1 -- none

-- Check for invalid months and future years
SELECT * FROM silver.portfolio_performance
WHERE month NOT BETWEEN 1 AND 12			-- none

SELECT * FROM silver.portfolio_performance
WHERE year < 2024 OR year > YEAR(GETDATE()) -- none

-- Check that all portfolio_id's in portfolio_performance exist in portfolios
SELECT DISTINCT pp.portfolio_id
FROM silver.portfolio_performance pp
LEFT JOIN silver.portfolios s ON pp.portfolio_id = s.portfolio_id
WHERE s.portfolio_id IS NULL;

SELECT * FROM silver.portfolio_performance

-- ----------------------------------------------------------
-- Quality Checks: Silver Transactions  Table
-- ----------------------------------------------------------
-- Check for duplicates or nulls on pk
SELECT 
	transaction_id,
	COUNT(*)
FROM silver.transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1 OR transaction_id IS NULL		-- NONE

-- Check for client_id not found in silver.clients
SELECT 
	t.client_id
FROM silver.transactions t
LEFT JOIN silver.clients c
ON t.client_id = c.client_id
WHERE c.client_id IS NULL							-- NONE

-- Check for client_id not found in silver.clients
SELECT 
	t.portfolio_id
FROM silver.transactions t
LEFT JOIN silver.portfolios p
ON t.portfolio_id = p.portfolio_id
WHERE p.portfolio_id IS NULL						-- NONE

-- Check for nulls or blanks 
SELECT * FROM silver.transactions
WHERE transaction_type IS NULL OR  transaction_type = '' -- NONE

-- Check for unique values
SELECT DISTINCT transaction_type
FROM silver.transactions

-- Check for future dates, nulls or blanks
SELECT * FROM silver.transactions
WHERE transaction_date > GETDATE() 
	OR transaction_date IS NULL						-- NONE

-- Check for nulls or invalid transaction amounts
SELECT * FROM silver.transactions					-- NONE
WHERE amount < 0 OR amount IS NULL

-- Check for whitespaces
SELECT * FROM silver.transactions
WHERE transaction_type != TRIM(transaction_type)
	OR LEN(CAST(amount AS VARCHAR)) != LEN(TRIM(CAST(amount AS VARCHAR))) -- NONE

SELECT * FROM silver.transactions
