# Smart Meter Data Modeling: Star Schema vs. One Big Table

This repository contains the implementation and evaluation of two analytical
data modeling approaches for heterogeneous smart meter data:

- Star Schema
- One Big Table (OBT)

Both approaches are implemented using **dbt** and **ClickHouse** and are
evaluated using identical analytical queries.

The project accompanies the practical paper:

**"Star Schema vs. One Big Table – Vergleich zweier
Datenmodellierungsansätze am Beispiel von Haushaltsverbrauchdaten in dbt
und ClickHouse"**

## Project Overview

The project uses the HEAPO dataset, which combines:

- daily smart meter readings
- household and building metadata
- heat pump audit protocols
- weather data

The raw data is first standardized in a common dbt staging layer.
Based on this layer, two different analytical data models are created.

### Star Schema

The Star Schema consists of:

- `fct_meter_readings`
- `dim_household`
- `dim_weather`
- `dim_protocol`

The fact table contains the daily smart meter measurements, while household,
weather and audit information remain in separate dimension tables.

### One Big Table

The OBT combines smart meter readings with household, weather and audit
attributes in a single denormalized table:

- `obt_smart_meter_readings`

The joins required by analytical queries are therefore already performed
during the dbt build process.

## Architecture

```text
Raw Data
   │
   ▼
Staging Layer
   ├── stg_meter_readings
   ├── stg_households
   ├── stg_protocols
   └── stg_weather
          │
          ├─────────────────────┐
          ▼                     ▼
     Star Schema          One Big Table
          │                     │
          ▼                     ▼
   fct_meter_readings    obt_smart_meter_readings
   dim_household
   dim_weather
   dim_protocol
          │                     │
          └──────────┬──────────┘
                     ▼
                  Benchmark