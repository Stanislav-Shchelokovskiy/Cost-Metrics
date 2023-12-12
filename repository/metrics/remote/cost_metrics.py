from typing import Iterable
from toolbox.sql.repository_queries import RepositoryAlchemyQueries
from toolbox.sql.sql_query import SqlAlchemyQuery
from sql_queries.index import remote_paths_index
from sql_queries.meta import CostMetrics


class CostMetricsQueries(RepositoryAlchemyQueries):

    def get_prep_queries(self, **kwargs) -> Iterable[SqlAlchemyQuery]:
        return (
            SqlAlchemyQuery(
                query_file_path=remote_paths_index.CostMetrics.sc_work_hours,
                format_params=kwargs,
            ),
            SqlAlchemyQuery(
                query_file_path=remote_paths_index.CostMetrics.employees,
                format_params=kwargs,
            ),
            SqlAlchemyQuery(
                query_file_path=remote_paths_index.CostMetrics.employees_audit,
                format_params=kwargs,
            ),
            SqlAlchemyQuery(
                query_file_path=remote_paths_index.CostMetrics.cost_metrics_prep,
                format_params=kwargs,
            ),
        )

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.CostMetrics.cost_metrics

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return CostMetrics.get_attrs()
