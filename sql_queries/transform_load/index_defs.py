from sql_queries.index import local_names_index
from sql_queries.meta import CostMetrics, Employees
import toolbox.sql.generators.sqlite.statements as sqlite_index


def get_create_index_statements() -> dict[str, tuple[str]]:
    return {
        local_names_index.CostMetrics.cost_metrics:
            (
                sqlite_index.create_index(
                    tbl=local_names_index.CostMetrics.cost_metrics,
                    cols=CostMetrics.get_index_fields(),
                ),
            ),
        local_names_index.CostMetrics.employees:
            (
                sqlite_index.create_index(
                    tbl=local_names_index.CostMetrics.employees,
                    cols=Employees.get_index_fields(),
                    unique=True,
                ),
            )
    }
