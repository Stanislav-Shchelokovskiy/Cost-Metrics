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
    'start': sql_str(-6),
    'end': sql_str(-1),
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month:
        [
            sql_str(-6),
            sql_str(-5),
            sql_str(-4),
            sql_str(-3),
            sql_str(-2),
            sql_str(-1),
        ],
    _emps.name: ['emp1'] * 6,
    _emps.level_value: [4.0, 5.0, 5.0, 4.0, 5.0, 5.5],
    _emps.hourly_pay_net: [5.804, 7.143, 7.143, 5.804, 7.143, 10.714],
    _emps.hourly_pay_gross: [7.603, 9.357, 9.357, 7.603, 9.357, 14.036],
    _emps.hourly_pay_gross_withAOE: [20.698, 22.452, 22.452, 20.698, 22.452, 27.131],
}