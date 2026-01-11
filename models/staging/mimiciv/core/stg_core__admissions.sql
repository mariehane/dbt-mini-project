with source as (
    select * from {{ source('mimiciv_core', 'admissions') }}
),

renamed as (
    select
        -- primary key
        hadm_id::integer as hadm_id,
        
        -- foreign keys
        subject_id::integer as subject_id,
        
        -- timestamps
        admittime::timestamp_ntz as admittime,
        dischtime::timestamp_ntz as dischtime,
        deathtime::timestamp_ntz as deathtime,
        edregtime::timestamp_ntz as edregtime,
        edouttime::timestamp_ntz as edouttime,
        
        -- admission details
        upper(trim(admission_type)) as admission_type,
        upper(trim(admission_location)) as admission_location,
        upper(trim(discharge_location)) as discharge_location,
        
        -- patient info
        upper(trim(insurance)) as insurance,
        upper(trim(language)) as language,
        upper(trim(marital_status)) as marital_status,
        upper(trim(ethnicity)) as ethnicity,
        
        -- flags
        case when hospital_expire_flag = 1 then true when hospital_expire_flag = 0 then false else null end as hospital_expire_flag,
        
        -- metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from renamed
