from sql_queries.meta.cost_metrics import CostmetricsMeta, CostmetricsEmployeesMeta
from toolbox.sql.generators.utils import build_filter_string
from toolbox.sql.generators.filter_clause_generator_factory import (
    FilterParametersNode,
    SqlFilterClauseFromFilterParametersGeneratorFactory,
    params_guard,
)


# yapf: disable
@params_guard
def generate_teams_filter(
    teams: FilterParametersNode,
    col: str = CostmetricsMeta.team,
    filter_prefix: str = 'AND',
) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(teams)
    return generate_filter(
        col=col,
        values=teams.values,
        filter_prefix=filter_prefix,
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
def generate_tents_filter(
    tents: FilterParametersNode,
    col: str = CostmetricsMeta.tent_name,
    filter_prefix: str = 'AND',
) -> str:
    generate_filter = SqlFilterClauseFromFilterParametersGeneratorFactory.get_in_filter_generator(tents)
    return generate_filter(
        col=col,
        values=tents.values,
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
        col=CostmetricsMeta.emp_crmid,
        values=employees.values,
        filter_prefix='AND',
    )
# yapf: enable


@params_guard
def generate_emps_filter(
    teams: FilterParametersNode,
    tribes: FilterParametersNode,
    tents: FilterParametersNode,
    positions: FilterParametersNode,
) -> str:
    teams_filter = generate_teams_filter(
        teams=teams,
        col=CostmetricsEmployeesMeta.team,
        filter_prefix='WHERE'
    )

    tribes_filter = generate_tribes_filter(
        tribes=tribes,
        col=CostmetricsEmployeesMeta.tribe,
        filter_prefix=__and_or_where(teams_filter)
    )

    tents_filter = generate_tents_filter(
        tents=tents,
        col=CostmetricsEmployeesMeta.tent,
        filter_prefix=__and_or_where(teams_filter + tribes_filter)
    )

    positions_filter = generate_positions_filter(
        positions=positions,
        col=CostmetricsEmployeesMeta.position,
        filter_prefix=__and_or_where(teams_filter + tribes_filter + tents_filter)
    )
    return build_filter_string(
        (
            teams_filter,
            tribes_filter,
            tents_filter,
            positions_filter,
        )
    )


def __and_or_where(current_filter):
    return 'AND' if current_filter else 'WHERE'
