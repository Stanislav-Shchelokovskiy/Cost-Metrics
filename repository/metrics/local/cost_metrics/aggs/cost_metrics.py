from collections.abc import Mapping
from toolbox.sql_async import MetricAsyncQueryDescriptor
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from repository.metrics.local.generators import cost_metrics, generate_groupby
from repository.metrics.local.cost_metrics.aggs.metric_aggs import get_metric
from sql_queries.meta import CostMetrics


# yapf: disable
class CostMetricsAggsQueryDescriptor(MetricAsyncQueryDescriptor):

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        period_field, agg_field, agg_name, *_ = self.get_fields(kwargs)
        metric = get_metric(metric=kwargs['metric'], role=kwargs['role'])
        groupby = generate_groupby(groupby_format=kwargs['group_by_period'])
        return {
            'select': f"{groupby.expression} AS {period_field}, {metric} AS {agg_field}, '{metric.get_display_name()}' AS {agg_name}",
            'from':  CostMetrics.get_name(),
            'where_group_limit': build_multiline_string_ignore_empties(
                (
                    cost_metrics.generate_filter(kwargs),
                    groupby.statement,
                )
            )
        }
# yapf: enable
