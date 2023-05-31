from sql_queries.meta import CostmetricsMeta
from toolbox.sql.generators.filter_clause_generator_factory import SqlFilterClauseFromFilterParametersGeneratorFactory


def generate_year_month_filter(
    range_start: str,
    range_end: str,
    filter_prefix: str = 'WHERE',
) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_right_halfopen_interval_filter_generator(True)
    return generate_filter(
        col=CostmetricsMeta.year_month,
        values=(range_start, range_end),
        filter_prefix=filter_prefix,
    )
