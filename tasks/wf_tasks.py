import os
import json
from collections.abc import Iterable, Callable
import toolbox.utils.network as network
from toolbox.utils.converters import DateTimeToSqlString
from repository import WfRepository


def _get_wf_response(
    method: str,
    params: dict[str, str],
) -> str:
    return network.get_data(
        end_point=os.environ['WF_ENDPOINT'] + method,
        headers={
            os.environ['WF_LOGIN_HEADER']: os.environ['WF_LOGIN'],
            os.environ['WF_LOGIN_PASSWORD']: os.environ['WF_PASSWORD'],
            'User-Agent': 'CostMetrics',
        },
        params=params,
    )


def _get_wf_hours(start: str, end: str) -> str:
    return _get_wf_response(
        method='GetDayAppointmentAnalysis',
        params={
            'start': start,
            'end': end,
        },
    )


def upsert_work_hours(start: str, end: str):
    wf_hours_json = _get_wf_hours(start, end)
    wf_hours = json.loads(wf_hours_json)
    _upsert_work_on_holidays(wf_hours)
    _upsert_proactive_hours(wf_hours)


def _upsert_work_on_holidays(wf_hours: Iterable):
    values = __get_values(
        wf_hours,
        'hours',
        lambda item: item['isHoliday'] == 1 and item['hours'] > 0,
    )
    if values:
        WfRepository.work_on_holidays.update_data(values=values)


def _upsert_proactive_hours(wf_hours: Iterable):
    values = __get_values(
        wf_hours,
        'proactiveHours',
        lambda item: item['proactiveHours'] > 0,
    )
    if values:
        WfRepository.proactive_hours.update_data(values=values)


def __get_values(wf_hours: Iterable, field: str, filter: Callable[..., bool]):
    return ','.join(
        str(
            (
                item['resourceID'],
                DateTimeToSqlString.convert_from_utcstring(item['date']),
                item[field],
            )
        ) for item in wf_hours if filter(item)
    )
