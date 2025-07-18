{{
  config(
    materialized = "table",
    tags = ["users"]
  )
}}


with user_activities as (
    select
        users.id as user_id,
        date_trunc(events.created, month) as query_month,
            -- using created from events table to extract monthly activity metrics instead of user created date
        events.firm_id,
            -- assuming a user_id can only be tied to one firm_id of all time. If the same user switched to a new firm, they will receive a new user_id
        firms.firm_size,
        firms.arr_in_thousands,
        count(events.id) as total_query_count,
        count(distinct events.event_type) as event_type_count,
        max(events.created) as latest_query_created,
        min(feedback_score) as lowest_feedback_score,
        max(feedback_score) as highest_feedback_score,
        avg(feedback_score) as average_feedback_score,
        sum(if(events.event_type = 'WORKFLOW', 1, 0)) as workflow_query_count,
        sum(if(events.event_type = 'ASSISTANT', 1, 0)) as assistant_query_count,
        sum(if(event.event_type = 'VAULT', 1, 0)) as vault_query_count
    from
        {{ref('stg_users')}} as users
        left join {{ref('stg_events')}} as events
            on users.id = events.user_id
            -- one to many join relationship
        left join {{ref('stg_firms')}} as firms
            on events.firm_id = firms.id
            -- many to one join relationship
    group by
        1, 2, 3, 4, 5
)

select
    farm_fingerprint(user_id, query_month) as id, -- primary key of the table
    user_id,
    query_month,
    firm_id,
    firm_size,
    arr_in_thousands,
    total_query_count,
    event_type_count,
    latest_query_created,
    lowest_feedback_score,
    highest_feedback_score,
    average_feedback_score,
    workflow_query_count,
    assistant_query_count,
    vault_query_count
from
    user_activities

/*
2. Analytics Questions

Answers:
  Based on your user_engagement model, how would you define a power user?
    - Here are the aspects I'd consider to assess a power user:
        - volume, query searches each month
        - coverage, how many types of events are being searched or covered each month
        - feedback, is the average feedback score high, what portion of the query events are above certain percentile
        - retention, when was the most recent query event, and if there are at least a certain number of query events each month
    - to be more granular, we could also assess user engagement at the firm level too
        - there might be correlations between firm size or ARR with query events volume
        - it also can be helpful to uncover big opportunities to improve user engagement. Such as, if a larger firm with higher ARR has lower than average events volume

  What potential issues or data quality concerns does the data surface? (These could be anomalies, missing data, inconsistent definitions, etc.)
    - if the created from events is missing for some events tied to a user, it would break the aggregation in the model. There's a non null test added in staging_models.yml line 27 and marts_models.yml line 14 for monitoring this
    - if there are any significant events volumn tied to a particular firm or user, it could be cause by bots, which could make the metrics skewed for count(), avg(), sum() 
*/