from toolbox.sql.sql_query import SqlQuery
from sql_queries.index import transform_load_paths_index
from sql_queries.index import local_names_index
from sql_queries.meta import (
    CostmetricsMeta,
)


def get_create_table_statements() -> dict[str, str]:
    return __create_table_statements


# yapf: disable
__create_table_statements = {
    local_names_index.CostMetrics.cost_metrics:
        SqlQuery(
            query_file_path=transform_load_paths_index.CostMetrics.cost_metrics_table,
            format_params={
                'CostMetricsTable': 'CostMetrics',
                **CostmetricsMeta.get_attrs(),
            },
        ).get_script(),
}
