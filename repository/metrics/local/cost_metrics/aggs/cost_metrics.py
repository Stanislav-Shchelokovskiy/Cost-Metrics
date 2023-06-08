from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
from repository.metrics.local.generators import cost_metrics, generate_groupby
from repository.metrics.local.cost_metrics.aggs.metric_aggs import get_metric
from repository.metrics.local.generators.groupby.groups import AggBy


class CostmetricsAggMeta(MetaData):
    year_month = CostmetricsMeta.year_month
    agg = 'agg'
    name = 'name'


# yapf: disable
class CostMetricsAggsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return CostmetricsAggMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        period_field, agg_field, agg_name, *_ = self.get_fields(kwargs)
        groupby = generate_groupby(
            groupby_format=kwargs['group_by_period'],
            agg_by=AggBy.chapter
        )
        metric = get_metric(metric=kwargs['metric'], mode=kwargs['mode'])
        return {
            'select': f'{groupby.expression} AS {period_field}, {metric} AS {agg_field}, {groupby.aggName} AS {agg_name}',
            'from':  local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': build_multiline_string_ignore_empties(
                (
                    cost_metrics.generate_filter(kwargs),
                    groupby.statement,
                )
            )
        }
# yapf: enable
