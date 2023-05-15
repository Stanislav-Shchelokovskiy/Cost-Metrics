from typing import Iterable
from toolbox.sql.repository_queries import RepositoryAlchemyQueries
import sql_queries.index as index


class CostMetrics(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return index.get_cost_metrics_path()

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {}

    def get_must_have_columns(self, **kwargs) -> Iterable[str]:
        return []