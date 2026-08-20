-- Q01: Monatlicher durchschnittlicher Stromverbrauch
-- Benchmark: One Big Table
-- Join-Komplexität: keine

SELECT
    toStartOfMonth(reading_date) AS month,
    avg(kwh_received_total) AS avg_kwh_received
FROM obt_smart_meter_readings
GROUP BY month
ORDER BY month;