import pytest
import repository.metrics.local.generators.employees as employees
from sql_queries.meta.cost_metrics import CostmetricsMeta


# yapf: disable
@pytest.mark.parametrize(
    'generator, field, param_name, values_converter', [
        (
            employees.generate_teams_filter,
            CostmetricsMeta.team,
            'teams',
            None,
        ),
        (
            employees.generate_tribes_filter,
            CostmetricsMeta.tribe_name,
            'tribes',
            None,
        ),
        (
            employees.generate_tents_filter,
            CostmetricsMeta.tent_name,
            'tents',
            None,
        ),
        (
            employees.generate_positions_filter,
            CostmetricsMeta.position_name,
            'positions',
            None,
        ),
        (
            employees.generate_employees_filter,
            CostmetricsMeta.emp_crmid,
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
