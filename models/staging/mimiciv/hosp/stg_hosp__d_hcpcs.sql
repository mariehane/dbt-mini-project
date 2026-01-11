with source as (
    select * from {{ source('mimiciv_hosp', 'd_hcpcs') }}
),

cleaned as (
    select
        -- Code details
        upper(trim(code)) as code,
        trim(category) as category,
        trim(long_description) as long_description,
        trim(short_description) as short_description,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
