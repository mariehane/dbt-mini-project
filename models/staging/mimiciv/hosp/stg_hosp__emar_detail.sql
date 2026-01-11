with source as (
    select * from {{ source('mimiciv_hosp', 'emar_detail') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        emar_id::varchar as emar_id,
        emar_seq::integer as emar_seq,
        parent_field_ordinal::integer as parent_field_ordinal,
        pharmacy_id::integer as pharmacy_id,
        
        -- Administration details
        trim(administration_type) as administration_type,
        trim(barcode_type) as barcode_type,
        trim(reason_for_no_barcode) as reason_for_no_barcode,
        trim(complete_dose_not_given) as complete_dose_not_given,
        trim(dose_due) as dose_due,
        trim(dose_due_unit) as dose_due_unit,
        trim(dose_given) as dose_given,
        trim(dose_given_unit) as dose_given_unit,
        trim(will_remainder_of_dose_be_given) as will_remainder_of_dose_be_given,
        trim(product_amount_given) as product_amount_given,
        trim(product_unit) as product_unit,
        trim(product_code) as product_code,
        trim(product_description) as product_description,
        trim(product_description_other) as product_description_other,
        trim(prior_infusion_rate) as prior_infusion_rate,
        trim(infusion_rate) as infusion_rate,
        trim(infusion_rate_adjustment) as infusion_rate_adjustment,
        trim(infusion_rate_adjustment_amount) as infusion_rate_adjustment_amount,
        trim(infusion_rate_unit) as infusion_rate_unit,
        upper(trim(route)) as route,
        trim(infusion_complete) as infusion_complete,
        trim(completion_interval) as completion_interval,
        trim(new_iv_bag_hung) as new_iv_bag_hung,
        trim(continued_infusion_in_other_location) as continued_infusion_in_other_location,
        trim(restart_interval) as restart_interval,
        trim(side) as side,
        trim(site) as site,
        trim(non_formulary_visual_verification) as non_formulary_visual_verification,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
