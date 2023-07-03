from collections.abc import Mapping, Iterable
from itertools import chain
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
from repository.metrics.local.cost_metrics.aggs.metric_aggs import (
    get_metrics_names,
    get_metrics,
    get_emp_metrics_names,
    get_emp_metrics,
    Metric,
)
from repository.metrics.local.generators import (
    Window,
    cost_metrics,
    employee_window,
    tribe_window,
    chapter_window,
)


# yapf: disable
class CostMetricsRawQueryDescriptor(GeneralSelectAsyncQueryDescriptor):
    __meta = dict()
    __cols = dict()


    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        mode = kwargs['mode']
        meta = self.__meta.get(mode, None)
        if not meta:
            meta = self.__generate_and_cache_fields_meta(mode)
        return meta


    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': self.__get_cols(kwargs),
            'from':  local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': cost_metrics.generate_filter(kwargs)
        }

# yapf: enable

    def __generate_and_cache_fields_meta(self, mode):
        emp_metrics_attrs = self.__get_fields(
            metrics_names=get_emp_metrics_names(),
            windows_names=(employee_window.name, ),
        )

        tribe_chapter_metrics_attrs = self.__get_fields(
            metrics_names=get_metrics_names(mode=mode),
            windows_names=(tribe_window.name, chapter_window.name),
        )
        meta = type(
            'CostmetricsRawMeta',
            (CostmetricsMeta, ),
            {
                **CostmetricsMeta.get_attrs(),
                **emp_metrics_attrs,
                **tribe_chapter_metrics_attrs,
            },
        )
        self.__meta[mode] = meta
        return meta

    def __get_fields(
        self,
        metrics_names: Iterable[str],
        windows_names: Iterable[str],
    ):
        return {
            self.__as_alias(over_name, metric):
            self.__as_alias(over_name, metric)
            for metric in metrics_names for over_name in windows_names
        }

    def __get_cols(self, kwargs):
        mode = kwargs['mode']
        cols = self.__cols.get(mode, None)
        if not cols:
            cols = self.__generate_and_cache_cols(mode)
        return cols

    def __generate_and_cache_cols(self, mode):
        emp_metrics_aliases = self.__get_metrics_cols(
            metrics=get_emp_metrics().values(),
            windows=(employee_window, ),
        )
        tribe_chapter_metrics_aliases = self.__get_metrics_cols(
            metrics=get_metrics(mode=mode).values(),
            windows=(tribe_window, chapter_window),
        )
        cols = ',\n\t'.join(
            chain(
                CostmetricsMeta.get_values(),
                emp_metrics_aliases,
                tribe_chapter_metrics_aliases,
            )
        )
        self.__cols[mode] = cols
        return cols

    def __get_metrics_cols(
        self,
        metrics: Iterable[Metric],
        windows: Iterable[Window],
    ):
        metrics_aliases = (
            f'{metric.get_over(wnd.statement)} AS {self.__as_alias(wnd.name, metric.name)}'
            for metric in metrics for wnd in windows
        )
        return metrics_aliases

    # yapf: disable
    def __as_alias(self, over_name, metric):
        return f'{over_name}_{metric}'.replace(' ', '_').replace('(', '').replace(')', '')
# yapf: enable
