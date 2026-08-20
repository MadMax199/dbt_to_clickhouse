-- Q04: Durchschnittlicher Wärmepumpenverbrauch nach Auditjahr
-- Benchmark: One Big Table
-- Join-Komplexität: keine

SELECT
    visit_year,
    avg(kwh_received_heatpump) AS avg_heatpump_consumption
FROM obt_smart_meter_readings
WHERE report_id IS NOT NULL
GROUP BY visit_year
ORDER BY visit_year;