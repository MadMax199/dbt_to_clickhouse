import pandas as pd
import numpy as np


def query_to_dataframe(client, sql):
    """
    Führt eine Query aus und gibt das Ergebnis als DataFrame zurück.
    """
    result = client.query(sql)

    return pd.DataFrame(
        result.result_rows,
        columns=result.column_names,
    )


def compare_query_results(
    client,
    query_id,
    star_sql,
    obt_sql,
    rtol=1e-5,
    atol=1e-8,
):
    """
    Vergleicht die fachlichen Ergebnisse einer Star- und OBT-Query.

    Numerische Werte werden mit einer Toleranz verglichen,
    alle übrigen Werte exakt.
    """

    star_df = query_to_dataframe(client, star_sql)
    obt_df = query_to_dataframe(client, obt_sql)

    result = {
        "query_id": query_id,
        "star_rows": len(star_df),
        "obt_rows": len(obt_df),
        "same_row_count": len(star_df) == len(obt_df),
        "same_columns": list(star_df.columns) == list(obt_df.columns),
        "values_equal": False,
        "max_numeric_difference": None,
    }

    # Unterschiedliche Spalten -> kein sinnvoller Wertevergleich
    if not result["same_columns"]:
        return result

    # Unterschiedliche Zeilenzahl
    if not result["same_row_count"]:
        return result

    # Sortierung vereinheitlichen
    columns = list(star_df.columns)

    star_df = (
        star_df
        .sort_values(columns, na_position="first")
        .reset_index(drop=True)
    )

    obt_df = (
        obt_df
        .sort_values(columns, na_position="first")
        .reset_index(drop=True)
    )

    comparisons = []
    numeric_differences = []

    for column in columns:

        star_col = star_df[column]
        obt_col = obt_df[column]

        if (
            pd.api.types.is_numeric_dtype(star_col)
            and pd.api.types.is_numeric_dtype(obt_col)
        ):

            star_values = star_col.to_numpy(dtype=float)
            obt_values = obt_col.to_numpy(dtype=float)

            equal = np.allclose(
                star_values,
                obt_values,
                rtol=rtol,
                atol=atol,
                equal_nan=True,
            )

            comparisons.append(equal)

            if len(star_values) > 0:
                diff = np.abs(
                    star_values - obt_values
                )

                if not np.all(np.isnan(diff)):
                    numeric_differences.append(
                        np.nanmax(diff)
                    )

        else:

            equal = (
                star_col.fillna("<NULL>").astype(str)
                ==
                obt_col.fillna("<NULL>").astype(str)
            ).all()

            comparisons.append(equal)

    result["values_equal"] = all(comparisons)

    if numeric_differences:
        result["max_numeric_difference"] = max(
            numeric_differences
        )

    return result