from toolbox.sql.repository_queries import RepositoryAlchemyQueries
import sql_queries.remote_index as remote_index
from sql_queries.meta import (
    WorkOnHolidaysMeta,
)


class WorkOnHolidaysQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return remote_index.get_upsert_work_on_holidays()

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {
            **kwargs,
            **WorkOnHolidaysMeta.get_attrs(),
        }
