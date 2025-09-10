MODEL (
  name staging.features,
  kind VIEW,
  audits (
    not_null(columns := (feature_id))
  )
);

SELECT
  feature_id,
  TRIM(feature_name) AS feature_name,
  TRIM(feature_description) AS feature_description,
  UPPER(TRIM(feature_category)) AS feature_category
FROM trail_trekker.raw.features