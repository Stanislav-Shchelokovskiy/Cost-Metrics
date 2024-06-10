import sql_queries.index.path.remote as path_index
from sql_queries.Tests.cost_metrics.params import migrations as __mig_path


class _iterations:
    year_month = 'year_month'
    emp_crmid = 'emp_crmid'
    unique_tickets = 'unique_tickets'
    iterations = 'iterations'
    sc_hours = 'sc_hours'


params = dict()

tbl = '#Iterations'

queries = [
    f'{__mig_path}iterations.sql',
    path_index.CostMetrics.iterations,
]

dtfields = [_iterations.year_month]

want = {
    _iterations.year_month: ['2023-12-01', '2024-01-01'],
    _iterations.emp_crmid: [1, 1],
    _iterations.unique_tickets: [2, 3],
    _iterations.iterations: [3, 4],
    _iterations.sc_hours: [150.75, 155],
}
