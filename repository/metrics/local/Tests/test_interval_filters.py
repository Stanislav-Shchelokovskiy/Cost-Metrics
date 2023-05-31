import pytest
import repository.metrics.local.generators.common as common
from sql_queries.meta.cost_metrics import CostmetricsMeta


@pytest.mark.parametrize(
    'kwargs, output', [
        (
            {
                'range_start': 'qwe',
                'range_end': 'asd',
            },
            f"WHERE 'qwe' <= {CostmetricsMeta.year_month} AND {CostmetricsMeta.year_month} < 'asd'",
        ),
        (
            {
                'range_start': 'qwe',
                'range_end': 'asd',
                'filter_prefix': 'AND',
            },
            f"AND 'qwe' <= {CostmetricsMeta.year_month} AND {CostmetricsMeta.year_month} < 'asd'",
        ),
    ]
)
def test_generate_year_month_filter(
    kwargs: dict,
    output,
):
    assert common.generate_year_month_filter(**kwargs) == output
