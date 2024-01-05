import toolbox.sql.index as RootPath


_root_path = RootPath.get_cwd() + '/remote'
_cost_path = _root_path + '/cost'
_wf_path = _root_path + '/wf'


class CostMetrics:
    sc_work_hours = _cost_path + '/sc_work_hours.sql'
    employees = _cost_path + '/employees.sql'
    employees_audit = _cost_path + '/employees_audit.sql'
    vacations = _cost_path + '/vacations.sql'
    positions = _cost_path + '/positions.sql'
    locations = _cost_path + '/locations.sql'
    levels = _cost_path + '/levels.sql'
    cost_metrics_prep = _cost_path + '/cost_metrics_prep.sql'
    cost_metrics = _cost_path + '/cost_metrics.sql'


class WF:
    upsert_wf_hours = _wf_path + '/upsert_wf_hours.sql'
