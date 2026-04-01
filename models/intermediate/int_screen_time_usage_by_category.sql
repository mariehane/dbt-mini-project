SELECT
    st.screen_time_user,
    st.device,
    st.screen_date,
    f.value:category::STRING AS category,
    f.value:duration_minutes::NUMBER AS duration_minutes,
    st._loaded_at,
    st._source_file
FROM {{ ref('stg_apple_screen_time') }} AS st,
    LATERAL FLATTEN(input => st.usage_by_category) AS f
