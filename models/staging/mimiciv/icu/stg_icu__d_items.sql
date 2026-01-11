with source as (
    select * from {{ source('mimiciv_icu', 'd_items') }}
),

cleaned as (
    select
        -- Item details
        itemid::integer as itemid,
        trim(label) as label,
        trim(abbreviation) as abbreviation,
        trim(linksto) as linksto,
        trim(category) as category,
        trim(unitname) as unitname,
        trim(param_type) as param_type,
        lownormalvalue,
        highnormalvalue,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
