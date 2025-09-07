MODEL (
  name raw.plan_features,
  kind SEED (
    path '/Users/atishdhamala/Trail Trekker Data Pipeline/data/plan_features.csv'
  ),
  description 'Feature inclusion map per plan.',
  column_descriptions (
    plan_feature_id = 'Row ID',
    plan_id = 'Plan ID',
    feature_id = 'Feature ID',
    included = 'Boolean: feature included in plan'
  )
);