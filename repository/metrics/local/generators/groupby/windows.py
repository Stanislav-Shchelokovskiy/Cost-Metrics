from typing import NamedTuple
from collections.abc import Callable
from sql_queries.meta.cost_metrics import CostmetricsMeta
from repository.metrics.local.generators.groupby.groups import (
    AggBy,
    employee_group,
    tent_group,
    tribe_group,
    chapter_group,
)


def __get_window(group: Callable[[str], str]):
    return f'PARTITION BY {group(CostmetricsMeta.year_month)}'


class Window(NamedTuple):
    name: str
    statement: str


employee_window = Window(AggBy.employee, __get_window(employee_group))
tent_window = Window(AggBy.tent, __get_window(tent_group))
tribe_window = Window(AggBy.tribe, __get_window(tribe_group))
chapter_window = Window(AggBy.chapter, __get_window(chapter_group))
