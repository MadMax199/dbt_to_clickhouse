select
    household_id,
    household_group,
    affects_time_point,
    reading_timestamp,
    reading_date,
    kwh_received_total,
    kwh_received_heatpump,
    kwh_received_other,
    kwh_returned_total,
    kvarh_received_capacitive_total,
    kvarh_received_capacitive_heatpump,
    kvarh_received_capacitive_other,
    kvarh_received_inductive_total,
    kvarh_received_inductive_heatpump,
    kvarh_received_inductive_other
from {{ ref('stg_meter_readings') }} as meter
left join {{ ref('stg_households') }} as households on meter.household_id = household.household_id
left join {{ ref('stg_weather') }} as weather on weather.weather_id = household.weather_id AND weather.weather_date = meter.reading_date
left join {{ ref('stg_protocols') }} as protocols on protocols.household_id  = household.household_id  AND protocols.visit_date  <= meter.reading_timestamp
