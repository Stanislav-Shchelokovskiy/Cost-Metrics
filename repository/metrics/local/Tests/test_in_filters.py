import pytest
import repository.metrics.local.generators.employees as employees
from sql_queries.meta import CostMetrics


# yapf: disable
@pytest.mark.parametrize(
    'generator, field, param_name, values_converter', [
        (
            employees.generate_teams_filter,
            CostMetrics.team,
            'teams',
            None,
        ),
        (
            employees.generate_tribes_filter,
            CostMetrics.tribe_id,
            'tribes',
            None,
        ),
        (
            employees.generate_tents_filter,
            CostMetrics.tent_id,
            'tents',
            None,
        ),
        (
            employees.generate_positions_filter,
            CostMetrics.position_id,
            'positions',
            None,
        ),
        (
            employees.generate_employees_filter,
            CostMetrics.emp_scid,
            'employees',
            None,
        ),
    ]
)
def test_single_in_filters(
    generator,
    field: str,
    param_name: str,
    values_converter,
    single_in_filter_cases,
):
    for values, output in single_in_filter_cases(values_converter, prefix='AND'):
        print(values)
        assert generator(**{param_name: values}) == output.format(field=field)
