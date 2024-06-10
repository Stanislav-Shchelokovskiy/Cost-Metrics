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
    'start': '2022-08-01',
    'end': '2022-11-01',
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month:
        [
            '2022-09-01',
            '2022-09-01',
            '2022-10-01',
            '2022-10-01',
            '2022-11-01',
            '2022-11-01',
        ],
    _emps.name: ['emp1', 'emp2', 'emp1', 'emp2', 'emp1', 'emp2'],
    _emps.level_value: [6, 3, 6, 5, 6, 5.0],
    _emps.level_name:
        [
            'support_developer_ph',
            'trainee_support',
            'support_developer_ph',
            'middle_support',
            'support_developer_ph',
            'middle_support',
        ],
    _emps.position_id:
        [
            '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A'
        ] * 3,
    _emps.position_name: ['support_developer_ph', 'support_developer'] * 3,
}
