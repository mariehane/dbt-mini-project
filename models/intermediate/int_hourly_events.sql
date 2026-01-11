{{
    config(
        materialized='table'
    )
}}

/*
    Hourly aggregation of all clinical events from multiple sources.
    
    This model unions events from:
    - chartevents (vital signs, observations)
    - labevents (laboratory results)
    - inputevents (fluid/medication inputs - tracks both amount and rate)
    - outputevents (output measurements)
    - procedureevents (ICU procedures)
    - prescriptions (medication prescriptions by GSN code)
    - antibiotics (sepsis-relevant antibiotic prescriptions)
    - microbiologyevents (microbiology samples)
    
    Output is in LONG format with one row per (hadm_id, hour, source, itemid).
    
    Aggregation logic:
    - value_mean: AVG of values (for rates, vital signs, lab values)
    - value_sum: SUM of values (for amounts, volumes)
    
    Hour is calculated as dense rank of charttime within each hadm_id,
    representing hours with data only (no gap-filling).
*/

with 
-- =============================================================================
-- SOURCE DATA: Union all event sources with normalized columns
-- =============================================================================

chartevents as (
    select
        hadm_id,
        charttime,
        'chartevents' as source,
        itemid::varchar as itemid,
        valuenum::float as value_for_mean,
        null::float as value_for_sum
    from {{ ref('stg_icu__chartevents') }}
    where hadm_id is not null
      and charttime is not null
      and valuenum is not null
),

labevents as (
    select
        hadm_id,
        charttime,
        'labevents' as source,
        itemid::varchar as itemid,
        valuenum::float as value_for_mean,
        null::float as value_for_sum
    from {{ ref('stg_hosp__labevents') }}
    where hadm_id is not null
      and charttime is not null
      and valuenum is not null
),

inputevents as (
    select
        hadm_id,
        starttime as charttime,
        'inputevents' as source,
        itemid::varchar as itemid,
        rate::float as value_for_mean,  -- rate is averaged
        amount::float as value_for_sum   -- amount is summed
    from {{ ref('stg_icu__inputevents') }}
    where hadm_id is not null
      and starttime is not null
      and (amount is not null or rate is not null)
),

outputevents as (
    select
        hadm_id,
        charttime,
        'outputevents' as source,
        itemid::varchar as itemid,
        null::float as value_for_mean,
        value::float as value_for_sum  -- output value is summed
    from {{ ref('stg_icu__outputevents') }}
    where hadm_id is not null
      and charttime is not null
      and value is not null
),

procedureevents as (
    select
        hadm_id,
        starttime as charttime,
        'procedureevents' as source,
        itemid::varchar as itemid,
        null::float as value_for_mean,
        value::float as value_for_sum  -- procedure value is summed
    from {{ ref('stg_icu__procedureevents') }}
    where hadm_id is not null
      and starttime is not null
      and value is not null
),

-- Prescriptions: use GSN code as itemid, padded to 6 digits for consistency with item_map
prescriptions as (
    select
        hadm_id,
        starttime as charttime,
        'prescriptions' as source,
        lpad(gsn::varchar, 6, '0') as itemid,  -- pad GSN to match item_map format
        1.0::float as value_for_mean,  -- binary presence indicator
        null::float as value_for_sum
    from {{ ref('stg_hosp__prescriptions') }}
    where hadm_id is not null
      and starttime is not null
      and gsn is not null
),

-- Antibiotics: synthetic itemid for any sepsis-relevant antibiotic
antibiotics as (
    select
        hadm_id,
        charttime,
        'antibiotics' as source,
        'antibiotics' as itemid,  -- synthetic itemid
        1.0::float as value_for_mean,  -- binary presence indicator
        null::float as value_for_sum
    from {{ ref('int_antibiotics') }}
    where hadm_id is not null
      and charttime is not null
),

-- Microbiology: synthetic itemid for any microbiology sample
microbiologyevents as (
    select
        hadm_id,
        coalesce(charttime, chartdate::timestamp_ntz) as charttime,
        'microbiology' as source,
        'microbio_sample' as itemid,  -- synthetic itemid
        1.0::float as value_for_mean,  -- binary presence indicator
        null::float as value_for_sum
    from {{ ref('stg_hosp__microbiologyevents') }}
    where hadm_id is not null
      and (charttime is not null or chartdate is not null)
),

-- =============================================================================
-- UNION ALL SOURCES
-- =============================================================================

events_union as (
    select * from chartevents
    union all
    select * from labevents
    union all
    select * from inputevents
    union all
    select * from outputevents
    union all
    select * from procedureevents
    union all
    select * from prescriptions
    union all
    select * from antibiotics
    union all
    select * from microbiologyevents
),

-- =============================================================================
-- HOURLY AGGREGATION
-- =============================================================================

hourly_aggregated as (
    select
        hadm_id,
        date_trunc('hour', charttime) as charttime,
        source,
        itemid,
        avg(value_for_mean) as value_mean,
        sum(value_for_sum) as value_sum,
        count(*) as record_count
    from events_union
    group by
        hadm_id,
        date_trunc('hour', charttime),
        source,
        itemid
),

-- =============================================================================
-- ADD HOUR RANK
-- =============================================================================

with_hour_rank as (
    select
        hadm_id,
        charttime,
        dense_rank() over (
            partition by hadm_id 
            order by charttime
        ) as hour,
        source,
        itemid,
        value_mean,
        value_sum,
        record_count
    from hourly_aggregated
)

select
    hadm_id,
    charttime,
    hour,
    source,
    itemid,
    value_mean,
    value_sum,
    record_count
from with_hour_rank
