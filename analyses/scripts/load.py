from pathlib import Path
import time
from datetime import datetime

import pandas as pd

from config import (
    N_RUNS,
    QUERIES,
    STAR_TABLES,
)
from connection import get_clickhouse_client
from runner import (
    validate_query_files,
    run_benchmarks,
)
from metrics import (
    load_performance_metrics,
    prepare_performance_metrics,
    summarize_performance,
    compare_performance,
    load_storage_metrics,
    compare_storage,
)
from validation import compare_query_results


# -------------------------------------------------------
# Pfade
# -------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parents[2]

QUERY_DIR = (
    BASE_DIR
    / "analyses"
    / "benchmark_queries"
)

RESULT_DIR = (
    BASE_DIR
    / "analyses"
    / "results"
)

RESULT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


def main():

    # ---------------------------------------------------
    # Benchmark-ID
    # ---------------------------------------------------

    benchmark_id = (
        datetime.now()
        .strftime("%Y%m%d_%H%M%S")
    )

    print("=" * 60)
    print("Benchmark Star Schema vs. One Big Table")
    print("=" * 60)
    print(f"Benchmark-ID: {benchmark_id}")
    print(f"Wiederholungen: {N_RUNS}")

    # ---------------------------------------------------
    # Verbindung
    # ---------------------------------------------------

    client = get_clickhouse_client()

    connection_test = client.query(
        "SELECT version(), currentDatabase()"
    )

    version, database = connection_test.result_rows[0]

    print(f"ClickHouse-Version: {version}")
    print(f"Datenbank: {database}")

    # ---------------------------------------------------
    # Benchmark-Queries prüfen
    # ---------------------------------------------------

    validate_query_files(
        QUERIES,
        QUERY_DIR,
    )

    # ---------------------------------------------------
    # Benchmarks ausführen
    # ---------------------------------------------------

    run_benchmarks(
        client=client,
        queries=QUERIES,
        query_dir=QUERY_DIR,
        benchmark_id=benchmark_id,
        n_runs=N_RUNS,
    )

    # ---------------------------------------------------
    # Query Log aktualisieren
    # ---------------------------------------------------

    print("\nAktualisiere system.query_log...")

    client.command(
        "SYSTEM FLUSH LOGS"
    )

    time.sleep(1)

    # ---------------------------------------------------
    # Performance auswerten
    # ---------------------------------------------------

    performance_df = (
        load_performance_metrics(
            client,
            benchmark_id,
        )
    )

    performance_df = (
        prepare_performance_metrics(
            performance_df,
            benchmark_id,
        )
    )

    summary_df = (
        summarize_performance(
            performance_df
        )
    )

    performance_comparison_df = (
        compare_performance(
            summary_df
        )
    )

    # ---------------------------------------------------
    # Speicher auswerten
    # ---------------------------------------------------

    storage_df = (
        load_storage_metrics(
            client
        )
    )

    storage_comparison_df = (
        compare_storage(
            storage_df,
            STAR_TABLES,
        )
    )

    # ---------------------------------------------------
    # Fachliche Validierung
    # ---------------------------------------------------

    print(
        "\nValidiere fachliche Gleichheit "
        "der Benchmark-Queries..."
    )

    validation_results = []
    query_pairs = {}

    # SQL-Dateien nach Query und Modell gruppieren
    for query_id, model, filename in QUERIES:

        sql = (
            (QUERY_DIR / filename)
            .read_text(
                encoding="utf-8"
            )
            .strip()
            .rstrip(";")
        )

        if query_id not in query_pairs:
            query_pairs[query_id] = {}

        query_pairs[query_id][model] = sql

    # Star vs. OBT vergleichen
    for query_id, models in query_pairs.items():

        if "star" not in models or "obt" not in models:
            raise ValueError(
                f"Für {query_id} fehlt die "
                "Star- oder OBT-Query."
            )

        result = compare_query_results(
            client=client,
            query_id=query_id,
            star_sql=models["star"],
            obt_sql=models["obt"],
        )

        validation_results.append(
            result
        )

        print(
            f"{query_id}: "
            f"Rows "
            f"{result['star_rows']} / "
            f"{result['obt_rows']} | "
            f"Columns: "
            f"{result['same_columns']} | "
            f"Values: "
            f"{result['values_equal']}"
        )

    validation_df = pd.DataFrame(
        validation_results
    )

    # ---------------------------------------------------
    # Ergebnisse speichern
    # ---------------------------------------------------

    performance_df.to_csv(
        RESULT_DIR
        / f"query_performance_{benchmark_id}.csv",
        index=False,
    )

    summary_df.to_csv(
        RESULT_DIR
        / f"query_performance_summary_{benchmark_id}.csv",
        index=False,
    )

    performance_comparison_df.to_csv(
        RESULT_DIR
        / f"query_performance_comparison_{benchmark_id}.csv",
        index=False,
    )

    storage_df.to_csv(
        RESULT_DIR
        / f"storage_usage_{benchmark_id}.csv",
        index=False,
    )

    storage_comparison_df.to_csv(
        RESULT_DIR
        / f"storage_comparison_{benchmark_id}.csv",
        index=False,
    )

    validation_df.to_csv(
        RESULT_DIR
        / f"query_validation_{benchmark_id}.csv",
        index=False,
    )

    # ---------------------------------------------------
    # Abschluss
    # ---------------------------------------------------

    print("\n" + "=" * 60)
    print("Benchmark abgeschlossen")
    print("=" * 60)

    print("\nPerformance:")
    print(
        summary_df.to_string(
            index=False
        )
    )

    print("\nStar Schema vs. OBT:")
    print(
        performance_comparison_df.to_string(
            index=False
        )
    )

    print("\nSpeicherbedarf:")
    print(
        storage_comparison_df.to_string(
            index=False
        )
    )

    print("\nFachliche Validierung:")
    print(
        validation_df.to_string(
            index=False
        )
    )

    print(
        f"\nErgebnisse gespeichert unter:\n"
        f"{RESULT_DIR}"
    )


if __name__ == "__main__":
    main()