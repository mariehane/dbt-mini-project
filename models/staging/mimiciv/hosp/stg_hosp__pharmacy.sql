with source as (
    select * from {{ source('mimiciv_hosp', 'pharmacy') }}
),

cleaned as (
    select
        -- Primary/Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        pharmacy_id::integer as pharmacy_id,
        poe_id::varchar as poe_id,
        
        -- Timestamps
        starttime::timestamp_ntz as starttime,
        stoptime::timestamp_ntz as stoptime,
        entertime::timestamp_ntz as entertime,
        verifiedtime::timestamp_ntz as verifiedtime,
        expirationdate::timestamp_ntz as expirationdate,
        
        -- Medication details
        trim(medication) as medication,
        upper(trim(proc_type)) as proc_type,
        upper(trim(status)) as status,
        upper(trim(route)) as route,
        trim(frequency) as frequency,
        trim(disp_sched) as disp_sched,
        trim(infusion_type) as infusion_type,
        trim(sliding_scale) as sliding_scale,
        trim(lockout_interval) as lockout_interval,
        trim(basal_rate) as basal_rate,
        trim(one_hr_max) as one_hr_max,
        doses_per_24_hrs,
        duration,
        trim(duration_interval) as duration_interval,
        expiration_value,
        trim(expiration_unit) as expiration_unit,
        trim(dispensation) as dispensation,
        trim(fill_quantity) as fill_quantity,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
