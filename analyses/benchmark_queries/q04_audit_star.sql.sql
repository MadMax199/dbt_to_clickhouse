-- Q04: Durchschnittlicher Wärmepumpenverbrauch nach Auditjahr
-- Benchmark: Star Schema
-- Join-Komplexität: zeitabhängiger ASOF JOIN

SELECT
    p.visit_year,
    avg(f.kwh_received_heatpump) AS avg_heatpump_consumption
FROM fct_meter_readings AS f
ASOF LEFT JOIN dim_protocol AS p
    ON p.household_id = f.household_id
    AND p.visit_date <= f.reading_timestamp
WHERE p.visit_date IS NOT NULL
  AND p.visit_year IS NOT NULL
GROUP BY p.visit_year
ORDER BY p.visit_year;