from collections.abc import Iterable, Callable, Mapping
from sql_queries.meta.cost_metrics import CostmetricsMeta
from repository.metrics.local.generators.groupby.groups import (
    AggBy,
    tribe_group,
    chapter_group,
)


def __get_window(group: Callable[[str], str]):
    return f'PARTITION BY {group(CostmetricsMeta.year_month)}'


windows = {
    AggBy.tribe: __get_window(tribe_group),
    AggBy.chapter: __get_window(chapter_group),
}


def get_windows() -> Mapping[str, str]:
    return windows


def get_windows_names() -> Iterable[str]:
    return windows.keys()
