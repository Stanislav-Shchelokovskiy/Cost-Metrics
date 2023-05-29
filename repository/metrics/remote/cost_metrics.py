from typing import Iterable
from toolbox.sql.repository_queries import RepositoryAlchemyQueries
from toolbox.sql.sql_query import SqlAlchemyQuery
from sql_queries.index import remote_paths_index
from sql_queries.meta import CostmetricsMeta


class CostMetricsQueries(RepositoryAlchemyQueries):

    def get_prep_queries(self, **kwargs) -> Iterable[SqlAlchemyQuery]:
        return (
            SqlAlchemyQuery(
                query_file_path=remote_paths_index.get_cost_metrics_prep_path(),
                format_params=kwargs,
            ),
        )

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.get_cost_metrics_totals_path()

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return CostmetricsMeta.get_attrs()

    def get_must_have_columns(self, **kwargs) -> Iterable[str]:
        return []