{{
  config(
    materialized = "view",
    tags = ["events"]
  )
}}

select
    farm_fingerprint(
        user_id, firm_id, created, event_type) as id, -- primary key of the table
        /* each dbt model should always have a static unique key for data integrity checks.
           my assumption here is:
             - created should be a timestamp, as indicated in the take home doc, even though in the Google Sheet it shows as date
             - when the 4 columns being combined, it should provide a unique key to the table
        */
    created,
    firm_id,
    user_id,
    event_type,
    num_docs,
    feedback_score
from
    {{ source('staging_models', 'events') }}