with source as (
    select * from {{ source('mimiciv_hosp', 'd_labitems') }}
),

cleaned as (
    select
        -- Item details
        itemid::integer as itemid,
        trim(label) as label,
        trim(fluid) as fluid,
        trim(category) as category,
        trim(loinc_code) as loinc_code,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
