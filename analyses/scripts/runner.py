def validate_query_files(queries, query_dir):
    """Prüft, ob alle konfigurierten SQL-Dateien vorhanden sind."""

    missing_files = [
        filename
        for _, _, filename in queries
        if not (query_dir / filename).exists()
    ]

    if missing_files:
        raise FileNotFoundError(
            "Fehlende Benchmark-Queries:\n"
            + "\n".join(missing_files)
        )


def run_benchmarks(
    client,
    queries,
    query_dir,
    benchmark_id,
    n_runs,
):
    """Führt alle Benchmark-Queries inklusive Warm-up aus."""

    for query_id, model, filename in queries:

        query_path = query_dir / filename

        sql = (
            query_path
            .read_text(encoding="utf-8")
            .strip()
            .rstrip(";")
        )

        print("\n" + "=" * 60)
        print(f"Benchmark: {query_id} | {model}")
        print(f"Datei: {filename}")
        print("=" * 60)

        # Warm-up-Lauf, wird nicht ausgewertet
        client.query(
            sql,
            settings={
                "use_query_cache": 0,
            },
        )

        # Gemessene Benchmark-Läufe
        for run in range(1, n_runs + 1):

            log_comment = (
                f"benchmark_{benchmark_id}_"
                f"{query_id}_{model}_run_{run}"
            )

            client.query(
                sql,
                settings={
                    "use_query_cache": 0,
                    "log_comment": log_comment,
                },
            )

            print(
                f"{query_id} | {model} | "
                f"Run {run}/{n_runs}"
            )