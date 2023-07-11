import json
from repository.metrics.local.cost_metrics.aggs.metric_aggs import is_authorized_metric


def try_get_metric(obj: dict):
    for v in obj.values():
        if metric := v.get('metric', None):
            return metric
        return try_get_metric(v)


def authorize_state_access(role: str, state: str | None) -> str:
    if state:
        state_obj = json.loads(state)
        metric = try_get_metric(state_obj)
        if is_authorized_metric(metric=metric, role=role):
            return state
    return '{}'
