with source as (
    select * from {{ source('mimiciv_icu', 'inputevents') }}
),

cleaned as (
    select
        -- Foreign keys
        subject_id::integer as subject_id,
        hadm_id::integer as hadm_id,
        stay_id::integer as stay_id,
        itemid::integer as itemid,
        orderid::integer as orderid,
        linkorderid::integer as linkorderid,
        
        -- Timestamps
        starttime::timestamp_ntz as starttime,
        endtime::timestamp_ntz as endtime,
        storetime::timestamp_ntz as storetime,
        
        -- Amounts
        amount,
        trim(amountuom) as amountuom,
        rate,
        trim(rateuom) as rateuom,
        totalamount,
        trim(totalamountuom) as totalamountuom,
        originalamount,
        originalrate,
        
        -- Order details
        trim(ordercategoryname) as ordercategoryname,
        trim(secondaryordercategoryname) as secondaryordercategoryname,
        trim(ordercomponenttypedescription) as ordercomponenttypedescription,
        trim(ordercategorydescription) as ordercategorydescription,
        
        -- Patient info
        patientweight,
        
        -- Flags
        isopenbag::integer as isopenbag,
        continueinnextdept::integer as continueinnextdept,
        trim(cancelreason) as cancelreason,
        trim(statusdescription) as statusdescription,
        
        -- Metadata
        current_timestamp() as _loaded_at
        
    from source
)

select * from cleaned
