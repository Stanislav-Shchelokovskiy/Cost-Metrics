import toolbox.sql.index as RootPath


def _get_root_path() -> str:
    return RootPath.get_cwd() + '/remote'


def _get_cost_path() -> str:
    return _get_root_path() + '/cost'


def _get_wf_path() -> str:
    return _get_root_path() + '/wf'


class CostMetrics:
    employees_audit = _get_cost_path() + '/employees_audit.sql'
    cost_metrics_prep = _get_cost_path() + '/cost_metrics_prep.sql'
    cost_metrics = _get_cost_path() + '/cost_metrics.sql'


class WF:
    upsert_wf_hours = _get_wf_path() + '/upsert_wf_hours.sql'
