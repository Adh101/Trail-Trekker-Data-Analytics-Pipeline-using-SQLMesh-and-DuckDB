 MODEL (
    name staging.customers,
    kind VIEW,
    audits (
        not_null(columns := (customer_id, username, email))
    )
 );

 SELECT
    customer_id,
    username,
    email,
    phone,
    first_name,
    last_name,
    date_of_birth::timestamp AS birth_date,
    preferred_difficulty AS difficulty_preference,
    location_city,
    location_state,
    location_country,
    profile_created_date::timestamp AS profile_created_at,
    total_hikes_logged,
    favorite_trail_type
FROM raw.customers