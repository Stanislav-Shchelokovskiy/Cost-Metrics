from collections.abc import Iterable
from toolbox.sql.repository_queries import RepositoryAlchemyQueries
import sql_queries.index as index
from sql_queries.meta import (
    WorkOnHolidaysMeta,
)


class WorkOnHolidaysQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return index.get_upsert_work_on_holidays()

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {
            **kwargs,
            **WorkOnHolidaysMeta.get_attrs(),
        }
