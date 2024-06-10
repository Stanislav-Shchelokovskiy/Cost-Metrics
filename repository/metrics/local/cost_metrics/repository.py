from collections.abc import Callable, Iterable
from toolbox.sql_async import (
    AsyncRepository,
    QueryDescriptor,
)
from repository.metrics.local.cost_metrics import (
    CostMetricsAggsQueryDescriptor,
    CostMetricsRawQueryDescriptor,
    TribesQueryDescriptor,
    TentsQueryDescriptor,
    PositionsQueryDescriptor,
    EmployeesQueryDescriptor,
    TeamsQueryDescriptor,
    select_metrics,
)
from toolbox.sql.aggs.metrics import Metric
from toolbox.utils.converters import Object_to_JSON
from toolbox.sql_async.repository_queries.async_query_descriptor import PeriodQueryDescriptor
from sql_queries.meta import CostMetrics
from config import admin_role


class MetricsRepository:

    def __init__(
        self,
        create_repository: Callable[[QueryDescriptor], AsyncRepository],
    ):
        self.aggregates = create_repository(CostMetricsAggsQueryDescriptor())
        self.raw = create_repository(CostMetricsRawQueryDescriptor())
        self.tribes = create_repository(TribesQueryDescriptor())
        self.tents = create_repository(TentsQueryDescriptor())
        self.positions = create_repository(PositionsQueryDescriptor())
        self.employees = create_repository(EmployeesQueryDescriptor())
        self.teams = create_repository(TeamsQueryDescriptor())
        self.period = create_repository(
            PeriodQueryDescriptor(
                field=CostMetrics.year_month, tbl=CostMetrics.get_name()
            )
        )

    async def get_metrics(self, role: str | None) -> str:
        return Object_to_JSON.convert(
            select_metrics(
                role=role,
                projector=lambda metric: {
                    'name': metric.name,
                    'displayName': metric.get_display_name(),
                    'group': metric.group,
                    'context': 1
                }
            )
        )

    def __call__(self) -> Iterable[Metric]:
        return select_metrics(role=admin_role())
