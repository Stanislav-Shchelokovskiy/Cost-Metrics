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
    _emps.level_value: [3.0, 3.0, 4.0, 4.0, 5.0, 6.0],
    _emps.hourly_pay_net: [3.268, 3.857, 4.554, 5.143, 6.214, 6.964],
    _emps.hourly_pay_gross: [3.464, 4.089, 4.827, 5.451, 6.587, 7.382],
    _emps.hourly_pay_gross_withAOE: [15.369, 15.993, 16.732, 17.356, 18.492, 19.287],
}
