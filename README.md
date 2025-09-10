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
## 📂 Repository Structure
```
Trail Trekker Data Pipeline/
├─ .venv/                                   # local virtualenv (do not commit)
├─ data/                                    # optional raw/derived local files (ignore in git)
├─ logs/                                    # local logs (ignore in git)
├─ trail-trekker/                           # SQLMesh project root
│  ├─ .cache/                               # SQLMesh cache (ignore in git)
│  ├─ audits/                               # (optional) custom audit SQL / helpers
│  ├─ logs/                                 # SQLMesh run logs (ignore in git)
│  ├─ macros/                               # (optional) SQLMesh macros / Jinja helpers
│  ├─ models/                               # all models (flat layout, prefixed by layer)
│  │  ├─ .gitkeep
│  │  ├─ dim_plans.sql                      # warehouse dimension (SCD-1)
│  │  ├─ fct_subscription_changes.sql       # warehouse fact (plan switches & cancels)
│  │  ├─ full_model.sql                     # example/template model
│  │  ├─ incremental_model.sql              # example incremental template
│  │  ├─ raw_customers.sql                  # raw layer (or seed-backed view)
│  │  ├─ raw_features.sql
│  │  ├─ raw_plan_features.sql
│  │  ├─ raw_plans.sql
│  │  ├─ raw_subscriptions.sql
│  │  ├─ seed_model.sql                     # example seed template
│  │  ├─ staging_customers.sql              # staging models (type cleaning/standardization)
│  │  ├─ staging_features.sql
│  │  ├─ staging_plans.sql
│  │  ├─ staging_subscriptions.sql
│  ├─ seeds/                                # (optional) CSVs for seed models
│  ├─ tests/                                # (optional) SQLMesh tests
│  ├─ .gitignore                            # project-specific ignores
│  ├─ config.yaml                           # SQLMesh project config
│  ├─ init_ddl.sql                          # (optional) helper DDL for local db setup
│  ├─ run_trail_trekker_pipeline.sh         # hourly runner script (cron calls this)
│  └─ trail_trekker.db                      # local DuckDB file (ignore in git)
├─ .gitignore                               # repo-level ignores (venv, logs, *.db, etc.)
└─ trail_trekker.db                         # (if present at root) local DuckDB (ignore in git)

```
