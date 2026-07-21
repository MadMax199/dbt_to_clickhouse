-- Staging-Modell für die Auditprotokolle (protocols.csv, 106 Spalten)
-- Report_ID, Household_ID, Visit_Year und Visit_Date wurden in der dbt_project.yml
-- als String erzwungen (unsaubere Rohwerte) und werden hier sicher in Zieltypen überführt.
-- Alle übrigen ~100 Gebäude-/Anlagenattribute werden unverändert durchgereicht,
-- da ihre Aufteilung in einzelne, fachliche Bereiche erst im Mart-Layer (dim_protocol) erfolgt.

with source as (

    select * from {{ ref('protocols') }}

),

renamed as (

    select
        cast(Report_ID as String)              as report_id,
        cast(Household_ID as String)           as household_id,
        toUInt16OrNull(Visit_Year)             as visit_year,
        toDateOrNull(Visit_Date)               as visit_date,

        -- restliche ~102 Gebäude-, Wärmepumpen- und Heizsystem-Attribute unverändert übernehmen
        * except (Report_ID, Household_ID, Visit_Year, Visit_Date)

    from source

)

select * from renamed
