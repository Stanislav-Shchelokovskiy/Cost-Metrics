import toolbox.sql.index as RootPath


def _get_root_path() -> str:
    return RootPath.get_cwd() + '/local'


def _get_cost_path() -> str:
    return _get_root_path() + '/cost'


class CostMetrics:
    cost_metrics_table = _get_cost_path() + '/cost_metrics.sql'
