from collections.abc import Mapping
from toolbox.sql_async import AsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta import CostmetricsMeta
from sql_queries.index import local_names_index
from sql_queries.index import local_paths_index


# yapf: disable
class CostMetricsQueryDescriptor(AsyncQueryDescriptor):

    def get_path(self, kwargs: Mapping) -> str:
        return local_paths_index.get_cost_metrics_table_path()

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return CostmetricsMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'CostMetricsTable': local_names_index.get_cost_metrics_table_name(),
        }
