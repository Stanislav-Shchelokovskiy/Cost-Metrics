from collections.abc import Mapping
from collections import ChainMap
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
from repository.metrics.local.generators import cost_metrics, generate_groupby, get_overs_names
from repository.metrics.local.cost_metrics.aggs.metric_aggs import get_metrics_names


# yapf: disable
class CostMetricsRawQueryDescriptor(GeneralSelectAsyncQueryDescriptor):
    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        if not hasattr(self, 'CostmetricsRawMeta'):
            metrics = get_metrics_names(mode = kwargs['mode'])
            attrs = {f'{over_name} {metric}': f'"{over_name} {metric}"' for metric in metrics for over_name in get_overs_names()}
            self.CostmetricsRawMeta = type('CostmetricsRawMeta', (CostmetricsMeta,), {**CostmetricsMeta.get_attrs(), **attrs})
        return self.CostmetricsRawMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        period_field, agg_field, agg_name, *_ = self.get_fields(kwargs)
        groupby = generate_groupby(
            groupby_format=kwargs['group_by_period'],
            agg_by=kwargs['agg_by']
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
