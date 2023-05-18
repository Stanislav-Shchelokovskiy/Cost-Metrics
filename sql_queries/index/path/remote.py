import toolbox.sql.index as RootPath


def __get_root_path() -> str:
    return RootPath.get_cwd() + '/remote'


def __get_cost_path() -> str:
    return __get_root_path() + '/cost'


def __get_wf_path() -> str:
    return __get_root_path() + '/wf'


def get_cost_metrics_prep_path() -> str:
    return __get_cost_path() + '/cost_metrics_prep.sql'


def get_cost_metrics_totals_path() -> str:
    return __get_cost_path() + '/cost_metrics_totals.sql'


def get_upsert_work_on_holidays() -> str:
    return __get_wf_path() + '/upsert_work_on_holidays.sql'
