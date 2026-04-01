-- The "God table" — one row per day, every metric joined in.

WITH spine AS (
    SELECT date_day FROM {{ ref('int_daily_spine') }}
),

sleep AS (
    SELECT * FROM {{ ref('int_sleep_metrics') }}
),
{#
--
--nutrition AS (
--    SELECT * FROM {{ ref('int_nutrition_daily') }}
--),
--
--workouts AS (
--    SELECT * FROM {{ ref('int_workout_summary') }}
--),
--
--weather AS (
--    SELECT * FROM {{ ref('stg_weather_daily') }}
--),

#}
screen AS (
    SELECT
        screen_date AS date_day,
        SUM(total_screen_time_minutes) AS total_screen_time_min,
        SUM(total_pickups) AS total_pickups,
        SUM(total_notifications) AS total_notifications,
        MIN(first_pickup_time) AS first_pickup_time
    FROM {{ ref('int_screen_time_summary') }}
    GROUP BY 1
){#,
--
--home_temp AS (
--    SELECT
--        recorded_date,
--        AVG(CASE WHEN location = 'bedroom' THEN temp_c END) AS avg_bedroom_temp_c,
--        AVG(temp_c)                                          AS avg_home_temp_c
--    FROM {{ ref('stg_home_temperature') }}
--    GROUP BY 1
--)
#}

SELECT
    s.date_day,

    -- 🛌 Sleep
    sl.sleep_onset_at,
    sl.wake_up_at,
    sl.total_sleep_min,
    sl.deep_sleep_min,
    sl.rem_sleep_min,
    sl.avg_sleeping_hr,

    -- 📱 Screen Time
    sc.total_screen_time_min,
    sc.total_pickups,
    sc.total_notifications,
    sc.first_pickup_time--,

    -- 🌡️ Home Environment
    --ht.avg_bedroom_temp_c,
    --ht.avg_home_temp_c,

    -- ☀️ Weather & Daylight
    --w.sunrise,
    --w.sunset,
    --w.daylight_hours,
    --w.temp_high_c                   AS outside_temp_high_c,
    --w.temp_low_c                    AS outside_temp_low_c,
    --w.precipitation_mm,

    -- 🍎 Nutrition
    --n.total_calories,
    --n.total_protein_g,
    --n.total_carbs_g,
    --n.total_fat_g,
    --n.first_meal_at,
    --n.last_meal_at,
    --DATEDIFF('minute', n.first_meal_at, n.last_meal_at) AS eating_window_min,

    -- 🏋️ Exercise
    --wk.workout_count,
    --wk.total_workout_min,
    --wk.total_calories_burned,
    --wk.workout_types                -- e.g. 'Strength, Running'

FROM      spine       s
LEFT JOIN sleep       sl ON s.date_day = sl.sleep_date
LEFT JOIN screen      sc ON s.date_day = sc.date_day
--LEFT JOIN home_temp   ht ON s.date_day = ht.recorded_date
--LEFT JOIN weather     w  ON s.date_day = w.date
--LEFT JOIN nutrition   n  ON s.date_day = n.date
--LEFT JOIN workouts    wk ON s.date_day = wk.date