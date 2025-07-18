{{
  config(
    materialized = "view",
    tags = ["users"]
  )
}}

select
    id, -- primary key of the table
    created,
    title
from
    {{ source('staging_models', 'users') }}