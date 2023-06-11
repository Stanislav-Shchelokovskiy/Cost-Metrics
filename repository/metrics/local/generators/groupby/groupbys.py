from collections.abc import Callable
from typing import NamedTuple
from toolbox.sql import KnotMeta
from sql_queries.meta.cost_metrics import CostmetricsMeta
import toolbox.sql.generators.sqlite_periods_generator as periods_generator
from sql_queries.index import local_names_index
from repository.metrics.local.generators.groupby.groups import (
    AggBy,
    employee_group,
    tribe_group,
    chapter_group,
)


def get_groupby(group: Callable[[str], str]):

    def groupby(period_expression: str):
        return f'GROUP BY {group(period_expression)}'

    return groupby


# yapf: disable
group_bys = {
    AggBy.employee: (
        get_groupby(employee_group),
        CostmetricsMeta.name,
    ),
    AggBy.tribe: (
        get_groupby(tribe_group),
        CostmetricsMeta.tribe_name,
    ),
    AggBy.chapter: (
        get_groupby(chapter_group),
        f'(SELECT {KnotMeta.name} FROM {local_names_index.CostMetrics.teams} WHERE {KnotMeta.id} = {CostmetricsMeta.team} LIMIT 1)',
    ),
    '': (
        get_groupby(lambda x: x),
        '""',
    )
}
# yapf: enable


class GroupBy(NamedTuple):
    expression: str
    statement: str
    aggName: str


def generate_groupby(groupby_format: str, agg_by: str = '') -> GroupBy:
    groupby_period_expression = periods_generator.generate_group_by_period(
        format=groupby_format,
        field=CostmetricsMeta.year_month,
    )
    group_by, aggName = group_bys[agg_by]
    return GroupBy(
        groupby_period_expression,
        group_by(groupby_period_expression),
        aggName,
    )
