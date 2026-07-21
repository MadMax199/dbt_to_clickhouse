-- Staging-Modell für die Wetterstationsdaten.
-- Da es nur 8 Wetterstationen gibt (im Gegensatz zu den 1.298 Messwertdateien),
-- wird die Union hier bewusst explizit statt dynamisch aufgebaut - das bleibt lesbar
-- und muss sich nicht ändern, solange keine neue Wetterstation hinzukommt.

with hg as (select * from {{ ref('Hg') }}),
     mqo as (select * from {{ ref('MqO') }}),
     ceoxs as (select * from {{ ref('ceOxS') }}),
     sv3mr as (select * from {{ ref('sV3mR') }}),
     wdd as (select * from {{ ref('wDD') }}),
     z6i as (select * from {{ ref('z6I') }}),
     jb8 as (select * from {{ ref('8jB') }}),
     hbsbg as (select * from {{ ref('HbsbG') }}),

unioned as (

    select * from hg
    union all
    select * from mqo
    union all
    select * from ceoxs
    union all
    select * from sv3mr
    union all
    select * from wdd
    union all
    select * from z6i
    union all
    select * from jb8
    union all
    select * from hbsbg

),

renamed as (

    select
        Weather_ID                          as weather_id,
        toDate(Timestamp)                   as weather_date,
        Temperature_max_daily                as temperature_max_daily,
        Temperature_min_daily                as temperature_min_daily,
        Temperature_avg_daily                as temperature_avg_daily,
        HeatingDegree_SIA_daily              as heating_degree_sia_daily,
        HeatingDegree_US_daily               as heating_degree_us_daily,
        CoolingDegree_US_daily               as cooling_degree_us_daily,
        Humidity_avg_daily                   as humidity_avg_daily,
        Precipitation_total_daily            as precipitation_total_daily,
        Sunshine_duration_daily              as sunshine_duration_daily

    from unioned

)

select * from renamed
