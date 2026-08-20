from pathlib import Path
import time
import pandas as pd
import clickhouse_connect



N_RUNS = 10

QUERY_DIR = Path("benchmarks/queries")
RESULT_DIR = Path("benchmarks/results")

RESULT_DIR.mkdir(parents=True, exist_ok=True)

client = clickhouse_connect.get_client(
    host="YOUR_CLICKHOUSE_HOST",
    port=8443,
    username="YOUR_USER",
    password="YOUR_PASSWORD",
    secure=True,
)

queries = [
    ("q01", "star", "q01_monthly_consumption_star.sql"),
    ("q01", "obt",  "q01_monthly_consumption_obt.sql"),

    ("q02", "star", "q02_pv_consumption_star.sql"),
    ("q02", "obt",  "q02_pv_consumption_obt.sql"),

    ("q03", "star", "q03_weather_consumption_star.sql"),
    ("q03", "obt",  "q03_weather_consumption_obt.sql"),

    ("q04", "star", "q04_protocol_consumption_star.sql"),
    ("q04", "obt",  "q04_protocol_consumption_obt.sql"),

    ("q05", "star", "q05_multi_dimension_star.sql"),
    ("q05", "obt",  "q05_multi_dimension_obt.sql"),

    ("q06", "star", "q06_ml_dataset_star.sql"),
    ("q06", "obt",  "q06_ml_dataset_obt.sql"),
]


for query_id, model, filename in queries:

    sql = (QUERY_DIR / filename).read_text(encoding="utf-8").strip().rstrip(";")

    # Warm-up
    client.query(
        sql,
        settings={
            "use_query_cache": 0,
            "enable_filesystem_cache": 0,
        },
    )

    for run in range(1, N_RUNS + 1):

        log_comment = f"benchmark_{query_id}_{model}_run_{run}"

        client.query(
            sql,
            settings={
                "use_query_cache": 0,
                "enable_filesystem_cache": 0,
                "log_comment": log_comment,
            },
        )

        print(f"{query_id} | {model} | Run {run}/{N_RUNS}")

# Query Log flushen
client.command("SYSTEM FLUSH LOGS")

time.sleep(1)