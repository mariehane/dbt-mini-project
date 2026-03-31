-- Creates one row per day from earliest data to today.
{{
    dbt_date.get_base_dates(
        start_date="2024-01-01",
        end_date=run_started_at.strftime("%Y-%m-%d")
    )
}}
