--Create the DuckDB database
ATTACH DATABASE '/Users/atishdhamala/Trail Trekker Data Pipeline/trail_trekker.db' AS trail_trekker;
CREATE SCHEMA IF NOT EXISTS trail_trekker.raw;

-- read from CSV with default params
CREATE OR REPLACE TABLE trail_trekker.raw.features AS SELECT * FROM '/Users/atishdhamala/Trail Trekker Data Pipeline/data/features.csv';
CREATE OR REPLACE TABLE trail_trekker.raw.customers AS SELECT * FROM '/Users/atishdhamala/Trail Trekker Data Pipeline/data/customers.csv';
CREATE OR REPLACE TABLE trail_trekker.raw.plan_features AS SELECT * FROM '/Users/atishdhamala/Trail Trekker Data Pipeline/data/plan_features.csv';
CREATE OR REPLACE TABLE trail_trekker.raw.subscriptions AS SELECT * FROM '/Users/atishdhamala/Trail Trekker Data Pipeline/data/subscriptions.csv';
--read the csv files from github
CREATE OR REPLACE TABLE trail_trekker.raw.plans AS SELECT * FROM 'https://raw.githubusercontent.com/schottma/trail_trekker/refs/heads/main/plans.csv';

