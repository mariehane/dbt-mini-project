with source as (
    select * from {{ source('mimiciv_hosp', 'drgcodes') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- DRG details
        upper(trim(drg_type)) as drg_type,
        upper(trim(drg_code)) as drg_code,
        trim(description) as description,
        drg_severity::integer as drg_severity,
        drg_mortality::integer as drg_mortality,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
