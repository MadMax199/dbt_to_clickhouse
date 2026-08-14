select
   meter.*,
   households.*,
   weather.*,
   protocols.*
from {{ ref('stg_meter_readings') }} as meter
left join {{ ref('stg_households') }} as households on meter.household_id = households.household_id
left join {{ ref('stg_weather') }} as weather on weather.weather_id = households.weather_id AND weather.weather_date = meter.reading_date
ASOF LEFT JOIN {{ ref('stg_protocols') }} AS protocols
    ON protocols.household_id = meter.household_id
    AND protocols.visit_date <= meter.reading_timestamp