# 🚀 Smart-Meter Data Modeling: Star Schema vs. One Big Table in ClickHouse Cloud

This repository contains the complete implementation and benchmarking framework for evaluating two fundamental data modeling paradigms—the **Star Schema** and **One Big Table (OBT)**—using high-frequency Smart-Meter data, static building assets, and weather time-series.

The pipeline is orchestrated using **dbt (data build tool)** and executed natively in **ClickHouse Cloud**, a high-performance, column-oriented OLAP database management system.

---

## 📖 Theoretical Context & Problem Statement

The integration of renewable energies and dynamic tariffs requires a rapid digital transformation of the power grid. Initiatives like the German Smart-Meter Rollout (**GNDEW 2023**; **BMWK 2024**) generate billions of high-frequency data points. 

Analysing this data requires combining highly dynamic consumption streams with static building metadata and spatial weather data (*Ji et al., 2020*).

### The Semiotic & Architectural Challenge
* **The Structural Gap:** Traditional relational systems optimized for OLTP (using 3rd Normal Form to avoid redundancies, *Codd, 1970*) fail to perform aggregate calculations over massive datasets due to expensive runtime join operations (*Chaudhuri & Dayal, 1997*).
* **The Semantic Gap:** Aligning heterogeneous schemas (time-series, spatial grid coordinates, and property metadata) requires a robust semantic layer to prevent data inconsistency.

To address these gaps, this project implements and benchmarks:
1. **The Star Schema (Dimensional Modeling):** Segmenting data into a central fact table and direct denormalized dimension tables (*Kimball & Ross, 2013*).
2. **One Big Table (OBT):** A single, wide table consolidating all attributes, eliminating run-time joins (*Späti, 2026*).

---

## 🛠️ Technological Pillars

### 1. ClickHouse as OLAP target
Unlike traditional row-oriented databases (e.g., PostgreSQL), ClickHouse employs a **column-oriented storage architecture** (*Anand, 2021*). 
* It writes the values of each column into separate, logically closed files (*Abadi et al., 2013*).
* When run-time aggregations are triggered, only the target columns are loaded into memory, completely bypassing unnecessary I/O overhead (*Abadi et al., 2008*).
* ClickHouse leverages vectorised query execution and specialized physical sorting engines like the **MergeTree** table engine to accelerate lookups.

### 2. dbt (data build tool) for Analytics Engineering
Rather than relying on classic ETL, this project implements a modern **ELT (Extract, Load, Transform)** workflow (*Reis & Housley, 2022*). 
Raw data is loaded straight into ClickHouse, and dbt acts as the orchestrator for **In-Database-Transformations** (*Solimito, 2023*):
* **Modularization:** SQL models are defined in separate modules and dynamically linked using Jinja-templated references (`ref()`). dbt calculates the dependency tree via a Directed Acyclic Graph (**DAG**).
* **Data Quality:** Declarative schema and data quality tests are ran automatically on schema boundaries.
* **Software Practices:** Models are version-controlled via Git, bringing CI/CD principles to data warehousing.

---

## 📊 Paradigm Comparison: ETL vs. ELT

| Aspect | Classical ETL Approach | Modern ELT Approach |
| :--- | :--- | :--- |
| **Storage & Cost** | Storage was expensive; required high optimization. | Cloud storage is cheap; high CPU compute is optimized. |
| **Modeling Priority** | Storage efficiency (avoiding redundancy). | Query latency and developer efficiency. |
| **Architecture** | Strong normalization (3NF) to reduce footprint. | Redundant, denormalized layouts for fast reads. |
| **Transformation** | Executed *before* loading, outside the warehouse. | Executed *after* loading raw data directly inside OLAP. |

---

## 📁 Repository Structure

```text
├── .venv/                     # Isolated Python environment
├── analyses/                  # Benchmark SQL queries (Performance tests)
├── models/
│   ├── staging/               # Staging models: cleaning, casting (HEAPO source)
│   ├── intermediate/          # Intermediate views, early aggregations
│   └── marts/
│       ├── star_schema/       # Mart: Fact table (fct_) & Dimension tables (dim_)
│       └── obt/               # Mart: Fully denormalized One Big Table (OBT)
├── tests/                     # Schema, unique, and non-null data assertions
├── dbt_project.yml            # Core dbt configuration
└── profiles.yml.example       # Example database connection profile