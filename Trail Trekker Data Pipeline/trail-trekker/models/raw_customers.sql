MODEL (
  name raw.customers,
  kind SEED (
    path '/Users/atishdhamala/Trail Trekker Data Pipeline/data/customers.csv'
  ),
  description 'Customers entity per ERD. PK = customer_id. One customer can have many subscriptions.',
  column_descriptions (
    customer_id = 'Primary key (ERD underlined).',
    username = 'Login/display handle.',
    email = 'Contact email (lowercased in staging).',
    phone = 'Freeform phone number.',
    first_name = 'Given name.',
    last_name = 'Family name.',
    location_state = 'US state code.',
    location_country = 'Country (e.g., USA).',
    profile_created_date = 'Account creation date (string in CSV).',
    total_hikes_logged = 'Integer-like count of hikes.',
    favorite_trail_type = 'Preference (e.g., Mountain, Forest).'
  )
);