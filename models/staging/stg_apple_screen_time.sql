WITH source AS (
    SELECT * FROM {{ source('raw', 'apple_screen_time') }}
),

parsed AS (
    SELECT
        _raw:user::STRING AS screen_time_user,
        _raw:device::STRING AS device,
        _raw:date::DATE AS screen_date,
        _raw:summary:total_screen_time_minutes::NUMBER AS total_screen_time_minutes,
        _raw:summary:total_pickups::NUMBER AS total_pickups,
        _raw:summary:total_notifications::NUMBER AS total_notifications,
        TRY_TO_TIMESTAMP_TZ(_raw:summary:first_pickup_time::STRING) AS first_pickup_time,
        _raw:usage_by_category AS usage_by_category,
        _raw:usage_by_app AS usage_by_app,
        _raw:web_usage AS web_usage,
        _raw:pickups_by_app AS pickups_by_app,
        _raw:notifications_by_app AS notifications_by_app,
        _loaded_at,
        _source_file
    FROM source
)

SELECT * FROM parsed
