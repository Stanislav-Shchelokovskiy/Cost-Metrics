import pytest
from typing import Callable
from os import getcwd
import toolbox.sql.index as RootPath
import sql_queries.remote_index as remote_index
import sql_queries.transform_load_index as transform_load_index
from pathlib import Path
from sql_queries.meta import (
    WorkOnHolidaysMeta,
    CostmetricsMeta,
)


@pytest.mark.parametrize(
    'get_query_file_path, format_params',
    [
        (
            remote_index.get_upsert_work_on_holidays,
            {
                'values': '(qwe, 2, 3)',
                **WorkOnHolidaysMeta.get_attrs(),
            },
        ),
        (
            remote_index.get_cost_metrics_path,
            {
                'start': 'start',
                'end': 'end',
                **CostmetricsMeta.get_attrs(),
            },
        ),
        (
            transform_load_index.get_cost_metrics_table_path,
            {
                **CostmetricsMeta.get_attrs(),
            },
        ),
    ],
)
def test_query_params(
    get_query_file_path: Callable[[], str],
    format_params: dict,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        prepare_env(monkeypatch)
        query = Path(get_query_file_path()).read_text(encoding='utf-8')
        for key in format_params:
            assert f'{{{key}}}' in query


def prepare_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setattr(
        target=RootPath,
        name='get_cwd',
        value=lambda: getcwd() + '/sql_queries',
    )
