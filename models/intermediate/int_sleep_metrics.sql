WITH source AS (
    SELECT * FROM {{ ref('stg_sleep') }}
)

SELECT
    sleep_date,
    sleep_onset_at,
    wake_up_at,
    total_sleep_min,
    deep_sleep_min,
    rem_sleep_min,
    CAST(NULL AS FLOAT) AS avg_sleeping_hr
FROM source
