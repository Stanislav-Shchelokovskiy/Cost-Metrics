import pytest
from os import getcwd
import toolbox.sql.index as RootPath
from sql_queries.index import remote_paths_index
from pathlib import Path
from sql_queries.meta import (
    WF,
    CostMetrics,
)


@pytest.mark.parametrize(
    'get_query_file_path, format_params',
    [
        (
            remote_paths_index.WF.upsert_wf_hours,
            {
                'values': '(qwe, 2, 3)',
                'target': 'target',
                **WF.get_attrs(),
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
            CostMetrics.get_attrs(),
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
        query.format(**format_params)


def prepare_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setattr(
        target=RootPath,
        name='get_cwd',
        value=lambda: getcwd() + '/sql_queries',
    )
