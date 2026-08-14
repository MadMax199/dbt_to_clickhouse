-- Dimensionstabelle: Wetter

select
    weather_id,
    weather_date,
    temperature_max_daily,
    temperature_min_daily,
    temperature_avg_daily,
    heating_degree_sia_daily,
    heating_degree_us_daily,
    cooling_degree_us_daily,
    humidity_avg_daily,
    precipitation_total_daily,
    sunshine_duration_daily
from {{ ref('stg_weather') }}
