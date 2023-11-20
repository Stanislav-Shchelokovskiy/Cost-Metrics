from collections.abc import Mapping
from toolbox.sql_async import GeneralSelectAsyncQueryDescriptor
from toolbox.sql import MetaData, KnotMeta
from sql_queries.meta import Teams


class TeamsQueryDescriptor(GeneralSelectAsyncQueryDescriptor):

    def get_fields_meta(self, kwargs: Mapping) -> MetaData:
        return KnotMeta

    def get_format_params(self, kwargs: Mapping) -> Mapping[str, str]:
        return {
            'select': f'{Teams.name} AS {KnotMeta.name}, {Teams.name} AS {KnotMeta.id}',
            'from': Teams.get_name(),
            'where_group_limit': '',
        }
