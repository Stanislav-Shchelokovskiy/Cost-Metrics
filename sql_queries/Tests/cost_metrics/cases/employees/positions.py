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
    _emps.position_id:
        [
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '0CF0BDBA-7DE3-4A06-9493-8F90720526B7',
            '7A8E1B05-385E-4C91-B61E-81446B0C404A',
            '945FDE96-987B-4608-85F4-7393F00D341B',
        ],
    _emps.position_name:
        [
            'support_developer',
            'tribe_leader',
            'support_developer',
            'chapter_leader',
        ],
}
