import toolbox.sql.generators.display_filter as DisplayFilterGenerator
from toolbox.sql.generators.display_filter import QueryParams
from toolbox.sql.generators.filter_clause_generator_factory import BaseNode
from sql_queries.meta import Employees, Tribes, Tents, Positions


def custom_display_filter(
    field_name: str,
    field_alias: str,
    filter_node,
) -> list | None:
    return None


class DisplayValuesStore:

    # yapf: disable
    _query_params_store = {
        'tribes': QueryParams(table=Tribes.get_name()),
        'tents': QueryParams(table=Tents.get_name()),
        'positions': QueryParams(table=Positions.get_name()),
        'employees': QueryParams(
            table=Employees.get_name(),
            value_field=Employees.scid.name,
            display_field=Employees.name.name,
        )
    }

    @staticmethod
    def get_query_params(field: str) -> QueryParams:
        return DisplayValuesStore._query_params_store.get(field, None)

    @staticmethod
    def get_display_value(field: str, alias: str, value) -> str:
        return value


async def generate_display_filter(node: BaseNode) -> str:
    return await DisplayFilterGenerator.generate_display_filter(
        node=node,
        custom_display_filter=custom_display_filter,
        display_values_store=DisplayValuesStore,
    )
