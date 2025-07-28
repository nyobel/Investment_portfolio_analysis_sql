/*
================================================================================================
Stored Procedure: Load Bronze Layer (Bronze -> Silver)
================================================================================================
Script Purpose:
    This stored procedure performs the ETL(Extract, Transform, Load) process to populate the 
    'silver' schema tables from the 'bronze' schema. 
    Actions performed:
    - Deletes data from silver tables.
    - Inserts transformed and cleaned data from Bronze into Silver tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		-- DELETE from all tables first, in FK-respecting order
		PRINT '======================================================';
		PRINT 'Deleting Data From Silver Tables Before Insertion';
		PRINT '======================================================';

		PRINT 'Clearing Transactions Table';
		DELETE FROM silver.transactions;

		PRINT 'Clearing Portfolio Performance Table';
		DELETE FROM silver.portfolio_performance;

		PRINT 'Clearing Investments Table';
		DELETE FROM silver.investments;

		PRINT 'Clearing Portfolios Table';
		DELETE FROM silver.portfolios;

		PRINT 'Clearing Clients Table';
		DELETE FROM silver.clients;

		PRINT '---------------------------------------------';
		PRINT 'Successfully Cleared Data From All Tables';
		PRINT '---------------------------------------------';


		PRINT '======================================================';
		PRINT 'Loading Silver Layer';
		PRINT '======================================================';
		-- --------------------------------------------
		-- INSERTING INTO: Silver Clients Table
		-- --------------------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Clients Table';
		PRINT '-------------------------------';

		PRINT '>> Inserting Data Into Table: silver.clients';
		INSERT INTO silver.clients (
			client_id,
			name,
			email,
			age,
			age_group,
			occupation,
			risk_profile,
			onboard_date,
			region
		)

		SELECT 
			client_id,
			TRIM(name) AS name,
			TRIM(email)AS email,
			CASE WHEN age < 18 THEN NULL
				 ELSE age 
			END AS age,					-- Replace invalid age with NULL
			CASE 
				WHEN age BETWEEN 18 AND 25 THEN '18-25'
				WHEN age BETWEEN 26 AND 35 THEN '26-35'
				WHEN age BETWEEN 36 AND 45 THEN '36-45'
				WHEN age BETWEEN 46 AND 55 THEN '46-55'
				WHEN age >= 56 THEN '55+'
				ELSE 'Unknown'
			END AS age_group,				-- Derive a column age group
			TRIM(occupation) AS occupation,
			TRIM(risk_profile) AS risk_profile,
			onboard_date,
			CASE 
				WHEN TRIM(region) = '' THEN 'Unknown'
				ELSE TRIM(region)
			END AS region					-- Replace blank spaces with Unknown
		FROM bronze.clients;

		-- --------------------------------------------
		-- INSERTING INTO: Silver Portfolios Table
		-- --------------------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Portfolios Table';
		PRINT '-------------------------------';

		PRINT '>> Inserting Data Into Table: silver.portfolios';
		INSERT INTO silver.portfolios (
			portfolio_id,
			portfolio_name,
			type,
			risk_level,
			manager
			)
		SELECT 
			portfolio_id,
			TRIM(portfolio_name),							         -- Trim whitespaces 
			TRIM(type),
			TRIM(risk_level),
			TRIM(manager)
		FROM bronze.portfolios;

		-- --------------------------------------------
		-- INSERTING INTO: Silver Investments Table
		-- --------------------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Investments Table';
		PRINT '-------------------------------';

		PRINT '>> Inserting Data Into Table: silver.investments';
		INSERT INTO silver.investments (
			investment_id, 
			client_id, 
			portfolio_id, 
			amount_invested, 
			investment_date
		)

		SELECT 
			investment_id, 
			client_id, 
			portfolio_id,
			CASE WHEN amount_invested < 0 THEN NULL
				 ELSE amount_invested
			END AS amount_invested,
			investment_date
		FROM bronze.investments;

		-- --------------------------------------------
		-- INSERTING INTO: Silver Portfolio Performance Table
		-- --------------------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Portfolio Performance Table';
		PRINT '-------------------------------';

		PRINT '>> Inserting Data Into Table: silver.portfolio_performance';
		INSERT INTO silver.portfolio_performance (
			portfolio_id,
			month,
			year,
			monthly_return,
			benchmark_return
			)
		SELECT 
			portfolio_id,
			month,
			year,
			monthly_return,
			benchmark_return
		FROM bronze.portfolio_performance;

		-- --------------------------------------------
		-- INSERTING INTO: Silver Transactions Table
		-- --------------------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Transactions Table';
		PRINT '-------------------------------';

		PRINT '>> Inserting Data Into Table: silver.transactions';
		INSERT INTO silver.transactions (
			transaction_id,
			client_id,
			portfolio_id,
			transaction_type,
			transaction_date,
			amount
			)
		SELECT 
			transaction_id,
			client_id,
			portfolio_id,
			CASE WHEN TRIM(transaction_type) = 'Withdrew' THEN 'Withdrawal' 
				 ELSE TRIM(transaction_type)
			END AS transaction_type,						        	-- Standardize transaction_type for consistency
			transaction_date,
			CASE WHEN amount < 0 THEN NULL
				 ELSE amount
			END AS amount
		FROM bronze.transactions;

	END TRY
	BEGIN CATCH
		PRINT '==================================================';
		PRINT 'ERROR OCCURRED WHEN LOADING SILVER LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================';
	END CATCH
END;
