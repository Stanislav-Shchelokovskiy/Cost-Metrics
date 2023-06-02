from collections.abc import Iterable
from typing import NamedTuple
from toolbox.sql import MetaData, KnotMeta
from sql_queries.meta.cost_metrics import CostmetricsMeta
import toolbox.sql.generators.sqlite_periods_generator as periods_generator
from sql_queries.index import local_names_index


# yapf: disable
def get_chapter_groupby(groupby_period_expression: str) -> str:
    return f'GROUP BY {groupby_period_expression}, {CostmetricsMeta.team}'

def get_tribe_groupby(groupby_period_expression: str) -> str:
    return get_chapter_groupby(groupby_period_expression) + f', {CostmetricsMeta.tribe_name}'

def get_employee_group_by(groupby_period_expression: str) -> str:
    return get_tribe_groupby(groupby_period_expression) + f', {CostmetricsMeta.position_name}, {CostmetricsMeta.name}'
# yapf: enable


class AggBy(MetaData):
    employee = 'Employee'
    tribe = 'Tribe'
    chapter = 'Chapter'


group_bys = {
    AggBy.employee: (
        get_employee_group_by,
        CostmetricsMeta.name,
    ),
    AggBy.tribe: (
        get_tribe_groupby,
        CostmetricsMeta.tribe_name,
    ),
    AggBy.chapter: (
        get_chapter_groupby,
        f'(SELECT {KnotMeta.name} FROM {local_names_index.CostMetrics.teams} WHERE {KnotMeta.id} = {CostmetricsMeta.team} LIMIT 1)',
    ),
}


def get_groupbys() -> Iterable[str]:
    return [x for x in AggBy.get_values()]


class GroupBy(NamedTuple):
    expression: str
    statement: str
    aggName: str


def generate_groupby(groupby_format: str, agg_by: str) -> GroupBy:
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
