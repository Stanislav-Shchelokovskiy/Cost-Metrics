from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta import Tribes, Tents


# yapf: disable
class TribesQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return Tribes

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': Tribes,
            'from': Tribes.get_name(),
            'where_group_limit': f'ORDER BY {Tribes.name}',
        }

class TentsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return Tents

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': Tents,
            'from': Tents.get_name(),
            'where_group_limit': f'ORDER BY {Tents.name}',
        }
