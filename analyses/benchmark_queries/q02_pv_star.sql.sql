-- Q02: Durchschnittlicher Stromverbrauch nach PV-Status
-- Benchmark: Star Schema
-- Join-Komplexität: 1 Join

SELECT
    h.has_pv_system,
    avg(f.kwh_received_total) AS avg_kwh_received
FROM fct_meter_readings AS f
INNER JOIN dim_household AS h
    ON f.household_id = h.household_id
GROUP BY h.has_pv_system
ORDER BY h.has_pv_system;