import toolbox.sql.index as RootPath


def __get_root_path() -> str:
    return RootPath.get_cwd() + '/transform_load'


def __get_cost_path() -> str:
    return __get_root_path() + '/cost'


def __get_cost_tables_path() -> str:
    return __get_cost_path() + '/tables'


def get_cost_metrics_table_path() -> str:
    return __get_cost_tables_path() + '/cost_metrics.sql'
