-- -----------------------------------------------------------------------------
-- Model: trail_trekker.warehouse.fct_subscription_changes
-- Purpose: Capture atomic subscription change events for analytics
-- Grain:   1 row per (customer_id, subscription_id, change event)
--
-- Business rules implemented:
--   • New subscription starts are NOT events
--   • Changes are evaluated within the SAME subscription_id
--   • A plan switch is a PLAN_CHANGE and is effective on the NEW segment’s start date
--   • A cancellation is only emitted if it is TERMINAL (no later row in the same subscription_id)
--   • Cancellation effective date is the subscription_end_date
--   • Output columns include before/after plan context
-- -----------------------------------------------------------------------------

MODEL (
  name trail_trekker.warehouse.fct_subscription_changes,
  kind VIEW,
  cron '@hourly',
  audits (
    not_null(columns := (subscription_change_id, customer_id, change_type, change_date))
  )
);

WITH s AS (
  -- -----------------------------------------------------------------------------
  -- 1) Base staging / normalization
  -- -----------------------------------------------------------------------------
  SELECT
    subscription_id,
    customer_id,
    plan_id,
    LOWER(TRIM(billing_cycle))                AS billing_cycle,      -- 'monthly' / 'annual'
    UPPER(TRIM(status))                       AS status,             -- e.g., 'ACTIVE' / 'CANCELLED'
    TRY_CAST(subscription_start_date AS DATE) AS subscription_start_date,
    TRY_CAST(subscription_end_date   AS DATE) AS subscription_end_date
  FROM staging.subscriptions
  WHERE subscription_start_date IS NOT NULL
),

subscription_events AS (
  -- -----------------------------------------------------------------------------
  -- 2) Timeline windows (computed WITHIN each customer's subscription_id)
  --    - previous_plan_id:   prior plan segment in the same subscription
  --    - next_start_same_sub: presence of a later segment (used to detect terminal cancels)
  -- -----------------------------------------------------------------------------
  SELECT
    s.*,
    LAG(plan_id) OVER ( PARTITION BY customer_id, subscription_id ORDER BY subscription_start_date) AS previous_plan_id,
    LEAD(subscription_start_date) OVER (PARTITION BY customer_id, subscription_id ORDER BY subscription_start_date ) AS next_start_same_sub,
    status AS subscription_status
  FROM s
),

subscription_changes AS (
  -- -----------------------------------------------------------------------------
  -- 3) Classify rows as:
  --     - 'CANCELLATION' if terminal cancel for this subscription_id
  --     - 'PLAN_CHANGE'  if plan_id differs from the previous row (same subscription_id)
  --     - 'NO_CHANGE'    otherwise
  --
  --    We exclude NEW subscriptions (previous_plan_id IS NULL) from being PLAN_CHANGE,
  --    but we still allow terminal cancels to be emitted even if they happen to be the first row.
  -- -----------------------------------------------------------------------------
  SELECT 
    se.*,
    CASE
      -- Terminal cancellation only:
      --   - current row is 'CANCELLED'
      --   - there is NO later segment in the same subscription (terminal)
      --   - an end date is present
      WHEN se.subscription_status = 'CANCELLED'
       AND se.next_start_same_sub IS NULL
       AND se.subscription_end_date IS NOT NULL
        THEN 'CANCELLATION'

      -- Plan change within the same subscription timeline
      WHEN se.previous_plan_id IS NOT NULL
       AND se.plan_id <> se.previous_plan_id
        THEN 'PLAN_CHANGE'

      -- Everything else is not a change event
      ELSE 'NO_CHANGE'
    END AS change_type
  FROM subscription_events se
  WHERE
    -- Exclude new subscriptions from changes,
    -- but still allow terminal cancels to pass through.
    se.previous_plan_id IS NOT NULL
    OR (se.subscription_status = 'CANCELLED'
        AND se.next_start_same_sub IS NULL
        AND se.subscription_end_date IS NOT NULL)
)

-- -----------------------------------------------------------------------------
-- 4) Final select:
--    - Build a deterministic surrogate key
--    - Emit only change rows (PLAN_CHANGE / CANCELLATION)
--    - Provide effective date + before/after context
-- -----------------------------------------------------------------------------
SELECT
  -- Deterministic event key: stable across runs & environments
  HASH(
    customer_id,
    subscription_id,
    change_type,
    COALESCE(CAST(
      CASE WHEN change_type = 'CANCELLATION'
           THEN subscription_end_date      -- cancels effective when they end
           ELSE subscription_start_date    -- switches effective when the new plan starts
      END AS VARCHAR
    ), ''),
    COALESCE(
      CASE WHEN change_type = 'CANCELLATION'
           THEN plan_id                    -- cancelled plan
           ELSE previous_plan_id           -- plan before the switch
      END, ''
    ),
    COALESCE(
      CASE WHEN change_type = 'CANCELLATION'
           THEN NULL                       -- no "to" plan on cancel
           ELSE plan_id                    -- plan after the switch
      END, ''
    )
  ) AS subscription_change_id,

  -- Natural identifiers
  customer_id,
  subscription_id,

  -- Change classification
  change_type,

  -- Effective date (per business rule)
  CASE WHEN change_type = 'CANCELLATION'
       THEN subscription_end_date
       ELSE subscription_start_date
  END AS change_date,

  -- Before/after plan context (handy for joins/analysis)
  CASE WHEN change_type = 'CANCELLATION'
       THEN plan_id
       ELSE previous_plan_id
  END AS from_plan_id,

  CASE WHEN change_type = 'CANCELLATION'
       THEN NULL
       ELSE plan_id
  END AS to_plan_id

FROM subscription_changes
WHERE change_type <> 'NO_CHANGE'




