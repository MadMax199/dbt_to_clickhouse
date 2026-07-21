-- Staging-Modell für die Smart-Meter-Zeitreihen.
-- Die 1.298 Messwertdateien (eine je Household_ID) tragen als Tabellennamen
-- ausschließlich Ziffern (z.B. "100101", "7069411").
--
-- Ursprünglich wurden diese über ein Macro (get_meter_reading_seed_names) und
-- dbt_utils.union_relations() dynamisch per UNION ALL zusammengeführt. Das
-- erzeugt bei 1.298 Tabellen jedoch eine SQL-Anweisung von mehreren hundert
-- Kilobyte Text, was ClickHouse's max_query_size-Limit (Standard: 256 KB)
-- überschreitet (Fehler: "Max query size exceeded").
--
-- Lösung: ClickHouse's native merge()-Tabellenfunktion. Sie liest alle
-- Tabellen im angegebenen Schema, deren Name auf ein Regex-Muster passt,
-- "virtuell" als eine einzige Relation - ohne eine lange UNION-ALL-Textkette
-- zu erzeugen. Das Regex '^[0-9]+$' trifft ausschließlich auf die 1.298
-- Messwertdateien, nicht auf households/protocols/die Wetterstationen.
--
-- Timestamp-Handling: Die Rohwerte enthalten ein Zeitzonen-Suffix
-- (z.B. "2021-04-08 23:59:59+00:00"). toDate() direkt auf den String
-- angewendet scheitert daran ("Cannot parse string ... as Date"), da
-- nach dem Datum noch Zeit/Zeitzone folgen. Daher wird zuerst einmalig
-- zu DateTime geparst (das funktioniert mit dem Suffix), und reading_date
-- wird aus diesem bereits geparsten DateTime abgeleitet (reine Kürzung,
-- kein erneutes String-Parsing).

with parsed as (

    select
        *,
        toDateTime(Timestamp) as parsed_timestamp
    from merge('{{ target.schema }}', '^[0-9]+$')

)

select
    cast(Household_ID as String)                as household_id,
    `Group`                                      as household_group,
    AffectsTimePoint                              as affects_time_point,
    parsed_timestamp                              as reading_timestamp,
    toDate(parsed_timestamp)                      as reading_date,
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

from parsed
