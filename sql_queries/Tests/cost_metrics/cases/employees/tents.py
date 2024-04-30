from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


params = {
    'start': '2023-05-12',
    'end': '2023-12-30',
    **params,
}

dtfields = [_emps.year_month]

want = {
    _emps.year_month:
        [
            '2023-05-01',
            '2023-06-01',
            '2023-07-01',
            '2023-08-01',
            '2023-09-01',
            '2023-10-01',
            '2023-11-01',
            '2023-12-01',
        ],
    _emps.name: ['emp1'] * 8,
    _emps.tent_id:
        [
            None,
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000003',
            None,
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
        ],
    _emps.tent_name:
        [None, 'tent1', 'tent1', 'tent3', 'tent3', None, 'tent2', 'tent2']
}
