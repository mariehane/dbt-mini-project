with source as (
    select * from {{ source('mimiciv_hosp', 'codes') }}
),

cleaned as (
    select
        -- Code details
        id::integer as id,
        upper(trim(code)) as code,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
