from sql_queries.Tests.cost_metrics.cases.employees.common import (
    _emps,
    params,
    tbl,
    queries,
)


params = {
    'start': '2022-09-01',
    'end': '2023-02-03',
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
    _emps.audit_location_id:
        [
            None,
            '00000000-0000-0000-0000-000000000003',
            None,
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000002',
            '00000000-0000-0000-0000-000000000001',
        ],
    _emps.audit_location_name:
        [
            None,
            'other',
            None,
            'estonia',
            'estonia',
            'armenia',
        ],
}
