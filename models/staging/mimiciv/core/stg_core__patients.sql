with source as (
    select * from {{ source('mimiciv_core', 'patients') }}
),

renamed as (
    select
        -- primary key
        subject_id::integer as subject_id,
        
        -- demographics
        upper(trim(gender)) as gender,
        anchor_age::integer as anchor_age,
        anchor_year::integer as anchor_year,
        trim(anchor_year_group) as anchor_year_group,
        
        -- death information
        dod::date as dod,
        
        -- metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from renamed
