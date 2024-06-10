import sql_queries.index.path.remote as path_index


class __vacs:
    crmid = 'crmid'
    year_month = 'year_month'
    paid_hours = 'paid_hours'
    free_hours = 'free_hours'


params = {
    'start': '2022-10-01',
    'end': '2023-03-15',
    'vacations_json': '',
}

dtfields = [__vacs.year_month]

tbl = '#Vacations'

want = {
    __vacs.crmid: ['00000000-0000-0000-0000-000000000001'] * 6,
    __vacs.year_month:
        [
            '2022-10-01', '2022-11-01', '2022-12-01', '2023-01-01',
            '2023-02-01', '2023-03-01'
        ],
    __vacs.paid_hours: [4.0, 4.0, 0.0, 0.0, 4.0, 0.0],
    __vacs.free_hours: [0.0, 0.0, 120.0, 4.0, 0.0, 16.0],
}

queries = [
    path_index.CostMetrics.months,
    path_index.CostMetrics.parse_vacations,
    path_index.CostMetrics.vacations,
]
