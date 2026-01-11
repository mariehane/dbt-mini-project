with source as (
    select * from {{ source('mimiciv_hosp', 'diagnoses_icd') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- Diagnosis details
        seq_num::integer as seq_num,
        upper(trim(icd_code)) as icd_code,
        icd_version::integer as icd_version,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
