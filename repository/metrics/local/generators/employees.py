from sql_queries.meta.cost_metrics import CostmetricsMeta
from toolbox.sql.generators.filter_clause_generator_factory import (
    FilterParametersNode,
    SqlFilterClauseFromFilterParametersGeneratorFactory,
    params_guard,
)


@params_guard
def generate_teams_filter(teams: FilterParametersNode) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(teams)
    return generate_filter(
        col=CostmetricsMeta.team,
        values=teams.values,
        filter_prefix='AND',
    )


@params_guard
def generate_tribes_filter(tribes: FilterParametersNode) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(tribes)
    return generate_filter(
        col=CostmetricsMeta.tribe_name,
        values=tribes.values,
        filter_prefix='AND',
    )


@params_guard
def generate_positions_filter(positions: FilterParametersNode) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(positions)
    return generate_filter(
        col=CostmetricsMeta.position_name,
        values=positions.values,
        filter_prefix='AND',
    )


@params_guard
def generate_employees_filter(employees: FilterParametersNode) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(employees)
    return generate_filter(
        col=CostmetricsMeta.name,
        values=employees.values,
        filter_prefix='AND',
    )
