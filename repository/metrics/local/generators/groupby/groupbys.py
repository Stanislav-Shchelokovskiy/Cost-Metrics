from typing import NamedTuple
from collections.abc import Sequence
from sql_queries.meta.cost_metrics import CostmetricsMeta
import toolbox.sql.generators.sqlite.periods_generator as periods_generator


class GroupBy(NamedTuple):
    expression: str
    statement: str


def generate_groupby(
    groupby_format: str,
    agg_bys: Sequence[str] = tuple(),
) -> GroupBy:
    groupby_period_expression = periods_generator.generate_group_by_period(
        format=groupby_format,
        field=CostmetricsMeta.year_month,
    )
    agg_bys = f', {", ".join(agg_bys)}' if agg_bys else ''
    return GroupBy(
        groupby_period_expression,
        f'GROUP BY {groupby_period_expression}' + agg_bys,
    )
