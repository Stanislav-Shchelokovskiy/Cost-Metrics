from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData, KnotMeta
from toolbox.sql.generators.utils import build_multiline_string_ignore_empties
from sql_queries.meta import Employee
from repository.metrics.local.generators import employees


# yapf: disable
class EmployeesQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return KnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': f'DISTINCT {Employee.name} AS {KnotMeta.name}, {Employee.scid} AS {KnotMeta.id}',
            'from': Employee.get_name(),
            'where_group_limit': build_multiline_string_ignore_empties(
                (
                    employees.generate_emps_filter(
                        teams=kwargs['teams'],
                        tribes=kwargs['tribes'],
                        tents=kwargs['tents'],
                        positions=kwargs['positions']
                    ),
                    f'ORDER BY {Employee.name}',
                )
            ),
        }
