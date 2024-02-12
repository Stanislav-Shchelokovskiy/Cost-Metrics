import pytest
from os import getcwd
import toolbox.sql.index as RootPath
from sql_queries.index import remote_paths_index
from pathlib import Path
from sql_queries.meta import CostMetrics


@pytest.mark.parametrize(
    'get_query_file_path, format_params',
    [
        (
            remote_paths_index.WF.upsert_wf_hours,
            {
                'json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.employees,
            {
                'employees_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.employees_audit,
            {
                'employees_audit_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.vacations,
            {
                'vacations_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.positions,
            {
                'positions_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.locations,
            {
                'locations_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.levels,
            {
                'levels_json': 'qwe',
            },
        ),
        (
            remote_paths_index.CostMetrics.iterations,
            {
                'employees_json': 'qwe',
                'start': 'start',
                'end': 'end',
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
        (
            remote_paths_index.CostMetrics.sc_work_hours,
            {
                'employees_json': 'qwe',
                'employees_positions_audit_json': 'asd',
                'start': 'start',
                'end': 'end',
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
        query.format(**format_params)


def prepare_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setattr(
        target=RootPath,
        name='get_cwd',
        value=lambda: getcwd() + '/sql_queries',
    )
