-- Staging-Modell für die Smart-Meter-Zeitreihen.
-- Die 1.298 Messwertdateien (eine je Household_ID) werden über das Macro
-- get_meter_reading_seed_names() automatisch erkannt und mittels
-- dbt_utils.union_relations() zu einer einzigen Tabelle zusammengeführt.
-- Voraussetzung: Paket dbt-labs/dbt_utils (siehe packages.yml).

{% set meter_seed_names = get_meter_reading_seed_names() %}

{% set relations = [] %}
{% for seed_name in meter_seed_names %}
    {% do relations.append(ref(seed_name)) %}
{% endfor %}

with unioned as (

    {{ dbt_utils.union_relations(relations=relations) }}

),

renamed as (

    select
        cast(Household_ID as String)                as household_id,
        `Group`                                      as household_group,
        AffectsTimePoint                              as affects_time_point,
        toDateTime(Timestamp)                         as reading_timestamp,
        toDate(Timestamp)                             as reading_date,
        kWh_received_Total                            as kwh_received_total,
        kWh_received_HeatPump                         as kwh_received_heatpump,
        kWh_received_Other                            as kwh_received_other,
        kWh_returned_Total                            as kwh_returned_total,
        kvarh_received_capacitive_Total               as kvarh_received_capacitive_total,
        kvarh_received_capacitive_HeatPump            as kvarh_received_capacitive_heatpump,
        kvarh_received_capacitive_Other               as kvarh_received_capacitive_other,
        kvarh_received_inductive_Total                as kvarh_received_inductive_total,
        kvarh_received_inductive_HeatPump             as kvarh_received_inductive_heatpump,
        kvarh_received_inductive_Other                as kvarh_received_inductive_other

    from unioned

)

select * from renamed
