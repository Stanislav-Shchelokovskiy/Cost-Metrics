from collections.abc import Mapping
from itertools import chain
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
from repository.metrics.local.generators import cost_metrics, get_windows_names, get_windows
from repository.metrics.local.cost_metrics.aggs.metric_aggs import get_metrics_names, get_metrics


# yapf: disable
class CostMetricsRawQueryDescriptor(GeneralSelectAsyncQueryDescriptor):
    __meta = dict()
    __cols = dict()


    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        mode = kwargs['mode']
        meta = self.__meta.get(mode, None)
        if not meta:
            meta = self.__generate_and_cache_fields_meta(kwargs, mode)
        return meta


    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': self.__get_cols(kwargs),
            'from':  local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': cost_metrics.generate_filter(kwargs)
        }


    def __generate_and_cache_fields_meta(self, kwargs, mode):
        metrics = get_metrics_names(mode = kwargs['mode'])
        attrs = {self.__as_alias(over_name, metric): self.__as_alias(over_name, metric) for metric in metrics for over_name in get_windows_names()}
        meta = type('CostmetricsRawMeta', (CostmetricsMeta,), {**CostmetricsMeta.get_attrs(), **attrs})
        self.__meta[mode] = meta
        return meta


    def __get_cols(self, kwargs):
        mode = kwargs['mode']
        cols = self.__cols.get(mode, None)
        if not cols:
            cols = self.__generate_and_cache_cols(kwargs, mode)
        return cols


    def __generate_and_cache_cols(self, kwargs, mode):
        metrics = get_metrics(mode = kwargs['mode']).values()
        windows = get_windows().items()
        metrics_aliases = (f'{metric.get_over(wnd)} AS {self.__as_alias(wnd_name, metric.name)}' for metric in metrics for wnd_name, wnd in windows)
        cols = ',\n\t'.join(chain(CostmetricsMeta.get_values(), metrics_aliases))
        self.__cols[mode] = cols
        return cols


    def __as_alias(self, over_name, metric):
        return f'{over_name}_{metric}'.replace(' ', '_').replace('(', '').replace(')', '')
# yapf: enable
