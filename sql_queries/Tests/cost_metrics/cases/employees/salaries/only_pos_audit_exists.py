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


params = {
    'start': sql_str(-2),
    'end': sql_str(-1),
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month: [sql_str(-2), sql_str(-1)],
    _emps.name: ['emp1'] * 2,
    _emps.level_value: [4.0, 5.0],
    _emps.hourly_pay_net: [5.804, 7.143],
    _emps.hourly_pay_gross: [7.603, 9.357],
    _emps.hourly_pay_gross_withAOE: [20.698, 22.452],
}
