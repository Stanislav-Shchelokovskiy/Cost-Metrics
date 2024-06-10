import asyncio
from pathlib import Path
from toolbox.utils.converters import Object_to_JSON, file_to_dict
from toolbox.sql.aggs import Metric
from repository.metrics.local.cost_metrics.aggs.metric_aggs import get_metric


async def get_description(metric: str, role: str) -> str:
    metric = get_metric(metric=metric, role=role)
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, __get_description_json, metric)


def __get_description_json(metric: Metric):

    def normalize(name: str):
        return name.replace(' / ', '_')

    def converter(title):
        return metric.display_name or title

    path = Path(f'repository/metrics/local/cost_metrics/aggs/help/metrics_descriptions/{normalize(metric.name)}.MD')
    desc = file_to_dict(path, converter)
    return Object_to_JSON.convert(desc)
