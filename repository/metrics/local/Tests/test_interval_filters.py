import pytest
import repository.metrics.local.generators.common as common
from sql_queries.meta import CostMetrics


@pytest.mark.parametrize(
    'field, generator, values_converter', [
        (
            CostMetrics.year_month,
            common.generate_year_month_filter,
            None,
        ),
        (
            CostMetrics.year_month,
            common.generate_year_month_filter,
            None,
        ),
    ]
)
def test_generate_year_month_filter(
    field: str,
    generator,
    values_converter,
    right_half_open_interval_filter_cases,
):
    for values, output in right_half_open_interval_filter_cases(values_converter, prefix='WHERE'):
        assert generator(values) == output.format(field=field)
