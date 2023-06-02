from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index


class PeriodMeta(MetaData):
    start = 'start'
    end = 'end'


# yapf: disable
class PeriodQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return PeriodMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': f"MIN({CostmetricsMeta.year_month}) AS {PeriodMeta.start}, DATE(MAX({CostmetricsMeta.year_month}), '+1 months') AS {PeriodMeta.end}",
            'from': local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': '',
        }
