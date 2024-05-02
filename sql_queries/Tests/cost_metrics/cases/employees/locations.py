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
    _emps.audit_location_id:
        [
            '69D186BB-CF91-4A5B-BF75-D3F1036C33E3',
            '00000000-0000-0000-0000-000000000002',
            None,
            '69D186BB-CF91-4A5B-BF75-D3F1036C33E3',
            '00000000-0000-0000-0000-000000000001',
        ],
    _emps.audit_location_name:
        [
            'philippines',
            'other',
            None,
            'philippines',
            'armenia',
        ],
}
