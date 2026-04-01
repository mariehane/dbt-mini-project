WITH source AS (
    SELECT * FROM {{ source('raw', 'apple_watch_sleep') }}
),

flattened AS (
    SELECT
        _raw:sleep_session_id::STRING       AS sleep_session_id,
        _raw:date::DATE                     AS sleep_date,
        _raw:sleep_onset::TIMESTAMP_NTZ     AS sleep_onset_at,
        _raw:wake_time::TIMESTAMP_NTZ       AS wake_up_at,
        _raw:total_sleep_min::FLOAT         AS total_sleep_min,
        _raw:deep_sleep_min::FLOAT          AS deep_sleep_min,
        _raw:rem_sleep_min::FLOAT           AS rem_sleep_min,
        _raw:core_sleep_min::FLOAT          AS core_sleep_min,
        _raw:awake_min::FLOAT               AS awake_min,
        _loaded_at,
        _source_file
    FROM source
)

SELECT * FROM flattened