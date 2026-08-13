-- Staging-Modell für die Haushalts-Stammdaten (households.csv)
-- Wandelt die Python-Style "True"/"False"-Strings der Flags in UInt8 um
-- und benennt 'Group' um, da es ein reserviertes Schlüsselwort in ClickHouse ist (GROUP BY).

with source as (

    select * from {{ ref('households') }}

),

renamed as (

    select
        cast(Household_ID as String)               as household_id,
        `Group`                                     as household_group,
        Weather_ID                                  as weather_id,
        Protocols_ReportIDs                         as protocol_report_ids,

        case
            when Installation_HasPVSystem = 'True' then 1
            when Installation_HasPVSystem = 'False' then 0
            else null
        end                                          as has_pv_system,

        case
            when Protocols_Available = 'True' then 1
            when Protocols_Available = 'False' then 0
            else null
        end                                          as has_protocols,

        case
            when Protocols_HasMultipleVisits = 'True' then 1
            when Protocols_HasMultipleVisits = 'False' then 0
            else null
        end                                          as has_multiple_protocol_visits,

        case
            when MetaData_Available = 'True' then 1
            when MetaData_Available = 'False' then 0
            else null
        end                                          as has_metadata,

        case
            when SmartMeterData_Available_15min = 'True' then 1
            when SmartMeterData_Available_15min = 'False' then 0
            else null
        end                                          as has_smartmeter_15min,

        case
            when SmartMeterData_Available_Daily = 'True' then 1
            when SmartMeterData_Available_Daily = 'False' then 0
            else null
        end                                          as has_smartmeter_daily,

        case
            when SmartMeterData_Available_Monthly = 'True' then 1
            when SmartMeterData_Available_Monthly = 'False' then 0
            else null
        end                                          as has_smartmeter_monthly

    from source

)

select * from renamed
