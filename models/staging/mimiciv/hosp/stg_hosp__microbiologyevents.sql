with source as (
    select * from {{ source('mimiciv_hosp', 'microbiologyevents') }}
),

cleaned as (
    select
        -- Primary/Foreign keys
        microevent_id::integer as microevent_id,
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        micro_specimen_id::integer as micro_specimen_id,
        
        -- Timestamps
        chartdate::date as chartdate,
        charttime::timestamp_ntz as charttime,
        storedate::date as storedate,
        storetime::timestamp_ntz as storetime,
        
        -- Specimen details
        spec_itemid::integer as spec_itemid,
        trim(spec_type_desc) as spec_type_desc,
        test_seq::integer as test_seq,
        
        -- Test details
        test_itemid::integer as test_itemid,
        trim(test_name) as test_name,
        
        -- Organism details
        org_itemid::integer as org_itemid,
        trim(org_name) as org_name,
        isolate_num::integer as isolate_num,
        trim(quantity) as quantity,
        
        -- Antibiotic details
        ab_itemid::integer as ab_itemid,
        trim(ab_name) as ab_name,
        trim(dilution_text) as dilution_text,
        trim(dilution_comparison) as dilution_comparison,
        dilution_value,
        upper(trim(interpretation)) as interpretation,
        trim(comments) as comments,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
