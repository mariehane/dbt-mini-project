with source as (
    select * from {{ source('mimiciv_core', 'transfers') }}
),

renamed as (
    select
        -- Primary key
        transfer_id::integer as transfer_id,
        
        -- foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- transfer details
        upper(trim(eventtype)) as eventtype,
        upper(trim(careunit)) as careunit,
        
        -- timestamps
        intime::timestamp_ntz as intime,
        outtime::timestamp_ntz as outtime,
        
        -- metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from renamed
