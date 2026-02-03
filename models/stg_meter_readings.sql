
{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by=['timestamp', 'household_id']
) }}

WITH unioned_data AS (
    SELECT 
        *,
        _table AS source_file
    FROM merge('default', '^[0-9]+$')
)

SELECT
    -- parseDateTimeBestEffort erkennt das Format mit +00:00 automatisch
    parseDateTimeBestEffort(toString("Timestamp")) AS timestamp,
    
    source_file AS household_id,
    "Group" AS group_assignment,
    "AffectsTimePoint" AS affects_timepoint,
    
    -- Bleib bei der toString -> toFloat64OrZero Kette für die Stabilität
    toFloat64OrZero(toString("kWh_received_Total")) AS kwh_received_total,
    toFloat64OrZero(toString("kWh_received_HeatPump")) AS kwh_received_heatpump,
    toFloat64OrZero(toString("kWh_received_Other")) AS kwh_received_other,
    toFloat64OrZero(toString("kWh_returned_Total")) AS kwh_returned_total

FROM unioned_data
-- Filtert Header-Zeilen oder leere Zeilen aus, falls sie im Merge landen
WHERE "Timestamp" != '' 
  AND "Timestamp" IS NOT NULL 
  AND "Timestamp" != 'Timestamp'