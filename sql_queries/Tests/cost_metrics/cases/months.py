import sql_queries.index.path.remote as path_index


class __year_months:
    year_month = 'year_month'
    next_month = 'next_month'


params = {
    'start': '2023-12-12',
    'end': '2024-03-13',
}

dtfields = [__year_months.year_month, __year_months.next_month]

tbl = '#Months'

want = {
    __year_months.year_month:
        ['2023-12-01', '2024-01-01', '2024-02-01', '2024-03-01'],
    __year_months.next_month:
        ['2024-01-01', '2024-02-01', '2024-03-01', '2024-03-13'],
}

queries = [path_index.CostMetrics.months]
