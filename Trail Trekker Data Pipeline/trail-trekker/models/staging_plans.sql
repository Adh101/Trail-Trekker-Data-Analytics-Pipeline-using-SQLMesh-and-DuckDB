 MODEL (
    name staging.plans,
    kind VIEW
 );

--  SELECT
--     plan_id,
--     plan_name,
--     plan_level,
--     price AS monthly_price_usd,
--     max_hikes_per_month,
--     photo_storage_gb,
--     description AS plan_description,
--     created_at::timestamp AS plan_created_at
--  FROM raw.plans

SELECT
  plan_id,
  TRIM(CAST(plan_name AS VARCHAR)) AS plan_name,
  TRY_CAST(plan_level AS INT) AS plan_level,
  TRY_CAST(REGEXP_REPLACE(CAST(price AS VARCHAR), '[^0-9.]', '') AS DECIMAL(10, 2)) AS price,
  TRY_CAST(REGEXP_REPLACE(CAST(max_hikes_per_month AS VARCHAR), '[^0-9]', '') AS INT) AS max_hikes_per_month,
  TRY_CAST(REGEXP_REPLACE(CAST(photo_storage_gb    AS VARCHAR), '[^0-9]', '') AS INT) AS photo_storage_gb,
  TRIM(CAST(description AS VARCHAR))                               AS description,
  TRY_CAST(STRPTIME(created_at, '%Y-%m-%d') AS DATE)               AS created_at
FROM trail_trekker.raw.plans
WHERE plan_id <> '000000';