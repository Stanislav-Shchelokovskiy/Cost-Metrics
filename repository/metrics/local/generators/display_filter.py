from toolbox.sql.generators.display_filter import QueryParams
from toolbox.sql.generators.filter_clause_generator_factory import BaseNode
import toolbox.sql.generators.display_filter as DisplayFilterGenerator
from sql_queries.index import local_names_index
from sql_queries.meta.cost_metrics import CostmetricsEmployeesMeta


def custom_display_filter(
    field_name: str,
    field_alias: str,
    filter_node,
) -> list | None:
    return None


class DisplayValuesStore:
    # yapf: disable
    _query_params_store = {
    'employees':
        QueryParams(
            table=local_names_index.CostMetrics.employees,
            value_field=CostmetricsEmployeesMeta.crmid,
            display_field=CostmetricsEmployeesMeta.name,
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
