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
from repository.wf.work_hours import WFHoursQueries
from repository.metrics.remote.cost_metrics import CostMetricsQueries
from repository.metrics.local.cost_metrics.repository import CostMetricsRepository
import toolbox.sql.generators.sqlite.periods_generator as periods_generator
import repository.metrics.local.generators.display_filter as DisplayFilterGenerator
import repository.metrics.local.cost_metrics.aggs.help.index as help


class WfRepository:
    wf_hours = SqlServerNonQueryRepository(queries=WFHoursQueries())


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
    periods = periods_generator
    display_filter = DisplayFilterGenerator
    help = help
