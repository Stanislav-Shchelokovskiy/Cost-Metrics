import asyncio
import json
from repository.metrics.local.cost_metrics.aggs.metric_aggs import is_authorized_metric


async def authorize_state_access(
    role: str,
    state: str | None,
    default: str,
) -> str:
    if state:

        def authorize_metric_access(role: str, state: str | None, ) -> str:

            def try_get_metric(obj: dict[str, dict]):
                for v in obj.values():
                    if metric := v.get('metric', None):
                        return metric
                    return try_get_metric(v)

            state_obj = json.loads(state)
            metric =  try_get_metric(state_obj)
            return is_authorized_metric(metric=metric, role=role)

        loop = asyncio.get_running_loop()
        authorized = await loop.run_in_executor(None, authorize_metric_access, role, state)
        if authorized:
            return state

    return default
