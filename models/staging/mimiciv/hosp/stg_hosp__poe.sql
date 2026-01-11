with source as (
    select * from {{ source('mimiciv_hosp', 'poe') }}
),

cleaned as (
    select
        -- Primary/Foreign keys
        poe_id::varchar as poe_id,
        poe_seq::integer as poe_seq,
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        
        -- Order details
        ordertime::timestamp_ntz as ordertime,
        upper(trim(order_type)) as order_type,
        trim(order_subtype) as order_subtype,
        upper(trim(transaction_type)) as transaction_type,
        discontinue_of_poe_id::varchar as discontinue_of_poe_id,
        discontinued_by_poe_id::varchar as discontinued_by_poe_id,
        upper(trim(order_status)) as order_status,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
