import os
import toolbox.utils.network as network
from repository import WfRepository


def _get_wf_hours(start: str, end: str) -> str:
    return network.get_data(
        end_point=os.environ["WF_ENDPOINT"],
        headers={
            os.environ["WF_LOGIN_HEADER"]: os.environ["WF_LOGIN"],
            os.environ["WF_LOGIN_PASSWORD"]: os.environ["WF_PASSWORD"],
            "User-Agent": "CostMetrics",
        },
        params={
            "start": start,
            "end": end,
        },
    ).replace('":', '": ')


def upsert_work_hours(start: str, end: str):
    wf_hours_json = _get_wf_hours(start, end)
    WfRepository.wf_hours.update_data(json=wf_hours_json)
