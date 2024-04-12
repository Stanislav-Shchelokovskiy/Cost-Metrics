from pandas import DataFrame, to_datetime


def transform(df: DataFrame, dtfield: str = 'year_month') -> DataFrame:
    df[dtfield] = to_datetime(
        df[dtfield],
        utc=True,
    )
    return df.sort_values(by=df.columns.to_list()).reset_index(drop=True)
