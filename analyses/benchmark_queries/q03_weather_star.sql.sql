-- Q03: Stromverbrauch in Abhängigkeit von Heizgradtagen
-- Benchmark: Star Schema
-- Join-Komplexität: 1 Join über zusammengesetzten Schlüssel

SELECT
    round(w.heating_degree_sia_daily, 0) AS heating_degree_days,
    avg(f.kwh_received_total) AS avg_kwh_received
FROM fct_meter_readings AS f
INNER JOIN dim_weather AS w
    ON f.weather_id = w.weather_id
    AND f.reading_date = w.weather_date
WHERE w.heating_degree_sia_daily IS NOT NULL
GROUP BY heating_degree_days
ORDER BY heating_degree_days;
