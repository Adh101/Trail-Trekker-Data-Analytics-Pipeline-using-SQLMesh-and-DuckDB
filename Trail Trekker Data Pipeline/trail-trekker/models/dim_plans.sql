MODEL (
  name trail_trekker.warehouse.dim_plans,
  kind VIEW,
  cron '@hourly',
  audits (
    not_null(columns := (plan_id, plan_name, price))
  )
);

WITH ranked AS (
  SELECT
    p.*,
    ROW_NUMBER() OVER (
      PARTITION BY plan_id
      ORDER BY created_at NULLS LAST, plan_name
    ) AS rn
  FROM trail_trekker.staging.plans p
)

SELECT
  -- surrogate key
  HASH(plan_id) AS plan_sk,
  plan_id,
  plan_name,
  plan_level,
  price,
  max_hikes_per_month,
  photo_storage_gb,
  description,
  created_at                               AS plan_created_at,
  CASE RIGHT(plan_id, 1)
    WHEN 'M' THEN 'monthly'
    WHEN 'A' THEN 'annual'
    ELSE NULL
  END                                       AS billing_period
FROM ranked
WHERE rn = 1;