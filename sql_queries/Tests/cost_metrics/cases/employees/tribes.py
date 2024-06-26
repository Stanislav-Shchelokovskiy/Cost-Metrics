from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


params = {
    'start': '2022-09-01',
    'end': '2023-02-05',
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
            '2023-02-01',
        ],
    _emps.name: ['emp1'] * 6,
    _emps.tribe_id:
        [
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000003',
        ],
    _emps.tribe_name: [
        'tribe1',
        'tribe1',
        'tribe3',
        'tribe2',
        'tribe2',
        'tribe3',
    ],
}
