from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData, KnotMeta
from sql_queries.index import local_names_index


# yapf: disable
class PositionsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return KnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': KnotMeta,
            'from': local_names_index.CostMetrics.positions,
            'where_group_limit': f'ORDER BY {KnotMeta.name}',
        }
