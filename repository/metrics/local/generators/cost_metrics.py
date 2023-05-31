from toolbox.sql.generators.utils import build_filter_string
import repository.metrics.local.generators.employees as employees
import repository.metrics.local.generators.common as common


def generate_filter(kwargs: dict) -> str:
    return build_filter_string(
        (
            common.generate_year_month_filter(
                range_start=kwargs['range_start'],
                range_end=kwargs['range_end']
            ),
            employees.generate_teams_filter(teams=kwargs['teams']),
            employees.generate_tribes_filter(tribes=kwargs['tribes']),
            employees.generate_positions_filter(positions=kwargs['positions']),
            employees.generate_employees_filter(employees=kwargs['employees']),
        )
    )
