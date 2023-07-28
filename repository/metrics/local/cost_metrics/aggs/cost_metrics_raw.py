from collections.abc import Mapping, Iterable
from itertools import chain
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta.cost_metrics import CostmetricsMeta
from sql_queries.index import local_names_index
from repository.metrics.local.cost_metrics.aggs.metric_aggs import (
    get_metrics_projections,
    get_metrics,
    get_emp_metrics_names,
    get_emp_metrics,
    Metric,
)
from repository.metrics.local.generators import (
    Window,
    cost_metrics,
    employee_window,
    tent_window,
    tribe_window,
    chapter_window,
)


# yapf: disable
class CostMetricsRawQueryDescriptor(GeneralSelectAsyncQueryDescriptor):
    __meta = dict()
    __cols = dict()
    __emp_windows = employee_window,
    __agg_windows = tent_window, tribe_window, chapter_window,



    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        role = kwargs['role']
        meta = self.__meta.get(role, None)
        if not meta:
            meta = self.__generate_and_cache_fields_meta(role)
        return meta


    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': self.__get_cols(kwargs),
            'from':  local_names_index.CostMetrics.cost_metrics,
            'where_group_limit': cost_metrics.generate_filter(kwargs)
        }

# yapf: enable

    def __generate_and_cache_fields_meta(self, role):
        emp_metrics_attrs = self.__get_fields(
            metrics_names=get_emp_metrics_names(),
            windows_names=[w.name for w in self.__emp_windows]
        )

        agg_metrics_attrs = self.__get_fields(
            metrics_names=get_metrics_projections(role=role),
            windows_names=[w.name for w in self.__agg_windows],
        )
        meta = type(
            'CostmetricsRawMeta',
            (CostmetricsMeta, ),
            {
                **CostmetricsMeta.get_attrs(),
                **emp_metrics_attrs,
                **agg_metrics_attrs,
            },
        )
        self.__meta[role] = meta
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
        role = kwargs['role']
        cols = self.__cols.get(role, None)
        if not cols:
            cols = self.__generate_and_cache_cols(role=role)
        return cols

    def __generate_and_cache_cols(self, role):
        emp_metrics_aliases = self.__get_metrics_cols(
            metrics=get_emp_metrics().values(),
            windows=self.__emp_windows,
        )
        agg_metrics_aliases = self.__get_metrics_cols(
            metrics=get_metrics(role=role).values(),
            windows=self.__agg_windows,
        )
        cols = ',\n\t'.join(
            chain(
                CostmetricsMeta.get_values(),
                emp_metrics_aliases,
                agg_metrics_aliases,
            )
        )
        self.__cols[role] = cols
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
