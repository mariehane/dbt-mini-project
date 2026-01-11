with source as (
    select * from {{ source('mimiciv_hosp', 'emar') }}
),

cleaned as (
    select
        -- Primary/Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        emar_id::varchar as emar_id,
        emar_seq::integer as emar_seq,
        poe_id::varchar as poe_id,
        pharmacy_id::integer as pharmacy_id,
        
        -- Timestamps
        charttime::timestamp_ntz as charttime,
        scheduletime::timestamp_ntz as scheduletime,
        storetime::timestamp_ntz as storetime,
        
        -- Medication details
        trim(medication) as medication,
        trim(event_txt) as event_txt,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
