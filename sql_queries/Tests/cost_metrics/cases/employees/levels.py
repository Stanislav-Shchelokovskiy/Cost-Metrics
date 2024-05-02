from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


params = {
    'start': '2022-09-01',
    'end': '2023-01-03',
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
            '2023-01-01',
        ],
    _emps.name: ['emp1'] * 5,
    _emps.level_name:
        [
            'trainee_support',
            'middle_support',
            'middle_support',
            'senior_support',
            'senior_support',
        ],
    _emps.level_value: [3, 5, 5, 5.5, 5.5],
}
