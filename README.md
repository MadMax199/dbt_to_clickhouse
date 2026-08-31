# Smart-Meter-Datenmodellierung: Star Schema vs. One Big Table

Dieses Repository enthält die Implementierung und Evaluation zweier Datenmodellierungsansätze für heterogene Smart-Meter-Daten:

- Star Schema
- One Big Table (OBT)

Beide Ansätze werden mit **dbt** in **ClickHouse** implementiert und anhand identischer analytischer Abfragen hinsichtlich ihrer Abfrageperformance und ihres Ressourcen- und Speicherbedarfs verglichen.

Das Repository ist Bestandteil der Praxisarbeit:

**„Star Schema vs. One Big Table – Vergleich zweier Datenmodellierungsansätze am Beispiel von Haushaltsverbrauchdaten in dbt und ClickHouse“**

## Projektaufbau

Als Datengrundlage wird der HEAPO-Datensatz verwendet. Dieser umfasst unter anderem:

- tägliche Smart-Meter-Messwerte
- Haushalts- und Gebäudestammdaten
- Auditprotokolle
- Wetterdaten

Die Quelldaten werden zunächst in einer gemeinsamen Staging-Schicht vereinheitlicht. Auf dieser Grundlage werden anschließend das Star Schema und die One Big Table aufgebaut.

### Staging-Schicht

Die gemeinsame Staging-Schicht besteht aus:

```text
stg_meter_readings
stg_households
stg_protocols
stg_weather
```

Hier werden die unterschiedlichen Quelldaten technisch harmonisiert, Spalten vereinheitlicht und Datentypen konvertiert.

### Star Schema

Das Star Schema besteht aus einer zentralen Faktentabelle und drei Dimensionstabellen:

```text
fct_meter_readings
├── dim_household
├── dim_weather
└── dim_protocol
```

Die Smart-Meter-Messwerte werden in der Faktentabelle gespeichert. Haushalts-, Wetter- und Auditinformationen verbleiben in separaten Dimensionstabellen und werden bei analytischen Abfragen miteinander verknüpft.

### One Big Table

Die One Big Table wird in folgendem Modell materialisiert:

```text
obt_smart_meter_readings
```

Hier werden Smart-Meter-Messwerte sowie Haushalts-, Wetter- und Auditinformationen bereits während des dbt-Build-Prozesses in einer einzelnen Tabelle zusammengeführt.

## Architektur

```text
Quelldaten
    │
    ▼
Staging-Schicht
    ├── stg_meter_readings
    ├── stg_households
    ├── stg_protocols
    └── stg_weather
           │
           ├──────────────────────┐
           ▼                      ▼
      Star Schema           One Big Table
           │                      │
           ▼                      ▼
 fct_meter_readings     obt_smart_meter_readings
 dim_household
 dim_weather
 dim_protocol
           │                      │
           └──────────┬───────────┘
                      ▼
                  Benchmark
```

## Voraussetzungen

Für die lokale Ausführung werden folgende Komponenten benötigt:

- Python 3.x
- Docker / Docker Desktop
- ClickHouse
- dbt
- Git

## 1. Repository klonen

```bash
git clone <REPOSITORY-URL>
cd <REPOSITORY-NAME>
```

## 2. Python-Umgebung erstellen

Unter Windows:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

Unter Linux oder macOS:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Anschließend werden die benötigten Python-Pakete installiert:

```bash
pip install -r requirements.txt
```

## 3. ClickHouse starten

Wird ClickHouse lokal über Docker Compose betrieben, kann die Datenbank mit folgendem Befehl gestartet werden:

```bash
docker compose up -d
```

Anschließend kann überprüft werden, ob der Container läuft:

```bash
docker ps
```

Die standardmäßigen ClickHouse-Ports sind:

- HTTP: `8123`
- Native Protocol: `9000`

## 4. dbt konfigurieren

Für dbt muss eine Verbindung zur verwendeten ClickHouse-Instanz konfiguriert werden.

Die Verbindung kann anschließend überprüft werden:

```bash
dbt debug
```

Bei erfolgreicher Konfiguration kann dbt auf die ClickHouse-Datenbank zugreifen.

## 5. Quelldaten bereitstellen

Die benötigten HEAPO-Daten müssen entsprechend der im Projekt erwarteten Verzeichnisstruktur bereitgestellt werden.

Verwendet werden vier Datenbereiche:

```text
Smart-Meter-Daten
Haushaltsdaten
Auditprotokolle
Wetterdaten
```

Die Smart-Meter-Daten liegen in separaten CSV-Dateien vor und werden innerhalb der Staging-Schicht zusammengeführt.

Sofern Quelldaten als dbt Seeds eingebunden sind, können diese mit folgendem Befehl geladen werden:

```bash
dbt seed
```

## 6. dbt-Modelle erstellen

Die Datenmodelle können mit folgendem Befehl aufgebaut werden:

```bash
dbt run
```

Dabei wird zunächst die gemeinsame Staging-Schicht erstellt. Auf deren Grundlage werden anschließend das Star Schema und die One Big Table aufgebaut.

Alternativ können Modelle und Tests gemeinsam ausgeführt werden:

```bash
dbt build
```

## 7. dbt-Tests ausführen

Zur Überprüfung der strukturellen Integrität werden unter anderem folgende Tests eingesetzt:

- `unique`
- `not_null`
- `relationships`
- `dbt_utils.unique_combination_of_columns`

Die Tests können separat ausgeführt werden:

```bash
dbt test
```

## 8. Benchmark ausführen

Zur Evaluation werden für beide Datenmodelle fachlich identische Abfragen ausgeführt.

Die sechs Benchmark-Szenarien umfassen:

| Query | Anwendungsfall |
|---|---|
| Q1 | Monatliche Aggregation |
| Q2 | Analyse von Haushaltsmerkmalen |
| Q3 | Analyse von Wetterinformationen |
| Q4 | Analyse von Auditinformationen |
| Q5 | Mehrdimensionale analytische Abfrage |
| Q6 | Bereitstellung eines Machine-Learning-Datensatzes |

Der Benchmark kann über das entsprechende Python-Skript gestartet werden, beispielsweise:

```bash
python analyses/load.py
```

Jede Abfrage wird mehrfach ausgeführt, um zufällige Laufzeitschwankungen zu reduzieren.

## Evaluationsmetriken

Für den Vergleich werden folgende Metriken betrachtet:

- Abfragelaufzeit
- gelesene Zeilen
- gelesene Datenmenge
- Arbeitsspeicherbedarf
- physischer Speicherbedarf
- Kompressionsverhältnis

Die Performance-Metriken werden aus dem ClickHouse Query Log ausgelesen.

Der Speicherbedarf wird für folgende Tabellen betrachtet:

```text
fct_meter_readings
dim_household
dim_weather
dim_protocol
obt_smart_meter_readings
```

## Reproduktion des Benchmarks

Für eine vollständige Reproduktion sind damit folgende Schritte erforderlich:

```text
1. Repository klonen
2. Python-Umgebung erstellen
3. Abhängigkeiten installieren
4. ClickHouse starten
5. dbt konfigurieren
6. Quelldaten bereitstellen
7. dbt-Modelle erstellen
8. dbt-Tests ausführen
9. Benchmark starten
10. Benchmark-Ergebnisse auswerten
```

## Datengrundlage

Als Datengrundlage wird der HEAPO-Datensatz verwendet:

Brudermueller, T., Fleisch, E., Vayá, M. G., & Staake, T. (2025).  
*HEAPO – An Open Dataset for Heat Pump Optimization with Smart Electricity Meter Data and On-Site Inspection Protocols.*

Der Datensatz kombiniert Smart-Meter-Zeitreihen mit Haushaltsmetadaten, Auditprotokollen und Wetterinformationen.

## Hintergrund

Das Repository wurde im Rahmen der Praxisarbeit im Modul **Data Engineering 1** erstellt.

Ziel ist die vergleichende Evaluation eines Star Schemas und einer One Big Table für analytische Smart-Meter-Anwendungsfälle in ClickHouse.