from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import CostmetricsMeta, CostmetricsEmployeesMeta
import toolbox.sql.generators.sqlite.index as sqlite_index


def get_create_index_statements() -> dict[str, tuple[str]]:
    return {
        local_names_index.CostMetrics.cost_metrics:
            (
                sqlite_index.generate_create_index_statement(
                    tbl=local_names_index.CostMetrics.cost_metrics,
                    cols=CostmetricsMeta.get_index_fields(),
                ),
                sqlite_index.generate_create_index_statement(
                    tbl=local_names_index.CostMetrics.cost_metrics,
                    cols=CostmetricsMeta.get_key_fields(),
                    unique=True,
                ),
            ),
        local_names_index.CostMetrics.employees:
            (
                sqlite_index.generate_create_index_statement(
                    tbl=local_names_index.CostMetrics.employees,
                    cols=CostmetricsEmployeesMeta.get_key_fields(),
                    unique=True,
                ),
            )
    }
