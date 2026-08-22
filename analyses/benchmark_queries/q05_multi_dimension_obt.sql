-- Q05: Monatlicher Wärmepumpenverbrauch nach PV-Status
-- unter kalten Wetterbedingungen und mit gültigem Audit
-- Benchmark: One Big Table
-- Join-Komplexität: keine

SELECT
    toStartOfMonth(reading_date) AS month,
    has_pv_system,
    avg(kwh_received_heatpump) AS avg_heatpump_consumption
FROM obt_smart_meter_readings
WHERE
    heating_degree_sia_daily > 10
    AND visit_date IS NOT NULL
GROUP BY
    month,
    has_pv_system
ORDER BY
    month,
    has_pv_system;