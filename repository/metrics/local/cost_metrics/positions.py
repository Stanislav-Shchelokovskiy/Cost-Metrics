from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData
from sql_queries.meta import Positions


# yapf: disable
class PositionsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return Positions

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': Positions,
            'from': Positions.get_name(),
            'where_group_limit': f'ORDER BY {Positions.name}',
        }
