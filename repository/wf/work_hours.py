from toolbox.sql.repository_queries import RepositoryAlchemyQueries
from sql_queries.index import remote_paths_index


class WFHoursQueries(RepositoryAlchemyQueries):

    def get_main_query_path(self, **kwargs) -> str:
        return remote_paths_index.WF.upsert_wf_hours

    def get_main_query_format_params(self, **kwargs) -> dict[str, str]:
        return kwargs
