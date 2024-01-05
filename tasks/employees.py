import os
import toolbox.utils.network as network
from toolbox.utils.selectors import employees
from toolbox.utils.converters import JSON_to_object, Object_to_JSON


def _get_emps_response(
    end_point: str,
    params: dict[str, str] = {},
) -> str:
    return network.get_data(
        end_point=end_point,
        headers={
            'X-ApplicationId': os.environ['EMPS_APPID'],
            'X-UserId': os.environ['EMPS_USERID'],
            'X-API-Key': os.environ['EMPS_APIKEY'],
            'User-Agent': 'CostMetrics',
        },
        params=params,
    )


def get_employees(start: str, **_) -> str:
    emps_json = _get_emps_response(end_point=os.environ['EMPS_ENDPOINT'])
    return employees.select(emps_json=emps_json, start=start)


def get_employees_audit(employees_json: str) -> tuple[str]:
    emps = JSON_to_object.convert(employees_json)
    audit = []
    for emp in emps:
        emp_audit = _get_emps_response(
            end_point=os.environ['EMPS_AUDIT_ENDPOINT'],
            params={'email': emp['email']},
        )
        audit.extend(JSON_to_object.convert(emp_audit))
    return employees_json, Object_to_JSON.convert(audit)


def get_vacations(*passthrough, start: str, **_) -> tuple[str]:
    vacations_json = _get_emps_response(
        end_point=os.environ['EMPS_VACATIONS_ENDPOINT'],
        params={
            'IncludePartial': True,
            'StartAfter': start,
        },
    )
    return *passthrough, vacations_json


def get_positions(*passthrough) -> tuple[str]:
    positions_json = _get_emps_response(
        end_point=os.environ['EMPS_POSITIONS_ENDPOINT'],
    )
    return *passthrough, positions_json


def get_locations(*passthrough) -> tuple[str]:
    locations_json = _get_emps_response(
        end_point=os.environ['EMPS_LOCATIONS_ENDPOINT'],
    )
    return *passthrough, locations_json


def get_levels(*passthrough) -> tuple[str]:
    levels_json = _get_emps_response(
        end_point=os.environ['EMPS_LEVELS_ENDPOINT'],
    )
    return *passthrough, levels_json
