import os
from toolbox.utils.converters import JSON_to_object, Object_to_JSON
import toolbox.utils.network as network


def _get_emps_response(
    method: str,
    params: dict[str, str],
) -> str:
    return network.get_data(
        end_point=os.environ['EMPS_ENDPOINT'] + method,
        headers={
            'X-ApplicationId': os.environ['EMPS_APPID'],
            'X-UserId': os.environ['EMPS_USERID'],
            'User-Agent': 'CostMetrics',
        },
        params=params,
    ).replace('":', '": ')


def get_employees() -> str:
    return _get_emps_response(
        method='employees',
        params={
            'expandDetails': True,
            'expandDataForAnalytics': True,
            'type': 'ActiveOrRetired',
        },
    )


def get_employees_audit(employees_json: str) -> tuple[str]:
    emps = JSON_to_object.convert(employees_json)
    emps = emps['page']
    audit = []
    for emp in emps:
        emp_audit = _get_emps_response(
            method='audit-employees',
            params={'email': emp['email']},
        )
        audit.extend(JSON_to_object.convert(emp_audit))
    return employees_json, Object_to_JSON.convert(audit)
