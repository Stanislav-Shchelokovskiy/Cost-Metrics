from toolbox.sql.repository import (
    SqlServerNonQueryRepository,
    SqlServerRepository,
)
from repository.wf.work_on_holidays import WorkOnHolidaysQueries
from repository.metrics.remote.cost_metrics import CostMetricsQueries


class WfRepository:
    work_on_holidays = SqlServerNonQueryRepository(
        queries=WorkOnHolidaysQueries()
    )


class RemoteRepository:
    cost_metrics = SqlServerRepository(queries=CostMetricsQueries())
