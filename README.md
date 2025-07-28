# Investment_portfolio_analysis_sql

This project is built to simulate data handling and analysis for an investment company. It uses **SQL** within **SQL Server Management Studio (SSMS)** to explore and manage datasets related to clients, portfolios, investments, and transactions.

The data is **AI-generated** and designed to reflect realistic financial structures and business logic. It enables practice in areas such as data cleaning, transformation, and performance analysis.

🏗️ The project follows the **Medallion Architecture** (Bronze, Silver, and Gold layers) to structure the data workflow:
- **Bronze** for raw ingested data  
- **Silver** for cleaned and joined datasets  
- **Gold** for final analysis-ready views

---

## 🔰 Bronze Layer (Status: ✅ Completed)

- Created five tables under the `bronze` schema: `clients`, `portfolios`, `investments`, `portfolio_performance`, and `transactions`.
- Data was loaded from CSV files.
- `clients` and `portfolios` were ingested via `BULK INSERT` using a stored procedure `bronze.load_bronze`.
- Due to decimal compatibility issues with SQL Server Express/Developer editions:
  - `investments`, `portfolio_performance`, and `transactions` were imported using **Flat File Import Wizard**.
- All DDL scripts and the load procedure are included and documented in the `/scripts/bronze` folder.


## ⚙️ Silver Layer (Status: ✅ Completed)

- Created cleaned versions of the Bronze tables under the `silver` schema.
- Built a stored procedure `silver.load_silver` that:
  - **Deletes existing records** in the correct referential order (child → parent) to avoid FK conflicts.
  - **Inserts cleaned data** with logic applied such as:
    - Trimming whitespace
    - Replacing invalid values (e.g., negative amounts or underage clients)
    - Standardizing `transaction_type` entries
    - Creating derived fields like `age_group`
- Maintains foreign key constraints between related tables to preserve integrity.
- Logging and error handling is built into the procedure using `TRY...CATCH` and `PRINT` statements.
- All scripts are available in the `/scripts/silver` folder.

---

## ✨ Gold Layer (Status: ✅ Completed)

- Constructed **star schema views** under the `gold` schema:
  - **Fact Views**: `fact_investments`, `fact_transactions`, `fact_portfolio_performance`
  - **Dimension Views**: `dim_clients`, `dim_portfolios`
- Enriched the data with:
  - Surrogate keys using `ROW_NUMBER()`
  - Business metrics such as `performance_diff`, `return_ratio`, and `benchmark_flag`
  - Derived fields like `onboard_year` and `onboard_month`
- All transformations are fully handled within SQL views, making the data analytics-ready and logically structured for BI tools.
- All scripts are available in the `/scripts/gold` folder.

---

## 📊 Next Steps

- Build **Power BI dashboards** using the Gold views.
- Visualize and analyze trends across:
  - Investment amounts by region, age group, or portfolio type
  - Client activity and transaction patterns
  - Portfolio performance versus benchmark over time
- Answer **key stakeholder questions** with dynamic KPIs, filters, and time-series visualizations.

---

This structure supports traceability and scalability while mimicking how modern data systems are organized in practice. The project will grow over time with additional logic, insights, and possibly dashboards.
