with source as (
    select * from {{ source('mimiciv_hosp', 'd_icd_procedures') }}
),

cleaned as (
    select
        -- Code details
        upper(trim(icd_code)) as icd_code,
        icd_version::integer as icd_version,
        trim(long_title) as long_title,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
