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
            'User-Agent': 'CostMetrics',
        },
        params=params,
    )


def get_employees(start: str, **kwargs) -> str:
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
