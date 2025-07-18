{{
  config(
    materialized = "view",
    tags = ["firms"]
  )
}}

select
    id, -- primary key of the table
    created,
    firm_size,
    arr_in_thousands
from
    {{ source('staging_models', 'firms') }}