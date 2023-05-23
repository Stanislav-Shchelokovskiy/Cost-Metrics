from toolbox.sql.repository import (
    SqlServerNonQueryRepository,
    SqlServerRepository,
)
from toolbox.sql_async import (
    AsyncRepository,
    AsyncSQLiteQueryExecutor,
    AsyncRepositoryQueries,
    QueryDescriptor,
)
from repository.wf.work_on_holidays import WorkOnHolidaysQueries
from repository.metrics.remote.cost_metrics import CostMetricsQueries
from repository.metrics.local.cost_metrics.repository import CostMetricsRepository


class WfRepository:
    work_on_holidays = SqlServerNonQueryRepository(
        queries=WorkOnHolidaysQueries()
    )


class RemoteRepository:
    cost_metrics = SqlServerRepository(queries=CostMetricsQueries())


class LocalRepository:

    @staticmethod
    def __create_async_repository(
        query_descriptor: QueryDescriptor
    ) -> AsyncRepository:
        return AsyncRepository(
            queries=AsyncRepositoryQueries(main_query=query_descriptor),
            query_executor=AsyncSQLiteQueryExecutor()
        )

    cost_metrics = CostMetricsRepository(__create_async_repository)
