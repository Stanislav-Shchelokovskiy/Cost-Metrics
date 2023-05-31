from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
import repository.metrics.local.generators.cost_metrics as cost_metrics
import toolbox.sql.generators.sqlite_periods_generator as periods_generator


class TmpMeta(MetaData):
    year_month = CostmetricsMeta.year_month
    sc_hours = CostmetricsMeta.sc_hours


# yapf: disable
class CostMetricsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return TmpMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        group_field, agg_field, *_ = self.get_fields(kwargs)
        group_by_expression = periods_generator.generate_group_by_period(
            format=kwargs['group_by_period'],
            field=group_field,
        )
        return {
            'select': f'{group_by_expression} AS {group_field}, SUM({agg_field}) AS {agg_field}',
            'from':  local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': build_multiline_string_ignore_empties(
                (
                    cost_metrics.generate_filter(kwargs),
                    f'GROUP BY {group_by_expression}, {CostmetricsMeta.team}',
                )
            )
        }


def get_chapter_groupby(group_by_period: str) -> str:
    groupby_period_expression = periods_generator.generate_group_by_period(
        format=group_by_period,
        field=CostmetricsMeta.year_month,
    )
    return f'GROUP BY {groupby_period_expression}, {CostmetricsMeta.team}',

def get_tribe_groupby(group_by_period: str) -> str:
    return get_chapter_groupby(group_by_period) + f', {CostmetricsMeta.emp_tribe_name}'

def get_employee_group_by(group_by_period: str) -> str:
    return get_tribe_groupby(group_by_period) + f', {CostmetricsMeta.position_name}, {CostmetricsMeta.emp_name}'
# yapf: enable
