# Trail-Trekker-Data-Analytics-Pipeline-using-SQLMesh-and-DuckDB

# Trail-Trekker Data Analytics Pipeline (SQLMesh + DuckDB)

Fresh, hourly metrics for Trail-Trekker using **DuckDB** for storage and **SQLMesh** for modeling, scheduling, and deployments.

## Objective:
To build the data warehouse for the data collected by Trail Trekker using **DuckDB** and data models using **SQLMesh**. Further, extend the data modeling to understand the subscription changes on a daily basis for their customers.

## Key Steps:
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
## Approach

This section explains *how* the pipeline was built and *why* specific choices were made—so a teammate with zero context can pick it up and extend it confidently.

---

### Milestone 1 — Data Ingestion
I started by choosing a storage/compute engine and a simple way to load seed data so I could iterate on modeling quickly before worrying about production infra.

**Why DuckDB?**
- **Fast local analytics**: Columnar, vectorized, great for dev/POC loops.
- **Zero infra**: A single file (`trail_trekker.db`) keeps the project portable.
- **SQL-native CSV ingestion**: Easy seeds via `read_csv_auto()` or SQLMesh seed models.

**Tradeoffs**
- **Single-writer, local file**: Great locally; not ideal for multi-user/cloud. For production, switch to a server DB (Postgres/Snowflake/BigQuery) or put DuckDB on shared storage with clear write patterns.
- **Orchestration in the cloud**: Local files don’t exist on workers; would need packaging or a different warehouse in Airflow/Composer/MWAA.

---

### Milestone 2 — Data Modeling

**Architecture (ELT within SQLMesh)**

- **Raw / Seeds** → **Staging** → **Warehouse (Dim / Fact)**  
- Organize transformations as **models** so lineage, audits, and scheduling are managed by SQLMesh.

**Method**

- **Kimball-style** dimensional modeling:
  - **`dim_plans` (SCD-1)**: One row per plan, stable reference data for joins & BI.
  - **`fct_subscription_changes`**: Transaction-style fact capturing switches and terminal cancellations.

**Why organize models this way?**

- **Staging layer** normalizes types/casing and removes noise (e.g., string dates, numeric text, placeholder rows).
- **Warehouse layer** is thin and business-ready:
  - **Dim** is clean, slowly changing **type 1** (historical plan attrs aren’t a current need).
  - **Fact** encodes the **business rules** for subscription changes (see below).

**Why these two models?**

- **`fct_subscription_changes`** directly answers questions like:
  - Which plans do users switch from/to?
  - What’s the timing of changes and cancellations?
  - Are customers moving monthly→annual (or vice versa)?
- **`dim_plans`** lets us enrich facts with plan metadata (price, limits) and keeps metrics definitions stable.

**Key modeling decisions**

- **Exclude “new subscription” as a change event.**  
  We only emit facts for **PLAN_CHANGE** and terminal **CANCELLATION**.
- **Change timestamp** = start of the *new* segment for plan switches, or `subscription_end_date` for cancellations.
- **One change per customer per day** is assumed and enforced via ordering; the dataset abides by this constraint.
- **Features not joined** into the dimension (yet) due to plan ID style mismatch (`PLN001M/PLN001A` vs `PLN001`). That mapping can be added later with a normalization rule.

---

### Milestone 3 — Why SQLMesh

- **Model-level scheduling**: Each model declares its own `cron`; `sqlmesh run` executes only models that are *due* and *impacted*. No DAG rewiring when you add/modify models.
- **Environments & plans**: `sqlmesh plan dev` / `plan prod --auto-apply` gives safe promotion and schema change tracking.
- **Audits/tests**: Not-null checks are embedded in model headers; more can be added over time.
- **Simple CLI**: Easy to run locally and to wrap in cron/Airflow/Dagster later.

---

### Milestone 4 — Orchestration

**Schedules chosen**

- **`fct_subscription_changes` — hourly (`@hourly`)**  
  Subscriptions can change throughout the day; near-real-time facts keep dashboards fresh.
- **`dim_plans` — daily (2am)**  
  Plan catalog is relatively static; daily refresh avoids unnecessary recompute.

**Why run `sqlmesh run` hourly?**

- SQLMesh executes **only models due by their own cron**—so calling hourly is safe and simple. If a model is daily, it will run once per day even if you invoke `run` every hour.

**Why a local cron job (for now)?**

- **Zero-friction orchestration** during development: fewer moving parts than Airflow/Dagster.
- Works well with the model-level cron built into SQLMesh.

**Production path**

- Move to **Airflow/Dagster/GitHub Actions** or **Tobiko Cloud (SQLMesh Cloud)**:
  - Cloud schedulers handle alerting/retries and avoid laptop sleep problems.
  - Switch the warehouse from local DuckDB to a server database for concurrency and shared access.

---



```
