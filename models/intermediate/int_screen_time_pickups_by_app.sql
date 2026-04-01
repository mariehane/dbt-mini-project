SELECT
    st.screen_time_user,
    st.device,
    st.screen_date,
    f.value:app_name::STRING AS app_name,
    f.value:first_app_after_pickup_count::NUMBER AS first_app_after_pickup_count,
    st._loaded_at,
    st._source_file
FROM {{ ref('stg_apple_screen_time') }} AS st,
    LATERAL FLATTEN(input => st.pickups_by_app) AS f
