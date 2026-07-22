-- Dimensionstabelle: Protokoll (Vor-Ort-Begehungen)
-- Enthält die ~102 Gebäude-, Wärmepumpen- und Heizsystem-Attribute.
-- Bewusst als EINE breite Dimension (Star Schema), nicht wie beim
-- Snowflake-Ansatz in mehrere fachliche Sub-Tabellen aufgeteilt.
--
-- Achtung: Primärschlüssel ist report_id, NICHT household_id - manche
-- Haushalte wurden mehrfach besucht (siehe households.Protocols_HasMultipleVisits).
-- household_id ist hier ein Fremdschlüssel, kein eindeutiger Schlüssel.

select
    report_id,
    household_id,
    visit_year,
    visit_date,
    * except (report_id, household_id, visit_year, visit_date)
from {{ ref('stg_protocols') }}