from sql_queries.meta.cost_metrics import CostmetricsMeta, CostmetricsEmployeesMeta
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
def generate_tribes_filter(
    tribes: FilterParametersNode,
    col: str = CostmetricsMeta.tribe_name,
    filter_prefix: str = 'AND',
) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(tribes)
    return generate_filter(
        col=col,
        values=tribes.values,
        filter_prefix=filter_prefix,
    )


@params_guard
def generate_positions_filter(
    positions: FilterParametersNode,
    col: str = CostmetricsMeta.position_name,
    filter_prefix: str = 'AND',
) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(positions)
    return generate_filter(
        col=col,
        values=positions.values,
        filter_prefix=filter_prefix,
    )


@params_guard
def generate_employees_filter(employees: FilterParametersNode) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(employees)
    return generate_filter(
        col=CostmetricsMeta.name,
        values=employees.values,
        filter_prefix='AND',
    )


@params_guard
def generate_tribes_positions_filter(
    tribes: FilterParametersNode,
    positions: FilterParametersNode,
) -> str:
    tribes_filter = generate_tribes_filter(
        tribes=tribes,
        col=CostmetricsEmployeesMeta.tribe,
        filter_prefix='WHERE'
    )
    positions_filter = generate_positions_filter(
        positions=positions,
        col=CostmetricsEmployeesMeta.position,
        filter_prefix=' AND' if tribes_filter else 'WHERE'
    )
    return tribes_filter + positions_filter
