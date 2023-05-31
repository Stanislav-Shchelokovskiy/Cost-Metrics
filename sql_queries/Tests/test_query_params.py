import pytest
from os import getcwd
import toolbox.sql.index as RootPath
from sql_queries.index import remote_paths_index
from sql_queries.index import transform_load_paths_index
from sql_queries.index import local_paths_index
from pathlib import Path
from sql_queries.meta.cost_metrics import (
    WorkOnHolidaysMeta,
    CostmetricsMeta,
)


@pytest.mark.parametrize(
    'get_query_file_path, format_params',
    [
        (
            remote_paths_index.WF.upsert_work_on_holidays,
            {
                'values': '(qwe, 2, 3)',
                **WorkOnHolidaysMeta.get_attrs(),
            },
        ),
        (
            remote_paths_index.CostMetrics.cost_metrics_prep,
            {
                'start': 'start',
                'end': 'end',
            },
        ),
        (
            remote_paths_index.CostMetrics.cost_metrics,
            CostmetricsMeta.get_attrs(),
        ),
        (
            transform_load_paths_index.CostMetrics.cost_metrics_table,
            {
                'CostMetricsTable': 'qwe',
                **CostmetricsMeta.get_attrs(),
            },
        ),
        (
            local_paths_index.CostMetrics.cost_metrics_table,
            {
                'CostMetricsTable': 'qwe',
                **CostmetricsMeta.get_attrs(),
            },
        ),
    ],
)
def test_query_params(
    get_query_file_path: str,
    format_params: dict,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        prepare_env(monkeypatch)
        query = Path(get_query_file_path).read_text(encoding='utf-8')
        for key in format_params:
            assert f'{{{key}}}' in query


def prepare_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setattr(
        target=RootPath,
        name='get_cwd',
        value=lambda: getcwd() + '/sql_queries',
    )
