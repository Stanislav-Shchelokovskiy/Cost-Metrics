import os
from collections.abc import Iterable, Callable, Mapping
from collections import ChainMap
from sql_queries.meta.cost_metrics import CostmetricsMeta
from toolbox.sql.aggs import Metric, SUM

# yapf: disable
sc_work_cost_gross_incl_overtime = Metric(
    'SC Work Cost (gross incl overtime)',
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime),
)
sc_work_cost_gross_withAOE_incl_overtime = Metric(
    'SC Work Cost (gross with AOE incl overtime)',
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime),
)
total_work_hours = Metric(
    'Total Work Hours',
    SUM(CostmetricsMeta.total_work_hours),
)
sc_work_cost_gross = Metric(
    'SC Work Cost (gross)',
    SUM(CostmetricsMeta.sc_work_cost_gross),
)
sc_work_cost_gross_withAOE = Metric(
    'SC Work Cost (gross with AOE)',
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE),
)
proactive_work_cost_gross = Metric(
    'Proactive Work Cost (gross)',
    SUM(CostmetricsMeta.proactive_work_cost_gross),
)
proactive_work_cost_gross_withAOE = Metric(
    'Proactive Work Cost (gross with AOE)',
    SUM(CostmetricsMeta.proactive_work_cost_gross_withAOE),
)
ticket_cost_gross = Metric(
    'Ticket Cost (gross)',
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime) / SUM(CostmetricsMeta.unique_tickets),
)
ticket_cost_gross_withAOE = Metric(
    'Ticket Cost (gross with AOE)',
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostmetricsMeta.unique_tickets),
)
iteration_cost_gross = Metric(
    'Iteration Cost (gross)',
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime) / SUM(CostmetricsMeta.iterations),
)
iteration_cost_gross_withAOE = Metric(
    'Iteration Cost (gross with AOE)',
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostmetricsMeta.iterations),
)
iterations_per_hour = Metric(
    'Iterations per hour',
    SUM(CostmetricsMeta.iterations) / SUM(CostmetricsMeta.sc_hours),
)
tickets_per_hour = Metric(
    'Tickets per hour',
    SUM(CostmetricsMeta.unique_tickets) / SUM(CostmetricsMeta.sc_hours),
)

# yapf: disable
fot_gross = Metric.from_metric('FOT (gross)', sc_work_cost_gross + proactive_work_cost_gross)
fot_gross_withAOE = Metric.from_metric('FOT (gross with AOE)', sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE)

hour_price_gross = Metric.from_metric('Hour price (gross)', (sc_work_cost_gross + proactive_work_cost_gross) / total_work_hours)
hour_price_gross_withAOE = Metric.from_metric('Hour price (gross with AOE)', (sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE) / total_work_hours)


tribe_chapter_metrics = {
    sc_work_cost_gross_incl_overtime.name: sc_work_cost_gross_incl_overtime,
    sc_work_cost_gross_withAOE_incl_overtime.name: sc_work_cost_gross_withAOE_incl_overtime,
    total_work_hours.name: total_work_hours,
    sc_work_cost_gross.name: sc_work_cost_gross,
    sc_work_cost_gross_withAOE.name: sc_work_cost_gross_withAOE,
    proactive_work_cost_gross.name: proactive_work_cost_gross,
    proactive_work_cost_gross_withAOE.name: proactive_work_cost_gross_withAOE,
    ticket_cost_gross.name: ticket_cost_gross,
    ticket_cost_gross_withAOE.name: ticket_cost_gross_withAOE,
    iteration_cost_gross.name: iteration_cost_gross,
    iteration_cost_gross_withAOE.name: iteration_cost_gross_withAOE,
    iterations_per_hour.name: iterations_per_hour,
    tickets_per_hour.name: tickets_per_hour,
    hour_price_gross.name: hour_price_gross,
    hour_price_gross_withAOE.name: hour_price_gross_withAOE,
}
# yapf: enable

advanced_metrics = {
    fot_gross.name: fot_gross,
    fot_gross_withAOE.name: fot_gross_withAOE,
}

all_metrics = ChainMap(advanced_metrics, tribe_chapter_metrics)

none_metric = Metric('Fake', SUM(0))


def get_metric(metric: str, mode: str | None) -> Metric:
    return get_metrics(mode).get(metric, none_metric)


def get_metrics_names(
    mode: str | None,
    formatter: Callable[[Metric], str] = lambda x: x.name
) -> Iterable:
    return [formatter(x) for x in get_metrics(mode).values()]


def get_metrics(mode: str | None) -> Mapping[str, Metric]:
    if advanced_mode_enabled(mode):
        return all_metrics
    return tribe_chapter_metrics


def advanced_mode_enabled(mode: str | None) -> bool:
    return mode == os.environ['ADVANCED_MODE_NAME']


def get_emp_metrics() -> Mapping[str, Metric]:
    return {
        iteration_cost_gross.name: iteration_cost_gross,
        tickets_per_hour.name: tickets_per_hour,
    }


def get_emp_metrics_names() -> Iterable[str]:
    return get_emp_metrics().keys()
