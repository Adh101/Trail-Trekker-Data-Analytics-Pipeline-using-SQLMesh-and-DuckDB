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
## Repository Structure
Trail Trekker Data Pipeline/
├─ run_trail_trekker_pipeline.sh           # local cron runner (hourly)
└─ trail-trekker/                          # SQLMesh project root (has sqlmesh.yaml)
   ├─ models/
   │  ├─ raw/                              # CSV-backed seed models (optional)
   │  ├─ staging/
   │  │  ├─ plans.sql
   │  │  ├─ subscriptions.sql
   │  │  └─ features.sql
   │  └─ warehouse/
   │     ├─ dim_plans.sql                  # SCD-1 dimension
   │     └─ fct_subscription_changes.sql   # fact: plan switches & cancellations
   ├─ seeds/                               # (optional) CSVs for raw ingestion
   ├─ tests/                               # (optional) model tests
   └─ sqlmesh.yaml                         # SQLMesh config

