MODEL (
  name raw.plans,
  kind SEED ( path '/Users/atishdhamala/Trail Trekker Data Pipeline/data/plans.csv' ),
  description 'Plans catalog (seeded from CSV).',
  column_descriptions (
    plan_id = 'Plan SKU (includes M/A suffix)',
    plan_name = 'Explorer / Adventurer / Trail Master',
    plan_level = '1..3',
    price = 'String in CSV; staged as DECIMAL(10,2)',
    max_hikes_per_month = 'Int-like in CSV; staged as INT',
    photo_storage_gb = 'Int-like in CSV; staged as INT',
    description = 'Plan description',
    created_at = 'Plan creation date (string in CSV)'
  )
);