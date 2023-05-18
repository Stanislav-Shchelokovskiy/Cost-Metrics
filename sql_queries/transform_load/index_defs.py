from typing import Iterable
from sql_queries.index import local_names_index
from sql_queries.meta import CostmetricsMeta


def _create_index_statement(
    tbl: str,
    cols: Iterable[str],
    unique: bool = False,
) -> str:
    unq = 'UNIQUE' if unique else ''
    return f'CREATE {unq} INDEX IF NOT EXISTS idx_{tbl}_{"_".join(cols)} ON {tbl}({",".join(cols)});'


def get_create_index_statements() -> dict[str, tuple[str]]:
    return {
        local_names_index.get_cost_metrics_table_name():
            (
                _create_index_statement(
                    tbl=local_names_index.get_cost_metrics_table_name(),
                    cols=CostmetricsMeta.get_key_fields(),
                    unique=True,
                ),
            )
    }
