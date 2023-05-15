from toolbox.sql.repository import SqlServerReadOnlyRepository
from repository.wf.work_on_holidays import WorkOnHolidaysQueries


class WfRepository:
    work_on_holidays = SqlServerReadOnlyRepository(
        queries=WorkOnHolidaysQueries()
    )
