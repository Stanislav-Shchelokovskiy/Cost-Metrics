from collections.abc import Mapping
from toolbox.sql_async import AsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta import NameKnotMeta
from sql_queries.index import local_names_index
from sql_queries.index import local_paths_index


# yapf: disable
class TribesQueryDescriptor(AsyncQueryDescriptor):

    def get_path(self, kwargs: Mapping) -> str:
        return local_paths_index.get_general_select_path()

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return NameKnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'columns': NameKnotMeta.name,
            'table_name': local_names_index.get_cost_metrics_tribes_name(),
            'filter_group_limit_clause': '',
        }
