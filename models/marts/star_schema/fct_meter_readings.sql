-- Faktentabelle: Smart-Meter-Zeitreihen
-- Granularität (= ein Datensatz entspricht): ein Haushalt zu einem Zeitstempel.
-- Enthält den Fremdschlüssel zu dim_household (household_id) sowie
-- weather_id (über dim_household nachgeschlagen), plus die Messwerte.
--
-- dim_protocol bewusst NICHT als Fremdschlüssel enthalten (siehe Erklärung
-- oben) - Protokoll-Zuordnung erfolgt bei Bedarf per ASOF JOIN zur Abfragezeit.

select
    m.household_id,
    m.reading_timestamp,
    m.reading_date,
    m.household_group,
    m.affects_time_point,
    h.weather_id,
    m.kwh_received_total,
    m.kwh_received_heatpump,
    m.kwh_received_other,
    m.kwh_returned_total,
    m.kvarh_received_capacitive_total,
    m.kvarh_received_capacitive_heatpump,
    m.kvarh_received_capacitive_other,
    m.kvarh_received_inductive_total,
    m.kvarh_received_inductive_heatpump,
    m.kvarh_received_inductive_other
from {{ ref('stg_meter_readings') }} as m
left join {{ ref('dim_household') }} as h
    on m.household_id = h.household_id