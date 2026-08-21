import os

import clickhouse_connect
from dotenv import load_dotenv


def get_clickhouse_client():
    """Erstellt eine ClickHouse-Verbindung auf Basis der .env-Datei."""

    load_dotenv()

    required_env_vars = [
        "CLICKHOUSE_HOST",
        "CLICKHOUSE_PORT",
        "CLICKHOUSE_USER",
        "CLICKHOUSE_PASSWORD",
        "CLICKHOUSE_DATABASE",
    ]

    missing_env_vars = [
        var
        for var in required_env_vars
        if not os.getenv(var)
    ]

    if missing_env_vars:
        raise ValueError(
            "Fehlende Umgebungsvariablen: "
            + ", ".join(missing_env_vars)
        )

    return clickhouse_connect.get_client(
        host=os.getenv("CLICKHOUSE_HOST"),
        port=int(os.getenv("CLICKHOUSE_PORT")),
        username=os.getenv("CLICKHOUSE_USER"),
        password=os.getenv("CLICKHOUSE_PASSWORD"),
        database=os.getenv("CLICKHOUSE_DATABASE"),
        secure=False,
    )