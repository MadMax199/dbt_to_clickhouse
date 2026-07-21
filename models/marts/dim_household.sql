-- Dimensionstabelle: Haushalt
-- Dünner Durchreicher von stg_households, da die eigentliche Bereinigung
-- (Typ-Casts, Umbenennung von "Group") bereits im Staging-Layer passiert ist.

select
    household_id,
    household_group,
    weather_id,
    protocol_report_ids,
    has_pv_system,
    has_protocols,
    has_multiple_protocol_visits,
    has_metadata,
    has_smartmeter_15min,
    has_smartmeter_daily,
    has_smartmeter_monthly
from {{ ref('stg_households') }}