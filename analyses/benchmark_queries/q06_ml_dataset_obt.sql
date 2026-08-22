-- Q06: Erstellung eines täglichen ML-Basisdatensatzes
-- Benchmark: One Big Table
-- Alle benötigten Attribute bereits denormalisiert

SELECT
    `meter.household_id` AS household_id,
    reading_date AS date,

    -- Verbrauch
    sum(kwh_received_total) AS kwh_received_total,
    sum(kwh_returned_total) AS kwh_returned_total,
    sum(kwh_received_heatpump) AS kwh_received_heatpump,

    -- Haushalt
    `meter.household_group` AS household_group,
    has_pv_system,

    -- Wetter
    avg(temperature_avg_daily) AS temperature_avg_daily,
    avg(temperature_min_daily) AS temperature_min_daily,
    avg(temperature_max_daily) AS temperature_max_daily,
    avg(heating_degree_sia_daily) AS heating_degree_sia_daily,
    avg(sunshine_duration_daily) AS sunshine_duration_daily,

    -- Audit / Gebäude
    report_id,
    visit_date,
    Building_Type,
    Building_FloorAreaHeated_Total,
    Building_Residents,
    Building_Renovated_Windows,
    Building_Renovated_Roof,
    Building_Renovated_Walls,
    Building_Renovated_Floor,
    Building_PVSystem_Size

FROM obt_smart_meter_readings

GROUP BY
    `meter.household_id`,
    reading_date,
    `meter.household_group`,
    has_pv_system,
    report_id,
    visit_date,
    Building_Type,
    Building_FloorAreaHeated_Total,
    Building_Residents,
    Building_Renovated_Windows,
    Building_Renovated_Roof,
    Building_Renovated_Walls,
    Building_Renovated_Floor,
    Building_PVSystem_Size

ORDER BY
    household_id,
    date;