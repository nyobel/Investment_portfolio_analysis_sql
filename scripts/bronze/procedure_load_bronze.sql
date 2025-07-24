/*
================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

DISCLAIMER:
    The tables [investments], [portfolio_performance], and [transactions] were imported as flat files
    due to persistent decimal value incompatibility with BULK INSERT in SQL Server Express and SQL Server Developer.
    The data was successfully loaded using the "Flat File Import Wizard" in SSMS instead.

Usage Example:
    EXEC bronze.load_bronze;
================================================================================================

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		PRINT '==================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==================================================';
		------------------------------clients------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Clients Table';
		PRINT '-------------------------------';

		PRINT '>> Truncating Table: bronze.clients';
		TRUNCATE TABLE bronze.clients;

		PRINT '>> Inserting Data Into Table: bronze.clients';
		BULK INSERT bronze.clients
				FROM 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\clients.csv'
				WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',
					TABLOCK
				);

		------------------------------portfolios------------------------------
		PRINT '-------------------------------';
		PRINT 'Loading Portfolios Table';
		PRINT '-------------------------------';

		PRINT '>> Truncating Table: bronze.portfolios';
		TRUNCATE TABLE bronze.portfolios;

		PRINT '>> Inserting Data Into Table: bronze.portfolios';
		BULK INSERT bronze.portfolios
				FROM 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\portfolios.csv'
				WITH (
					FIRSTROW = 2,
					FIELDTERMINATOR = ',',
					TABLOCK
				);

		PRINT '==================================================';
		PRINT 'Bronze Layer Load Completed Successfully';
		PRINT '==================================================';

	END TRY
	BEGIN CATCH
		PRINT '==================================================';
		PRINT 'ERROR OCCURRED WHEN LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================';
	END CATCH

END;
-- ==================================================================================================
-- Attempted BULK INSERT (Failed due to decimal compatibility issues on SQL Server Express/Developer)
-- Tables affected: investments, portfolio_performance, transactions
-- Used Flat File Import Wizard instead — see README
-- ==================================================================================================

/*
BULK INSERT bronze.investments
FROM 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\investments.csv'
WITH (
    FORMATFILE = 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\investments.fmt',
	FIRSTROW = 2,
    TABLOCK
);

GO

BULK INSERT bronze.portfolio_performance
		FROM 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\portfolio_performance.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

GO

BULK INSERT bronze.transactions
		FROM 'C:\Users\Crystal\Documents\Projects\Investment Portfolios Analysis(GPT) - SQL\datasets\transactions.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
*/
