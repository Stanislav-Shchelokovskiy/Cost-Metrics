from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import NameKnotMeta
from sql_queries.index import local_names_index


# yapf: disable
class PositionsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return NameKnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': NameKnotMeta.name,
            'from': local_names_index.CostMetrics.positions,
            'where_group_limit': '',
        }
