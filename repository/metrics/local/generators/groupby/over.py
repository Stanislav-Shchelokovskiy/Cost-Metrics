from collections.abc import Iterable, Callable
from typing import NamedTuple
from toolbox.sql import MetaData, KnotMeta
from sql_queries.meta.cost_metrics import CostmetricsMeta
import toolbox.sql.generators.sqlite_periods_generator as periods_generator
from sql_queries.index import local_names_index
from repository.metrics.local.generators.groupby.groups import (
    AggBy,
    tribe_group,
    chapter_group,
)


def get_over(group: Callable[[str], str]):

    def over(period_expression: str):
        return f'OVER (PARTITION BY {group(period_expression)})'

    return over


overs = {
    AggBy.tribe: get_over(tribe_group),
    AggBy.chapter: get_over(chapter_group),
}


def get_overs_names() -> Iterable[str]:
    return overs.keys()
