# 🚀 Smart-Meter-Datenmodellierung: Star-Schema vs. One Big Table in ClickHouse Cloud

Dieses Repository enthält das vollständige Implementierungs- und Benchmarking-Framework zur Evaluierung von zwei fundamentalen Datenmodellierungsparadigmen – dem **Star-Schema** und der **One Big Table (OBT)** – unter Verwendung hochfrequenter Smart-Meter-Zeitreihen, statischer Gebäude-Stammdaten und Wetterdaten.

Die Pipeline wird mithilfe von **dbt (data build tool)** orchestriert und nativ in **ClickHouse Cloud** ausgeführt, einem hochperformanten, spaltenorientierten OLAP-Datenbankmanagementsystem.

---

## 📖 Theoretischer Kontext & Problemstellung

Der Ausbau der erneuerbaren Energien und die Nutzung dynamischer Stromtarife erfordern eine schnelle digitale Transformation des Stromnetzes. Initiativen wie der deutsche Smart-Meter-Rollout (**GNDEW 2023**; **BMWK 2024**) erzeugen Milliarden hochfrequenter Datenpunkte.

Die Analyse dieser Daten erfordert die Kombination hochdynamischer Verbrauchswerte mit statischen Gebäude- und Anlagenstammdaten sowie dynamischen Wetterdaten (*Ji et al., 2020*).

### Die semiotische & architektonische Herausforderung
* **Die strukturelle Lücke:** Klassische relationale Systeme, die für OLTP optimiert sind (unter Verwendung der 3. Normalform zur Vermeidung von Redundanzen, *Codd, 1970*), scheitern bei komplexen Aggregationsberechnungen über riesige Datenmengen aufgrund rechenintensiver Join-Operationen zur Abfragezeit (*Chaudhuri & Dayal, 1997*).
* **Die semantische Lücke:** Die Verknüpfung heterogener Schemata (Zeitreihen, geografische Netzkoordinaten und Gebäude-Metadaten) erfordert eine robuste semantische Schicht, um Inkonsistenzen zu verhindern.

Um diese Herausforderungen zu bewältigen, implementiert und vergleicht dieses Projekt:
1. **Das Star-Schema (Dimensionale Modellierung):** Aufteilung der Daten in eine zentrale Faktentabelle und direkt verknüpfte, denormalisierte Dimensionstabellen (*Kimball & Ross, 2013*).
2. **One Big Table (OBT):** Eine einzige, breite Tabelle, die alle Attribute konsolidiert und Joins zur Abfragezeit überflüssig macht (*Späti, 2026*).

---

## 🛠️ Technologische Säulen

### 1. ClickHouse als OLAP-Zielsystem
Im Gegensatz zu traditionellen zeilenorientierten Datenbanken (z. B. PostgreSQL) setzt ClickHouse auf eine **spaltenorientierte Speicherarchitektur** (*Anand, 2021*).
* Die Werte jeder einzelnen Spalte werden in separate, logisch geschlossene Dateien auf dem Speichermedium geschrieben (*Abadi et al., 2013*).
* Bei analytischen Aggregationsabfragen müssen physisch nur diejenigen Spaltendateien in den Arbeitsspeicher geladen werden, die tatsächlich Teil der Operation sind. Der enorme I/O-Overhead wird somit systemisch eliminiert (*Abadi et al., 2008*).
* ClickHouse nutzt eine hochgradig parallelisierte, vektorisierte Abfrageausführung sowie die spezialisierte **MergeTree**-Tabellen-Engine, um Such- und Aggregationsvorgänge extrem zu beschleunigen.

### 2. dbt (data build tool) für Analytics Engineering
Anstelle des klassischen ETL-Ansatzes implementiert dieses Projekt einen modernen **ELT-Workflow (Extract, Load, Transform)** *(Reis & Housley, 2022)*.
Die Rohdaten werden direkt in ClickHouse geladen, und dbt fungiert als Orchestrator für die **In-Database-Transformationen** (*Solimito, 2023*):
* **Modularität:** SQL-Modelle werden in separaten Dateien definiert und über die Jinja-Templating-Engine mittels der `ref()`-Funktion dynamisch miteinander verknüpft. dbt generiert daraus automatisch einen gerichteten kreisfreien Graphen (Directed Acyclic Graph, **DAG**), der die exakte Reihenfolge der Tabellenerstellung steuert.
* **Datenqualität:** Deklarative Schema- und Datenqualitätstests (z. B. auf Eindeutigkeit oder Nullwerte) werden automatisiert an den Modellgrenzen ausgeführt.
* **Softwareentwicklung-Best-Practices:** Modelle werden über Git versioniert, wodurch CI/CD-Prinzipien in die Datenmodellierung einziehen.

---

## 📊 Paradigmen-Vergleich: ETL vs. ELT

| Aspekt | Klassischer ETL-Ansatz | Moderner ELT-Ansatz |
| :--- | :--- | :--- |
| **Speicher & Kosten** | Physischer Speicher war teuer und musste stark optimiert werden. | Cloud-Speicher ist günstig; CPU-Rechenleistung für Berechnungen wird optimiert. |
| **Modellierungs-Priorität** | Speichereffizienz (Vermeidung von Redundanzen). | Abfragegeschwindigkeit und Entwicklereffizienz. |
| **Architektur** | Starke Normalisierung (3NF) zur Reduzierung des Footprints. | Redundante, denormalisierte Strukturen für schnelle Lesezugriffe. |
| **Transformation** | Daten werden vor dem Laden außerhalb des Data Warehouse transformiert. | Transformationen erfolgen direkt nach dem Laden der Rohdaten im OLAP-System. |

---

## 📁 Repository-Struktur

```text
├── .venv/                     # Isolierte virtuelle Python-Umgebung
├── analyses/                  # SQL-Queries für die Performance-Benchmarks
├── models/
│   ├── staging/               # Staging-Modelle: Bereinigung & Typisierung (HEAPO-Quelle)
│   ├── intermediate/          # Intermediate-Views und vorbereitende Joins
│   └── marts/
│       ├── star_schema/       # Mart-Ebene: Faktentabelle (fct_) & Dimensionen (dim_)
│       └── obt/               # Mart-Ebene: Vollständig denormalisierte One Big Table (OBT)
├── tests/                     # Schema- und Datenqualitätstests (Unique, Not Null, etc.)
├── dbt_project.yml            # Zentrale dbt-Projektkonfiguration
└── profiles.yml.example       # Vorlage für die ClickHouse-Verbindung