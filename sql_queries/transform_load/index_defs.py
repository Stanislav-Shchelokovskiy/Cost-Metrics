from typing import Iterable
from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import CostmetricsMeta, CostmetricsEmployeesMeta


def _create_index_statement(
    tbl: str,
    cols: Iterable[str],
    unique: bool = False,
) -> str:
    unq = 'UNIQUE' if unique else ''
    return f'CREATE {unq} INDEX IF NOT EXISTS idx_{tbl}_{"_".join(cols)} ON {tbl}({",".join(cols)});'


def get_create_index_statements() -> dict[str, tuple[str]]:
    return {
        local_names_index.CostMetrics.cost_metrics:
            (
                _create_index_statement(
                    tbl=local_names_index.CostMetrics.cost_metrics,
                    cols=CostmetricsMeta.get_key_fields(),
                    unique=True,
                ),
            ),
        local_names_index.CostMetrics.employees:
            (
                _create_index_statement(
                    tbl=local_names_index.CostMetrics.employees,
                    cols=CostmetricsEmployeesMeta.get_key_fields(),
                    unique=True,
                ),
            )
    }
