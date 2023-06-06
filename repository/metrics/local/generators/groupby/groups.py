from collections.abc import Iterable
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import CostmetricsMeta


class AggBy(MetaData):
    employee = 'Employee'
    tribe = 'Tribe'
    chapter = 'Chapter'


def get_aggbys() -> Iterable[str]:
    return [x for x in AggBy.get_values()]


# yapf: disable
def chapter_group(period_expression: str) -> str:
    return f'{period_expression}, {CostmetricsMeta.team}'

def tribe_group(period_expression: str) -> str:
    return chapter_group(period_expression) + f', {CostmetricsMeta.tribe_name}'

def employee_group(period_expression: str) -> str:
    return tribe_group(period_expression) + f', {CostmetricsMeta.position_name}, {CostmetricsMeta.name}'
