# Trail-Trekker-Data-Analytics-Pipeline-using-SQLMesh-and-DuckDB

# Trail-Trekker Data Analytics Pipeline (SQLMesh + DuckDB)

Fresh, hourly metrics for Trail-Trekker using **DuckDB** for storage and **SQLMesh** for modeling, scheduling, and deployments.

- **Seeds (CSV-backed “raw”)** → loaded into DuckDB  
- **Staging models** → type/format cleanup & normalization  
- **Dimensional models** → `warehouse.dim_plans` (SCD-1)  
- **Fact models** → `warehouse.fct_subscription_changes` (plan switches & terminal cancels)  
- **Orchestration** → model-level cron in SQLMesh + a simple **local cron** runner script

---

## ⚙️ Tech Stack

- **DuckDB** (embedded analytics DB)
- **SQLMesh** (models, environments, scheduling, audits)
- Python 3.10+ (venv)
- Optional: Airflow / Dagster / GitHub Actions

---
