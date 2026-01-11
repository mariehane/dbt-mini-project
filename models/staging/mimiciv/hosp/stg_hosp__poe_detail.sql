with source as (
    select * from {{ source('mimiciv_hosp', 'poe_detail') }}
),

cleaned as (
    select
        -- Foreign keys
        poe_id::varchar as poe_id,
        poe_seq::integer as poe_seq,
        subject_id::integer as subject_id,
        
        -- Field details
        trim(field_name) as field_name,
        trim(field_value) as field_value,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
