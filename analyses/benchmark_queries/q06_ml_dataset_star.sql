-- Q06: Erstellung eines täglichen ML-Basisdatensatzes
-- Benchmark: Star Schema
-- Benötigt Household-, Weather- und Protocol-Dimension

SELECT
    f.household_id,
    f.reading_date AS date,

    sum(f.kwh_received_total) AS kwh_received_total,
    sum(f.kwh_returned_total) AS kwh_returned_total,
    sum(f.kwh_received_heatpump) AS kwh_received_heatpump,

    h.household_group,
    h.has_pv_system,

    avg(w.temperature_avg_daily) AS temperature_avg_daily,
    avg(w.temperature_min_daily) AS temperature_min_daily,
    avg(w.temperature_max_daily) AS temperature_max_daily,
    avg(w.heating_degree_sia_daily) AS heating_degree_sia_daily,
    avg(w.sunshine_duration_daily) AS sunshine_duration_daily,

    p.report_id,
    p.visit_date,
    p.Building_Type,
    p.Building_FloorAreaHeated_Total,
    p.Building_Residents,
    p.Building_Renovated_Windows,
    p.Building_Renovated_Roof,
    p.Building_Renovated_Walls,
    p.Building_Renovated_Floor,
    p.Building_PVSystem_Size

FROM fct_meter_readings AS f

LEFT JOIN dim_household AS h
    ON f.household_id = h.household_id

LEFT JOIN dim_weather AS w
    ON f.weather_id = w.weather_id
    AND f.reading_date = w.weather_date

ASOF LEFT JOIN dim_protocol AS p
    ON p.household_id = f.household_id
    AND p.visit_date <= f.reading_timestamp

GROUP BY
    f.household_id,
    f.reading_date,
    h.household_group,
    h.has_pv_system,
    p.report_id,
    p.visit_date,
    p.Building_Type,
    p.Building_FloorAreaHeated_Total,
    p.Building_Residents,
    p.Building_Renovated_Windows,
    p.Building_Renovated_Roof,
    p.Building_Renovated_Walls,
    p.Building_Renovated_Floor,
    p.Building_PVSystem_Size

ORDER BY
    f.household_id,
    f.reading_date;