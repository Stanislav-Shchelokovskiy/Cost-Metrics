import os
import toolbox.utils.network as network
import json
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
        },
        params=params,
    )


def _get_work_on_holidays_hours(start: str, end: str) -> str:
    return _get_wf_response(
        method='GetDayAppointmentAnalysis',
        params={
            'start': start,
            'end': end,
        },
    )


def upsert_work_on_holidays(start: str, end: str):
    work_on_holydays_json = _get_work_on_holidays_hours(start, end)
    WfRepository.work_on_holidays.update_data(
        values=','.join(
            str(
                (
                    item['resourceID'],
                    DateTimeToSqlString.convert_from_utcstring(item['date']),
                    hours if (hours:= item['hours']) < 8 else 0,
                )
            ) for item in json.loads(work_on_holydays_json)
            if item['isHoliday'] == 1
        )
    )
