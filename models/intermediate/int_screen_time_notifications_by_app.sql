SELECT
    st.screen_time_user,
    st.device,
    st.screen_date,
    f.value:app_name::STRING AS app_name,
    f.value:notification_count::NUMBER AS notification_count,
    st._loaded_at,
    st._source_file
FROM {{ ref('stg_apple_screen_time') }} AS st,
    LATERAL FLATTEN(input => st.notifications_by_app) AS f
