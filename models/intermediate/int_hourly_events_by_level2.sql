{{
    config(
        materialized='table'
    )
}}

/*
    Hourly events aggregated by LEVEL2 concept from item_map seeds.
    
    This model joins int_hourly_events with all item_map seeds and aggregates
    by LEVEL2 (the standardized concept name like 'heart_rate', 'creatinine').
    
    Multiple itemids that map to the same LEVEL2 are combined:
    - value_mean: AVG of the hourly means (average of averages)
    - value_sum: SUM of the hourly sums
    
    Only includes:
    - itemids that appear in at least one item_map seed
    - Event-related origins (excludes 'static' and 'diagnoses_icd')
    - Special synthetic itemids: 'antibiotics', 'microbio_sample'
    
    Output is in LONG format with one row per (hadm_id, hour, source, level2).
*/

with 
-- =============================================================================
-- UNION ALL ITEM MAPS
-- =============================================================================

-- Combine all item maps into a single reference table
item_map_chartevents as (
    select
        itemid::varchar as itemid,
        origin,
        label,
        level2
    from {{ ref('item_map_chartevents') }}
    where origin is not null
      and level2 is not null
),

item_map_epic as (
    select
        itemid::varchar as itemid,
        origin,
        label,
        level2
    from {{ ref('item_map_epic') }}
    where origin is not null
      and level2 is not null
),

item_map_dascena as (
    select
        itemid::varchar as itemid,
        origin,
        label,
        level2
    from {{ ref('item_map_dascena_epic') }}
    where origin is not null
      and level2 is not null
),

-- Union and deduplicate (same itemid might appear in multiple maps)
item_map_union as (
    select distinct
        itemid,
        origin,
        label,
        level2
    from (
        select * from item_map_chartevents
        union all
        select * from item_map_epic
        union all
        select * from item_map_dascena
    )
    -- Filter to event-related origins only (exclude static features and diagnoses)
    where origin not in ('static', 'diagnoses_icd')
),

-- Add special synthetic itemids with their LEVEL2 mappings
special_items as (
    select 'antibiotics' as itemid, 'antibiotics' as origin, 'antibiotics' as label, 'antibiotics' as level2
    union all
    select 'microbio_sample' as itemid, 'microbiology' as origin, 'microbio_sample' as label, 'microbio_sample' as level2
),

-- Combine regular item map with special items
all_item_mappings as (
    select itemid, origin, label, level2 from item_map_union
    union all
    select itemid, origin, label, level2 from special_items
),

-- =============================================================================
-- JOIN HOURLY EVENTS WITH ITEM MAP
-- =============================================================================

hourly_events as (
    select * from {{ ref('int_hourly_events') }}
),

events_with_level2 as (
    select
        e.hadm_id,
        e.charttime,
        e.hour,
        e.source,
        e.itemid,
        m.level2,
        e.value_mean,
        e.value_sum,
        e.record_count
    from hourly_events e
    inner join all_item_mappings m
        on e.itemid = m.itemid
),

-- =============================================================================
-- AGGREGATE BY LEVEL2
-- =============================================================================

aggregated_by_level2 as (
    select
        hadm_id,
        charttime,
        -- Use MIN(hour) since all rows for same hadm_id+charttime have same hour
        min(hour) as hour,
        source,
        level2,
        -- Average of the hourly means for items mapping to same LEVEL2
        avg(value_mean) as value_mean,
        -- Sum of the hourly sums for items mapping to same LEVEL2
        sum(value_sum) as value_sum,
        -- Total record count across all items
        sum(record_count) as record_count
    from events_with_level2
    group by
        hadm_id,
        charttime,
        source,
        level2
)

select
    hadm_id,
    charttime,
    hour,
    source,
    level2,
    value_mean,
    value_sum,
    record_count
from aggregated_by_level2
