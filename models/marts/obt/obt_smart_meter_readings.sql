select
   meter.*,
   households.*,
   weather.*,
   protocols.report_id,
   protocols.household_id,
   protocols.visit_year,
   protocols.visit_date,
   protocols.Building_Type,
   protocols.Building_FloorAreaHeated_Total,
   protocols.Building_Residents,
   protocols.Building_Renovated_Windows,
   protocols.Building_Renovated_Roof,
   protocols.Building_Renovated_Walls,
   protocols.Building_Renovated_Floor,
   protocols.Building_PVSystem_Size
from {{ ref('stg_meter_readings') }} as meter
left join {{ ref('stg_households') }} as households on meter.household_id = households.household_id
left join {{ ref('stg_weather') }} as weather on weather.weather_id = households.weather_id AND weather.weather_date = meter.reading_date
ASOF LEFT JOIN {{ ref('stg_protocols') }} AS protocols
    ON protocols.household_id = meter.household_id
    AND protocols.visit_date <= meter.reading_timestamp