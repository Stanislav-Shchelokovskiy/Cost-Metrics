import toolbox.sql.index as RootPath


def get_root_path() -> str:
    return RootPath.get_cwd() + '/remote'


def get_cost_path() -> str:
    return get_root_path() + '/cost'


def get_wf_path() -> str:
    return get_root_path() + '/wf'


def get_cost_metrics_path() -> str:
    return get_cost_path() + '/cost_metrics.sql'


def get_upsert_work_on_holidays() -> str:
    return get_wf_path() + '/upsert_work_on_holidays.sql'
