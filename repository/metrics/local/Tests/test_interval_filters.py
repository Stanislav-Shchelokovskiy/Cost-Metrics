import pytest
import repository.metrics.local.generators.common as common
from sql_queries.meta import CostMetrics


@pytest.mark.parametrize(
    'kwargs, output', [
        (
            {
                'range_start': 'qwe',
                'range_end': 'asd',
            },
            f"WHERE 'qwe' <= {CostMetrics.year_month} AND {CostMetrics.year_month} < 'asd'",
        ),
        (
            {
                'range_start': 'qwe',
                'range_end': 'asd',
                'filter_prefix': 'AND',
            },
            f"AND 'qwe' <= {CostMetrics.year_month} AND {CostMetrics.year_month} < 'asd'",
        ),
    ]
)
def test_generate_year_month_filter(
    kwargs: dict,
    output,
):
    assert common.generate_year_month_filter(**kwargs) == output
