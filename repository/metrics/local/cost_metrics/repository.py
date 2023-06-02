from collections.abc import Callable
from toolbox.sql_async import (
    AsyncRepository,
    QueryDescriptor,
)
from repository.metrics.local.cost_metrics.aggs import (
    CostMetricsAggsQueryDescriptor,
    get_metrics,
)
from repository.metrics.local.cost_metrics.tribes import TribesQueryDescriptor
from repository.metrics.local.cost_metrics.positions import PositionsQueryDescriptor
from repository.metrics.local.cost_metrics.employees import EmployeesQueryDescriptor
from repository.metrics.local.cost_metrics.teams import TeamsQueryDescriptor
from repository.metrics.local.cost_metrics.period import PeriodQueryDescriptor
from repository.metrics.local.generators import get_groupbys
from toolbox.utils.converters import Object_to_JSON


class CostMetricsRepository:

    def __init__(
        self,
        create_repository: Callable[[QueryDescriptor], AsyncRepository],
    ):
        self.aggregates = create_repository(CostMetricsAggsQueryDescriptor())
        self.tribes = create_repository(TribesQueryDescriptor())
        self.positions = create_repository(PositionsQueryDescriptor())
        self.employees = create_repository(EmployeesQueryDescriptor())
        self.teams = create_repository(TeamsQueryDescriptor())
        self.period = create_repository(PeriodQueryDescriptor())

    async def get_metrics(self) -> str:
        return Object_to_JSON.convert(get_metrics())

    async def get_agg_bys(self) -> str:
        return Object_to_JSON.convert(get_groupbys())
