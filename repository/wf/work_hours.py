from toolbox.sql.repository_queries import RepositoryAlchemyQueries
from sql_queries.index import remote_paths_index
from sql_queries.index import remote_names_index
from sql_queries.meta.cost_metrics import (
    WFMeta,
)


class WorkOnHolidaysQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.WF.upsert_wf_hours

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {
            **kwargs,
            **WFMeta.get_attrs(),
            'target': remote_names_index.WF.work_on_holidays,
        }


class ProactiveHoursQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.WF.upsert_wf_hours

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return {
            **kwargs,
            **WFMeta.get_attrs(),
            'target': remote_names_index.WF.proactive_hours,
        }
