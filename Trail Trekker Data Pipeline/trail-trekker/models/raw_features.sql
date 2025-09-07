MODEL (
  name raw.features,
  kind SEED (
    path '/Users/atishdhamala/Trail Trekker Data Pipeline/data/features.csv'
  ),
  description 'Feature reference list.',
  column_descriptions (
    feature_id = 'Primary ID for a feature',
    feature_name = 'Marketing-friendly name',
    feature_description = 'Short description',
    feature_category = 'Grouping: Core, Advanced, Community'
  )
);