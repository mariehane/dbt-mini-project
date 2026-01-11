with source as (
    select * from {{ source('mimiciv_icu', 'outputevents') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        stay_id::integer as stay_id,
        itemid::integer as itemid,
        
        -- Timestamps
        charttime::timestamp_ntz as charttime,
        storetime::timestamp_ntz as storetime,
        
        -- Values
        value,
        trim(valueuom) as valueuom,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
