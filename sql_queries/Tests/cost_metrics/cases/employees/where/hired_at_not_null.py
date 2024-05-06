from datetime import datetime, timezone
from dateutil.relativedelta import relativedelta
from toolbox.utils.converters import DateTimeToSqlString
from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


__now = datetime.now(timezone.utc)


def sql_str(months: int) -> str:
    return DateTimeToSqlString.convert(
        __now + relativedelta(months=months, day=1),
        '-',
    )

def sql_str_preserve_day(months: int) -> str:
    return DateTimeToSqlString.convert(
        __now + relativedelta(months=months),
        '-',
    )


params = {
    'start': sql_str(-2),
    'end': sql_str(-1),
    **params,
}

dtfields = [_emps.year_month, _emps.hired_at]

want = {
    _emps.year_month: [sql_str(-1)],
    _emps.name: ['emp1'],
    _emps.hired_at: [sql_str_preserve_day(-2)],
}
