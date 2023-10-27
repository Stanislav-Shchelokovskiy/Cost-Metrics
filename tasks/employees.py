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


def get_employees_audit() -> str:
    emps = _get_emps_response(
        method='employees',
        params={
            'expandDetails': True,
            'expandDataForAnalytics': True,
        },
    )
    emps = JSON_to_object.convert(emps)
    emps = emps['page']
    audit = []
    for emp in emps:
        emp_audit = _get_emps_response(
            method='audit-employees',
            params={'email': emp['email']},
        )
        audit.extend(JSON_to_object.convert(emp_audit))
    return Object_to_JSON.convert(audit)
