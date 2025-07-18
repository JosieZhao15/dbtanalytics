{{
  config(
    materialized = "table",
    tags = ["events"]
  )
}}

with dates as (
    --the purpose of this date array is to make sure we can populate everyday's date even if there's no activity for a particular date
    select
        generate_date_array('2022-01-01', current_date(), interval 1 day) as date_array
),

daily_activities as (
    select
        date(created) as day, -- assuming created is a timestamp
        count(*) as events_count,
        count(distinct firm_id) as firms_count,
        count(distinct user_id) as users_count,
        count(distinct event_type) as event_type_count,
        count(num_docs) as docs_count,
        avg(feedback_score) as average_feedback_score,
        safe_divide(sum(feedback_score), count(distinct firm_id)) as average_feedback_score_per_firm,
        safe_divide(sum(feedback_score), count(distinct user_id)) as average_feedback_score_per_user
    from
        {{ref('stg_events')}}
)

select
    dates.date_array as query_date, -- primary key of the table
    daily_activities.events_count,
    daily_activities.firms_count,
    daily_activities.users_count,
    daily_activities.event_type_count,
    daily_activities.docs_count,
    daily_activities.average_feedback_score,
    average_feedback_score_per_firm,
    average_feedback_score_per_user
from
    dates
    left join daily_activities
        on dates.date_array = daily_activities.day
        -- one to one join relationship
        -- but if in a particular day, there's no event activity, the left join would still populate that date