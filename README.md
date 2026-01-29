# 🚀 DBT to ClickHouse: Modern Data Transformation

## Projektübersicht

Dieses Projekt demonstriert eine robuste Datenpipeline zur Transformation von Rohdaten mithilfe von dbt (data build tool) in einer leistungsstarken ClickHouse Cloud-Umgebung. Es dient als Boilerplate für Analytics Engineering, bei dem Daten aus verschiedenen Quellen bereinigt, transformiert und für die Analyse bereitgestellt werden.

### ✨ Technologie-Stack

* **dbt (data build tool):** Für die Transformation der Daten (SQL-First, Data Build Tool).
* **ClickHouse Cloud:** Eine spaltenorientierte Datenbank für OLAP-Workloads, die extrem schnelle Abfragen ermöglicht.
* **Python (mit .venv):** Zur Verwaltung der dbt-Abhängigkeiten.
* **Git:** Für die Versionskontrolle.

## Erste Schritte

Diese Anleitung hilft dir, das Projekt lokal einzurichten und deine erste Datentransformation durchzuführen.

###  Voraussetzungen

Stelle sicher, dass folgende Software auf deinem System installiert ist:

* [Git](https://git-scm.com/downloads)
* [Python 3.8+](https://www.python.org/downloads/)
* [pip](https://pip.pypa.io/en/stable/installation/) (normalerweise bei Python dabei)
* **ClickHouse Cloud Account:** Ein aktiver Service in der [ClickHouse Cloud](https://clickhouse.cloud/).

### 1\. Repository klonen

```bash
git clone [https://github.com/DeinNutzername/dbt_to_clickhouse.git](https://github.com/DeinNutzername/dbt_to_clickhouse.git)
cd dbt_to_clickhouse