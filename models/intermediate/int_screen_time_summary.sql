SELECT
    screen_time_user,
    device,
    screen_date,
    total_screen_time_minutes,
    total_pickups,
    total_notifications,
    first_pickup_time,
    _loaded_at,
    _source_file
FROM {{ ref('stg_apple_screen_time') }}
