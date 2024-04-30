from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
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
    _emps.name: ['emp1'] * 4,
    _emps.tribe_id:
        [
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000003',
            '00000000-0000-0000-0000-000000000002',
        ],
    _emps.tribe_name: ['tribe1', 'tribe1', 'tribe3', 'tribe2'],
}
