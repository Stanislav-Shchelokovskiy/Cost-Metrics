from toolbox.sql import MetaData
from sql_queries.meta import CostMetrics


class AggBy(MetaData):
    employee = 'Employee'
    tribe = 'Tribe'
    tent = 'Tent'
    chapter = 'Chapter'


# yapf: disable
def chapter_group(period_expression: str) -> str:
    return f'{period_expression}, {CostMetrics.team}'

def tribe_group(period_expression: str) -> str:
    return chapter_group(period_expression) + f', {CostMetrics.tribe_id}'

def tent_group(period_expression: str) -> str:
    return tribe_group(period_expression) + f', {CostMetrics.tent_id}'

def employee_group(period_expression: str) -> str:
    return tent_group(period_expression) + f', {CostMetrics.position_id}, {CostMetrics.emp_scid}, {CostMetrics.name}'
