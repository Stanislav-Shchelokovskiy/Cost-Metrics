from sql_queries.index import local_names_index
from sql_queries.meta import CostMetrics, Employees
import toolbox.sql.generators.sqlite.index as sqlite_index


def get_create_index_statements() -> dict[str, tuple[str]]:
    return {
        local_names_index.CostMetrics.cost_metrics:
            (
                sqlite_index.generate_create_index_statement(
                    tbl=local_names_index.CostMetrics.cost_metrics,
                    cols=CostMetrics.get_index_fields(),
                ),
            ),
        local_names_index.CostMetrics.employees:
            (
                sqlite_index.generate_create_index_statement(
                    tbl=local_names_index.CostMetrics.employees,
                    cols=Employees.get_index_fields(),
                    unique=True,
                ),
            )
    }
