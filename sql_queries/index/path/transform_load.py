import toolbox.sql.index as RootPath


def _get_root_path() -> str:
    return RootPath.get_cwd() + '/transform_load'


def _get_cost_path() -> str:
    return _get_root_path() + '/cost'


def _get_cost_tables_path() -> str:
    return _get_cost_path() + '/tables'


class CostMetrics:
    cost_metrics_table = _get_cost_tables_path() + '/cost_metrics.sql'
