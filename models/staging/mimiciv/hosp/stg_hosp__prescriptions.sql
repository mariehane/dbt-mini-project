with source as (
    select * from {{ source('mimiciv_hosp', 'prescriptions') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        pharmacy_id::integer as pharmacy_id,
        
        -- Timestamps
        starttime::timestamp_ntz as starttime,
        stoptime::timestamp_ntz as stoptime,
        
        -- Medication details
        upper(trim(drug_type)) as drug_type,
        trim(drug) as drug,
        trim(gsn) as gsn,
        trim(ndc) as ndc,
        trim(prod_strength) as prod_strength,
        trim(form_rx) as form_rx,
        trim(dose_val_rx) as dose_val_rx,
        trim(dose_unit_rx) as dose_unit_rx,
        trim(form_val_disp) as form_val_disp,
        trim(form_unit_disp) as form_unit_disp,
        doses_per_24_hrs,
        upper(trim(route)) as route,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
