from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import KnotMeta
from sql_queries.index import local_names_index


# yapf: disable
class TribesQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return KnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': f'{KnotMeta.name} AS {KnotMeta.name}, {KnotMeta.name} AS {KnotMeta.id}',
            'from': local_names_index.CostMetrics.tribes,
            'where_group_limit': '',
        }
