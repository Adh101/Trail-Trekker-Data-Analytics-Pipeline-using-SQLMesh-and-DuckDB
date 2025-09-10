MODEL (
  name staging.subscriptions,
  kind VIEW, 
  audits (
    not_null(columns := (subscription_id, customer_id, plan_id))
  )
);

-- SELECT 
--     subscription_id,
--     customer_id,
--     plan_id,
--     billing_cycle AS billing_cadence,
--     subscription_start_date::timestamp AS subscription_started_at,
--     subscription_end_date::timestamp AS subscription_ended_at,
--     status AS subscription_status,
--     next_billing_date::timestamp AS next_billing_at,
--     payment_method
-- FROM raw.subscriptions

SELECT
  subscription_id,
  customer_id,
  plan_id,
  LOWER(TRIM(billing_cycle)) AS billing_cycle,
  TRY_CAST(subscription_start_date AS DATE) AS subscription_start_date,
  TRY_CAST(STRPTIME(subscription_end_date, '%Y-%m-%d') AS DATE) AS subscription_end_date,
  UPPER(TRIM(status)) AS status,
  TRY_CAST(STRPTIME(next_billing_date, '%Y-%m-%d') AS DATE) AS next_billing_date,
  LOWER(TRIM(payment_method)) AS payment_method
FROM trail_trekker.raw.subscriptions;