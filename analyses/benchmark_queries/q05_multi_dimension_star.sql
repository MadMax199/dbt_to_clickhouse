-- Q05: Monatlicher Wärmepumpenverbrauch nach PV-Status
-- unter kalten Wetterbedingungen und mit gültigem Audit
-- Benchmark: Star Schema
-- Join-Komplexität: Household + Weather + ASOF Protocol

SELECT
    toStartOfMonth(f.reading_date) AS month,
    h.has_pv_system,
    avg(f.kwh_received_heatpump) AS avg_heatpump_consumption
FROM fct_meter_readings AS f

INNER JOIN dim_household AS h
    ON f.household_id = h.household_id

INNER JOIN dim_weather AS w
    ON f.weather_id = w.weather_id
    AND f.reading_date = w.weather_date

ASOF LEFT JOIN dim_protocol AS p
    ON p.household_id = f.household_id
    AND p.visit_date <= f.reading_timestamp

WHERE
    w.heating_degree_sia_daily > 10
    AND p.visit_date IS NOT NULL

GROUP BY
    month,
    h.has_pv_system

ORDER BY
    month,
    h.has_pv_system;