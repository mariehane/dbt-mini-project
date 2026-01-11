with source as (
    select * from {{ source('mimiciv_icu', 'icustays') }}
),

cleaned as (
    select
        -- Primary key
        stay_id::integer as stay_id,
        
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- Care unit details
        upper(trim(first_careunit)) as first_careunit,
        upper(trim(last_careunit)) as last_careunit,
        
        -- Timestamps
        intime::timestamp_ntz as intime,
        outtime::timestamp_ntz as outtime,
        
        -- Length of stay
        los,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
