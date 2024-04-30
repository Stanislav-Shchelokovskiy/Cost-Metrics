from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


params = {
    'start': '2022-09-05',
    'end': '2022-11-05',
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month: [
        '2022-09-01',
        '2022-10-01',
        '2022-11-01',
    ],
    _emps.name: ['emp1'] * 3,
    _emps.chapter_id:
        [
            '00000000-0000-0000-0000-000000000001',
            '29B6E93D-8644-4977-9010-983076353DC6',
            '00000000-0000-0000-0000-000000000002',
        ],
}