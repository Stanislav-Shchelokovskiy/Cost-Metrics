from collections.abc import Mapping
from toolbox.sql_async import AsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.index import local_names_index
from sql_queries.index import local_paths_index
from sql_queries.meta import CostmetricsEmployeesMeta


# yapf: disable
class EmployeesQueryDescriptor(AsyncQueryDescriptor):

    def get_path(self, kwargs: Mapping) -> str:
        return local_paths_index.General.general_select

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return CostmetricsEmployeesMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'columns': ','.join(self.get_fields(kwargs)),
            'table_name': local_names_index.CostMetrics.employees,
            'filter_group_limit_clause': '',
        }
