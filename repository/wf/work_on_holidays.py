from toolbox.sql.repository_queries import RepositoryAlchemyQueries
from sql_queries.index import remote_paths_index
from sql_queries.meta import (
    WorkOnHolidaysMeta,
)


class WorkOnHolidaysQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.get_upsert_work_on_holidays()

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {
            **kwargs,
            **WorkOnHolidaysMeta.get_attrs(),
        }
