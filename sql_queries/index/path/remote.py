import toolbox.sql.index as RootPath


_root_path = RootPath.get_cwd() + '/remote'
_cost_path = _root_path + '/cost'
_wf_path = _root_path + '/wf'


class CostMetrics:
    sc_work_hours = _cost_path + '/sc_work_hours.sql'
    iterations_raw = _cost_path + '/iterations_raw.sql'
    parse_employees = _cost_path + '/employees.sql'
    parse_employees_audit = _cost_path + '/employees_audit.sql'
    parse_vacations = _cost_path + '/vacations.sql'
    parse_positions = _cost_path + '/positions.sql'
    parse_locations = _cost_path + '/locations.sql'
    parse_levels = _cost_path + '/levels.sql'

    __metrics = _cost_path + '/metrics/'
    months = __metrics + 'months.sql'
    vacations = __metrics + 'vacations.sql'
    employees = __metrics + 'employees.sql'
    iterations = __metrics + 'iterations.sql'
    cost_metrics = __metrics + 'cost_metrics.sql'


class WF:
    upsert_wf_hours = _wf_path + '/upsert_wf_hours.sql'
