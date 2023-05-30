import toolbox.sql.index as RootPath


def _get_root_path() -> str:
    return RootPath.get_cwd() + '/remote'


def _get_cost_path() -> str:
    return _get_root_path() + '/cost'


def _get_wf_path() -> str:
    return _get_root_path() + '/wf'


class CostMetrics:
    cost_metrics_prep = _get_cost_path() + '/cost_metrics_prep.sql'
    cost_metrics = _get_cost_path() + '/cost_metrics.sql'


class WF:
    upsert_work_on_holidays = _get_wf_path() + '/upsert_work_on_holidays.sql'
