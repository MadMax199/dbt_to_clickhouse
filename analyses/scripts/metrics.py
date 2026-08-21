import pandas as pd


def load_performance_metrics(client, benchmark_id):
    """Lädt die Performance-Metriken des aktuellen Benchmark-Laufs."""

    performance_sql = f"""
    SELECT
        log_comment,
        query_duration_ms,
        read_rows,
        read_bytes,
        memory_usage,
        result_rows,
        event_time
    FROM system.query_log
    WHERE type = 'QueryFinish'
      AND is_initial_query = 1
      AND startsWith(
          log_comment,
          'benchmark_{benchmark_id}_'
      )
    ORDER BY event_time
    """

    result = client.query(performance_sql)

    return pd.DataFrame(
        result.result_rows,
        columns=result.column_names,
    )


def prepare_performance_metrics(
    performance_df,
    benchmark_id,
):
    """Bereitet die Performance-Rohdaten für die Auswertung auf."""

    if performance_df.empty:
        raise ValueError(
            "Keine Performance-Metriken gefunden."
        )

    metadata = performance_df[
        "log_comment"
    ].str.extract(
        rf"benchmark_{benchmark_id}_"
        rf"(q\d+)_(star|obt)_run_(\d+)"
    )

    metadata.columns = [
        "query",
        "model",
        "run",
    ]

    df = pd.concat(
        [
            performance_df,
            metadata,
        ],
        axis=1,
    )

    if df["run"].isna().any():
        raise ValueError(
            "Benchmark-Metadaten konnten "
            "nicht vollständig extrahiert werden."
        )

    df["run"] = df["run"].astype(int)

    # Bytes in MB umrechnen
    df["read_mb"] = (
        df["read_bytes"] / 1024**2
    )

    df["memory_mb"] = (
        df["memory_usage"] / 1024**2
    )

    return df


def summarize_performance(df):
    """Aggregiert die Performance-Metriken nach Query und Modell."""

    return (
        df
        .groupby(["query", "model"])
        .agg(
            runs=(
                "query_duration_ms",
                "count",
            ),
            median_duration_ms=(
                "query_duration_ms",
                "median",
            ),
            mean_duration_ms=(
                "query_duration_ms",
                "mean",
            ),
            std_duration_ms=(
                "query_duration_ms",
                "std",
            ),
            min_duration_ms=(
                "query_duration_ms",
                "min",
            ),
            max_duration_ms=(
                "query_duration_ms",
                "max",
            ),
            median_read_rows=(
                "read_rows",
                "median",
            ),
            median_read_mb=(
                "read_mb",
                "median",
            ),
            median_memory_mb=(
                "memory_mb",
                "median",
            ),
            median_result_rows=(
                "result_rows",
                "median",
            ),
        )
        .reset_index()
    )


def compare_performance(summary_df):
    """Vergleicht die mediane Ausführungszeit von Star Schema und OBT."""

    comparison_df = summary_df.pivot(
        index="query",
        columns="model",
        values="median_duration_ms",
    )

    if not {"star", "obt"}.issubset(
        comparison_df.columns
    ):
        raise ValueError(
            "Für den Performance-Vergleich werden "
            "Star- und OBT-Ergebnisse benötigt."
        )

    comparison_df["difference_ms"] = (
        comparison_df["star"]
        - comparison_df["obt"]
    )

    comparison_df["obt_speedup_percent"] = (
        (
            comparison_df["star"]
            - comparison_df["obt"]
        )
        / comparison_df["star"]
        * 100
    )

    return comparison_df.reset_index()


def load_storage_metrics(client):
    """Lädt den physischen Speicherbedarf der relevanten Tabellen."""

    storage_sql = """
    SELECT
        table,
        sum(rows) AS rows,
        sum(data_compressed_bytes) AS compressed_bytes,
        sum(data_uncompressed_bytes) AS uncompressed_bytes
    FROM system.parts
    WHERE active
      AND database = currentDatabase()
      AND table IN (
          'fct_meter_readings',
          'dim_household',
          'dim_weather',
          'dim_protocol',
          'obt_smart_meter_readings'
      )
    GROUP BY table
    ORDER BY table
    """

    result = client.query(storage_sql)

    storage_df = pd.DataFrame(
        result.result_rows,
        columns=result.column_names,
    )

    if storage_df.empty:
        raise ValueError(
            "Keine Speicherinformationen in system.parts gefunden."
        )

    storage_df["compressed_mb"] = (
        storage_df["compressed_bytes"] / 1024**2
    )

    storage_df["uncompressed_mb"] = (
        storage_df["uncompressed_bytes"] / 1024**2
    )

    storage_df["compression_ratio"] = (
        storage_df["uncompressed_bytes"]
        / storage_df["compressed_bytes"]
    )

    return storage_df


def compare_storage(
    storage_df,
    star_tables,
):
    """Aggregiert den Speicherbedarf für Star Schema und OBT."""

    star_storage = storage_df[
        storage_df["table"].isin(star_tables)
    ]

    obt_storage = storage_df[
        storage_df["table"]
        == "obt_smart_meter_readings"
    ]

    if star_storage.empty:
        raise ValueError(
            "Keine Tabellen des Star Schemas gefunden."
        )

    if obt_storage.empty:
        raise ValueError(
            "One Big Table wurde nicht gefunden."
        )

    comparison_df = pd.DataFrame(
        [
            {
                "model": "star",
                "compressed_bytes":
                    star_storage[
                        "compressed_bytes"
                    ].sum(),
                "uncompressed_bytes":
                    star_storage[
                        "uncompressed_bytes"
                    ].sum(),
            },
            {
                "model": "obt",
                "compressed_bytes":
                    obt_storage[
                        "compressed_bytes"
                    ].sum(),
                "uncompressed_bytes":
                    obt_storage[
                        "uncompressed_bytes"
                    ].sum(),
            },
        ]
    )

    comparison_df["compressed_mb"] = (
        comparison_df["compressed_bytes"]
        / 1024**2
    )

    comparison_df["uncompressed_mb"] = (
        comparison_df["uncompressed_bytes"]
        / 1024**2
    )

    comparison_df["compression_ratio"] = (
        comparison_df["uncompressed_bytes"]
        / comparison_df["compressed_bytes"]
    )

    return comparison_df