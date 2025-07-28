/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- ===================================================================
-- GOLD LAYER
-- ===================================================================

-- ------------------------------------------------------------------
-- Investments Fact View: gold.fact_investments
-- ------------------------------------------------------------------
IF OBJECT_ID ('gold.fact_investments', 'V') IS NOT NULL
	DROP VIEW gold.fact_investments;

GO

CREATE OR ALTER VIEW gold.fact_investments AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY i.investment_id) AS investment_key,
	i.investment_id,
	i.client_id,
	c.name AS client_name,
	c.age_group,
	c.occupation,
	c.region,
	i.portfolio_id,
	p.portfolio_name,
	P.risk_level,
	i.amount_invested,
	i.investment_date
FROM silver.investments i
LEFT JOIN silver.clients c
	ON i.client_id = c.client_id
LEFT JOIN silver.portfolios p
	ON	i.portfolio_id = p.portfolio_id;

GO
  
-- ------------------------------------------------------------------
-- Transactions Fact View: gold.fact_transactions
-- ------------------------------------------------------------------
IF OBJECT_ID ('gold.fact_transactions', 'V') IS NOT NULL
	DROP VIEW gold.fact_transactions;

GO

CREATE OR ALTER VIEW gold.fact_transactions AS
SELECT
	ROW_NUMBER() OVER (ORDER BY t.transaction_date, t.transaction_id) AS transaction_key,
	t.transaction_id,
	t.client_id,
	c.name AS client_name,
	c.age_group,
	c.region,
	c.risk_profile,
	t.portfolio_id,
	p.portfolio_name,
	p.risk_level,
	t.transaction_type,
	t.transaction_date,
	t.amount
FROM silver.transactions t
LEFT JOIN silver.clients c
	ON	t.client_id = c.client_id
LEFT JOIN silver.portfolios p
	ON	t.portfolio_id = p.portfolio_id
WHERE t.amount IS NOT NULL;

GO
-- ------------------------------------------------------------------
-- Portfolio Performance Fact View: gold.fact_portfolio_performance
-- ------------------------------------------------------------------
IF OBJECT_ID ('gold.fact_portfolio_performance', 'V') IS NOT NULL
	DROP VIEW gold.fact_portfolio_performance;

GO

CREATE OR ALTER VIEW gold.fact_portfolio_performance AS
WITH base_query AS (
	SELECT
		ROW_NUMBER() OVER (ORDER BY pp.portfolio_id, pp.year, pp.month) AS performance_key,
		pp.portfolio_id,
		p.portfolio_name,
		p.manager AS manager_name,
		p.risk_level,
		pp.month AS performance_month,
		pp.year AS performance_year,
		pp.monthly_return,
		pp.benchmark_return,
		pp.monthly_return - pp.benchmark_return AS performance_diff,
		CAST(ROUND(monthly_return / NULLIF(benchmark_return, 0), 4) AS DECIMAL(10, 4)) AS return_ratio	
	FROM silver.portfolio_performance pp
	LEFT JOIN silver.portfolios p
		ON pp.portfolio_id = p.portfolio_id
)
SELECT
	performance_key,
	portfolio_id,
	portfolio_name,
	manager_name,
	risk_level,
	performance_year,
	performance_month,
	monthly_return,
	benchmark_return,
	performance_diff,
	CASE 
		WHEN performance_diff > 0 THEN 'Outperformed'
		ELSE 'Underperformed'
	END AS benchmark_flag,
	return_ratio
FROM base_query;

GO
  
-- ------------------------------------------------------------------
-- Clients Dimension View: gold.dim_clients
-- ------------------------------------------------------------------
IF OBJECT_ID ('gold.dim_clients', 'V') IS NOT NULL
	DROP VIEW gold.dim_clients;

GO

CREATE OR ALTER VIEW gold.dim_clients AS
SELECT
	ROW_NUMBER() OVER (ORDER BY client_id) AS client_key,
	client_id,
	name,
	email,
	age_group,
	occupation,
	risk_profile,
	region,
	onboard_date,
	YEAR(onboard_date) AS onboard_year,
	DATENAME(MONTH, onboard_date) AS onboard_month
FROM silver.clients;

GO
  
-- ------------------------------------------------------------------
-- Portfolios Dimension View: gold.dim_portfolio
-- ------------------------------------------------------------------
IF OBJECT_ID ('gold.dim_portfolios', 'V') IS NOT NULL
	DROP VIEW gold.dim_portfolios;

GO

CREATE OR ALTER VIEW gold.dim_portfolios AS
SELECT
	ROW_NUMBER() OVER (ORDER BY portfolio_id) AS portfolio_key,
	portfolio_id,
	portfolio_name,
	type AS portfolio_type,
	risk_level,
	manager AS manager_name
FROM silver.portfolios;
