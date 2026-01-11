with source as (
    select * from {{ source('mimiciv_hosp', 'hcpcsevents') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- Event details
        chartdate::date as chartdate,
        upper(trim(hcpcs_cd)) as hcpcs_cd,
        seq_num::integer as seq_num,
        trim(short_description) as short_description,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
