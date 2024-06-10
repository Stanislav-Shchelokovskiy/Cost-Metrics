from collections.abc import Iterable, Mapping
from pandas.testing import assert_frame_equal
from pandas import DataFrame, to_datetime


def transform(df: DataFrame, dtfields: Iterable[str] = None) -> DataFrame:
    if dtfields:
        for field in dtfields:
            df[field] = to_datetime(
                df[field],
                utc=True,
            )
    return df.sort_values(by=df.columns.to_list()).reset_index(drop=True)


def assert_equal(
    got: DataFrame,
    want: Mapping,
    dtfields: Iterable[str] | None = None,
):
    got = transform(got, dtfields=dtfields)
    want = transform(DataFrame(data=want), dtfields=dtfields)

    assert_frame_equal(got, want)
