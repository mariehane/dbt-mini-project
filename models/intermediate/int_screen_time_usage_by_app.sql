SELECT
    st.screen_time_user,
    st.device,
    st.screen_date,
    f.value:app_name::STRING AS app_name,
    f.value:bundle_id::STRING AS bundle_id,
    f.value:category::STRING AS category,
    f.value:duration_minutes::NUMBER AS duration_minutes,
    st._loaded_at,
    st._source_file
FROM {{ ref('stg_apple_screen_time') }} AS st,
    LATERAL FLATTEN(input => st.usage_by_app) AS f
