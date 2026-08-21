N_RUNS = 10

QUERIES = [
    ("q01", "star", "q01_monthly_star.sql.sql"),
    ("q01", "obt",  "q01_monthly_obt.sql.sql"),

    ("q02", "star", "q02_pv_star.sql.sql"),
    ("q02", "obt",  "q02_pv_obt.sql.sql"),

    ("q03", "star", "q03_weather_star.sql.sql"),
    ("q03", "obt",  "q03_weather_obt.sql.sql"),

    ("q04", "star", "q04_audit_star.sql.sql"),
    ("q04", "obt",  "q04_audit_obt.sql.sql"),

    ("q05", "star", "q05_multi_dimension_star.sql"),
    ("q05", "obt",  "q05_multi_dimension_obt.sql"),

    ("q06", "star", "q06_ml_dataset_star.sql"),
    ("q06", "obt",  "q06_ml_dataset_obt.sql"),
]

STAR_TABLES = [
    "fct_meter_readings",
    "dim_household",
    "dim_weather",
    "dim_protocol",
]