from collections.abc import Callable
from toolbox.sql_async import (
    AsyncRepository,
    QueryDescriptor,
)
from repository.metrics.local.cost_metrics.cost_metrics import CostMetricsQueryDescriptor
from repository.metrics.local.cost_metrics.tribes import TribesQueryDescriptor
from repository.metrics.local.cost_metrics.positions import PositionsQueryDescriptor
from repository.metrics.local.cost_metrics.employees import EmployeesQueryDescriptor
from repository.metrics.local.cost_metrics.teams import TeamsQueryDescriptor
from sql_queries.meta.cost_metrics import CostmetricsMeta
from toolbox.utils.converters import Object_to_JSON


class CostMetricsRepository:

    def __init__(
        self,
        create_repository: Callable[[QueryDescriptor], AsyncRepository],
    ):
        self.cost_metrics = create_repository(CostMetricsQueryDescriptor())
        self.tribes = create_repository(TribesQueryDescriptor())
        self.positions = create_repository(PositionsQueryDescriptor())
        self.employees = create_repository(EmployeesQueryDescriptor())
        self.teams = create_repository(TeamsQueryDescriptor())

    async def get_metrics(self):
        return Object_to_JSON.convert(CostmetricsMeta.get_metrics())
