from toolbox.sql.generators.display_filter import QueryParams
from toolbox.sql.generators.filter_clause_generator_factory import BaseNode
import toolbox.sql.generators.display_filter as DisplayFilterGenerator


def custom_display_filter(
    field_name: str,
    field_alias: str,
    filter_node,
) -> list | None:
    return None


class DisplayValuesStore:

    @staticmethod
    def get_query_params(field: str) -> QueryParams:
        return None

    @staticmethod
    def get_display_value(field: str, alias: str, value) -> str:
        return value


async def generate_display_filter(node: BaseNode) -> str:
    return await DisplayFilterGenerator.generate_display_filter(
        node=node,
        custom_display_filter=custom_display_filter,
        display_values_store=DisplayValuesStore,
    )
