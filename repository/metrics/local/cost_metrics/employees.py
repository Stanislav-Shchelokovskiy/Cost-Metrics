from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.index import local_names_index
from sql_queries.meta import CostmetricsEmployeesMeta


# yapf: disable
class EmployeesQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return CostmetricsEmployeesMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': ','.join(self.get_fields(kwargs)),
            'from': local_names_index.CostMetrics.employees,
            'where_group_limit': '',
        }
