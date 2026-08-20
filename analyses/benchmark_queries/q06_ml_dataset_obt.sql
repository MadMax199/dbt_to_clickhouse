-- Q06: Erstellung eines täglichen ML-Basisdatensatzes
-- Benchmark: One Big Table
-- Alle benötigten Attribute bereits denormalisiert

SELECT
    household_id,
    reading_date AS date,

    -- Target / Verbrauch
    sum(kwh_received_total) AS kwh_received_total,
    sum(kwh_returned_total) AS kwh_returned_total,
    sum(kwh_received_heatpump) AS kwh_received_heatpump,

    -- Haushaltsinformationen
    household_group,
    has_pv_system,

    -- Wetter
    avg(temperature_avg_daily) AS temperature_avg_daily,
    avg(temperature_min_daily) AS temperature_min_daily,
    avg(temperature_max_daily) AS temperature_max_daily,
    avg(heating_degree_sia_daily) AS heating_degree_sia_daily,
    avg(sunshine_duration_daily) AS sunshine_duration_daily,

    -- Gebäude / Audit
    report_id,
    visit_date,
    building_type,
    building_floorareaheated_total,
    building_residents,
    building_renovated_windows,
    building_renovated_roof,
    building_renovated_walls,
    building_renovated_floor,
    building_pvsystem_size

FROM obt_smart_meter_readings

GROUP BY
    household_id,
    reading_date,
    household_group,
    has_pv_system,
    report_id,
    visit_date,
    building_type,
    building_floorareaheated_total,
    building_residents,
    building_renovated_windows,
    building_renovated_roof,
    building_renovated_walls,
    building_renovated_floor,
    building_pvsystem_size

ORDER BY
    household_id,
    reading_date;