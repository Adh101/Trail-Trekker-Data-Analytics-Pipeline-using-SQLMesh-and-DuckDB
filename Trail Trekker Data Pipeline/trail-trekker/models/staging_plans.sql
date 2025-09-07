 MODEL (
    name staging.plans,
    kind VIEW
 );

 SELECT
    plan_id,
    plan_name,
    plan_level,
    price AS monthly_price_usd,
    max_hikes_per_month,
    photo_storage_gb,
    description AS plan_description,
    created_at::timestamp AS plan_created_at
 FROM raw.plans