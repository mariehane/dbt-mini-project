with source as (
    select * from {{ source('mimiciv_hosp', 'labevents') }}
),

cleaned as (
    select
        -- Primary key
        labevent_id::integer as labevent_id,
        
        -- Foreign keys
        subject_id::integer as subject_id,
        nullif(trim(hadm_id), '')::integer as hadm_id,
        specimen_id::integer as specimen_id,
        itemid::integer as itemid,
        
        -- Timestamps
        charttime::timestamp_ntz as charttime,
        storetime::timestamp_ntz as storetime,
        
        -- Values
        nullif(trim(value), '') as value,
        valuenum,
        nullif(trim(valueuom), '') as valueuom,
        ref_range_lower,
        ref_range_upper,
        
        -- Flags
        nullif(trim(flag), '') as flag,
        nullif(trim(priority), '') as priority,
        nullif(trim(comments), '') as comments,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
