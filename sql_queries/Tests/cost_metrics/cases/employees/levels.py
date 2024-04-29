from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    cols,
    queries,
)


params = {
    'start': '2022-09-01',
    'end': '2022-12-30',
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month:
        [
            '2022-09-01',
            '2022-10-01',
            '2022-11-01',
            '2022-12-01',
        ],
    _emps.scid: ['00000000-0000-0000-0000-000000000001'] * 4,
    _emps.name: ['emp1'] * 4,
    _emps.level_name:
        [
            'trainee_support',
            'middle_dev',
            'middle_support',
            'senior_support',
        ],
    _emps.level_value: [3, 5, 5, 5.5],
}
