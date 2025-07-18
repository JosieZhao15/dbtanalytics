Welcome to your new dbt project!

### Assumptions

Assumption One
- Each user_id is uniquely tied to one firm_id for all time. If a user switches firms, they are assigned a new user_id under the new firm_id. As a
  result, in the events table, all events associated with a given user_id will always be tied to a single firm_id.
- This ensures that when aggregating user-level activity metrics, each user's engagement is attributed to one firm only—never across multiple firms.
- This assumption is important to highlight because if there is a positive correlation between firm size and user engagement, mixing activities
  across firms for a single user could skew the analysis and misrepresent engagement patterns for the firm-level assessment, when defining power users.
- For example, if a user was at a smaller firm with lower ARR, switched to a bigger firm with higher ARR, but kept the same user_id, as a result in the
  user-level aggreations, all past activity patterns would be attributed to the most recent firm in the model dim_user_engagement.sql

Assumption Two
- In the events table, I assumed created column is a timestamp, not a date. It was indicated as a timestamp in the take home doc, but it's a date in the
  Google Sheet
- My assumption is, a user should only be able to have one query event created at the exact timestamp down to the millisecond. Maybe they can have multiple
  windows open at the same time to run multiple queries, but in reality I think for the same user they should have only one query event at the exact timestamp
- This was important to assume, because the raw events data from the sheet did not have a primary key. To follow dbt's standard best practices, every single
  model should always have a primary key, this is for the purpose of maintaining data integrity for unique and not null tests
- So, I added the hash function farm_fingerprint() in the model stg_events.sql to populate a static primary key for the tests in staging_models.yml in line 23 and 24

Assumption Three
- I assumed that there are only three event types: WORKFLOW, ASSISTANT, and VAULT.
- This assumption is important because in both dim_user_engagement.sql and dim_firm_usage_summary.sql, I implemented pivot logic using SUM(IF(...)) for each event type.
- This hardcoded approach will only capture the specified event types. Any new or unexpected event types introduced in the future would be excluded from the pivot and
  thus from the output.
- If the list of event types is likely to expand over time, a more scalable approach would be to use the PIVOT operator

### How to interpret the models
