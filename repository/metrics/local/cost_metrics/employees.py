from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import KnotMeta
from repository.metrics.local.generators import employees


# yapf: disable
class EmployeesQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return KnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': f'DISTINCT {KnotMeta.name} AS {KnotMeta.name}, {KnotMeta.name} AS {KnotMeta.id}',
            'from': local_names_index.CostMetrics.employees,
            'where_group_limit': build_multiline_string_ignore_empties(
                (
                    employees.generate_tribes_positions_filter(tribes=kwargs['tribes'], positions=kwargs['positions']),
                    f'ORDER BY {KnotMeta.name}',
                )
            ),
        }
