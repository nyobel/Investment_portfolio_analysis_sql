# Investment_portfolio_analysis_sql

This project is built to simulate data handling and analysis for an investment company. It uses **SQL** within **SQL Server Management Studio (SSMS)** to explore and manage datasets related to clients, portfolios, investments, and transactions.

The data is **AI-generated** and designed to reflect realistic financial structures and business logic. It enables practice in areas such as data cleaning, transformation, and performance analysis.

📐 The project follows the **Medallion Architecture** (Bronze, Silver, and Gold layers) to structure the data workflow:
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

---

## 🛣️ Next Steps

The Silver and Gold layers will follow:

- **Silver Layer**: Apply transformations, enforce constraints, join logic, and derive analytical columns.
- **Gold Layer**: Design business-focused views, KPIs, and potential dashboard integrations.

---

This structure supports traceability and scalability while mimicking how modern data systems are organized in practice. The project will grow over time with additional logic, insights, and possibly dashboards.
