-- Q02: Durchschnittlicher Stromverbrauch nach PV-Status
-- Benchmark: One Big Table
-- Join-Komplexität: keine

SELECT
    has_pv_system,
    avg(kwh_received_total) AS avg_kwh_received
FROM obt_smart_meter_readings
GROUP BY has_pv_system
ORDER BY has_pv_system;