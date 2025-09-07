MODEL (
  name raw.subscriptions,
  kind SEED ( path '/Users/atishdhamala/Trail Trekker Data Pipeline/data/subscriptions.csv' ),
  description 'Raw subscriptions (seeded from CSV).',
  column_descriptions (
    subscription_id = 'Primary key',
    customer_id = 'FK to customers',
    plan_id = 'FK to plans',
    billing_cycle = 'monthly / annual (string)',
    subscription_start_date = 'Date string in CSV',
    subscription_end_date = 'Nullable date string in CSV',
    status = 'active / cancelled (string)',
    next_billing_date = 'Nullable date string in CSV',
    payment_method = 'credit_card, etc.'
  )
);