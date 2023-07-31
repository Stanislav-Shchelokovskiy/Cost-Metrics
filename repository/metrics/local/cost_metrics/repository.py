from collections.abc import Callable
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
    PeriodQueryDescriptor,
    select_metrics,
)
from toolbox.utils.converters import Object_to_JSON


class CostMetricsRepository:

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
        self.period = create_repository(PeriodQueryDescriptor())

    async def get_metrics(self, role: str | None) -> str:
        return Object_to_JSON.convert(
            select_metrics(
                role=role,
                projector=lambda x: {
                    'name': x.name,
                    'displayName': x.display_name or x.name,
                    'group': x.group,
                    'context': 1
                }
            )
        )
