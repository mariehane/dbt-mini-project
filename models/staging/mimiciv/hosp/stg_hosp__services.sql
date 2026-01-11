with source as (
    select * from {{ source('mimiciv_hosp', 'services') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- Service details
        transfertime::timestamp_ntz as transfertime,
        upper(trim(prev_service)) as prev_service,
        upper(trim(curr_service)) as curr_service,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
