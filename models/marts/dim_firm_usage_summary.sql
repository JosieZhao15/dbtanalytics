{{
  config(
    materialized = "table",
    tags = ["firms"]
  )
}}

select
    firms.id as firm_id,
    firms.created as firm_created,
    firms.firm_size,
    firms.arr_in_thousands,
    count(distinct events.user_id) as user_count,
    count(events.id) as query_count,
    count(distinct events.event_type) as event_type_count,
    min(event.feedback_score) as lowest_feedback_score,
    max(event.feedback_score) as highest_feedback_score,
    avg(event.feedback_score) as average_feedback_score,
    sum(if(events.event_type = 'WORKFLOW', 1, 0)) as workflow_query_count,
    sum(if(events.event_type = 'ASSISTANT', 1, 0)) as assistant_query_count,
    sum(if(events.event_type = 'VAULT', 1, 0)) as vault_query_count
from
    {{ref('stg_firms')}} as firms
    left join {{ref('stg_events')}} as events
        on firms.id = events.firm_id
        -- one to many join relationship
