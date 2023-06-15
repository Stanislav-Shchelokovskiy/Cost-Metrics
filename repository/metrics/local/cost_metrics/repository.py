from collections.abc import Callable
from toolbox.sql_async import (
    AsyncRepository,
    QueryDescriptor,
)
from repository.metrics.local.cost_metrics import (
    CostMetricsAggsQueryDescriptor,
    CostMetricsRawQueryDescriptor,
    TribesQueryDescriptor,
    PositionsQueryDescriptor,
    EmployeesQueryDescriptor,
    TeamsQueryDescriptor,
    PeriodQueryDescriptor,
    get_metrics_names,
)
from repository.metrics.local.generators import get_aggbys
from toolbox.utils.converters import Object_to_JSON


class CostMetricsRepository:

    def __init__(
        self,
        create_repository: Callable[[QueryDescriptor], AsyncRepository],
    ):
        self.aggregates = create_repository(CostMetricsAggsQueryDescriptor())
        self.raw = create_repository(CostMetricsRawQueryDescriptor())
        self.tribes = create_repository(TribesQueryDescriptor())
        self.positions = create_repository(PositionsQueryDescriptor())
        self.employees = create_repository(EmployeesQueryDescriptor())
        self.teams = create_repository(TeamsQueryDescriptor())
        self.period = create_repository(PeriodQueryDescriptor())

    async def get_metrics(self, mode: str | None) -> str:
        return Object_to_JSON.convert(get_metrics_names(mode=mode, formatter=lambda x: {'name' : x.name, 'context' : 1}))

    async def get_aggbys(self) -> str:
        return Object_to_JSON.convert(get_aggbys())
