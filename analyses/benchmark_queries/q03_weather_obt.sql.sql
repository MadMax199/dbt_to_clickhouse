-- Q03: Stromverbrauch in Abhängigkeit von Heizgradtagen
-- Benchmark: One Big Table
-- Join-Komplexität: keine

SELECT
    round(heating_degree_sia_daily, 0) AS heating_degree_days,
    avg(kwh_received_total) AS avg_kwh_received
FROM obt_smart_meter_readings
WHERE heating_degree_sia_daily IS NOT NULL
GROUP BY heating_degree_days
ORDER BY heating_degree_days;