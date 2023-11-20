from sql_queries.meta import CostMetrics
from toolbox.sql.generators.filter_clause_generator_factory import (
    FilterParametersNode,
    SqlFilterClauseFromFilterParametersGeneratorFactory as filter_factory,
)


def generate_year_month_filter(
    range: FilterParametersNode,
    filter_prefix: str = 'WHERE',
) -> str:
    generate_filter = filter_factory.get_right_halfopen_interval_filter_generator(range)
    return generate_filter(
        col=CostMetrics.year_month,
        values=range.values,
        filter_prefix=filter_prefix,
    )
