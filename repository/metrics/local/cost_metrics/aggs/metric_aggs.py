import os
from collections.abc import Iterable, Callable, Mapping
from collections import ChainMap
from sql_queries.meta.cost_metrics import CostmetricsMeta
from toolbox.sql.aggs import Metric, SUM, NONE_METRIC

class MetricGroup:
    cost = 'Cost'
    efficiency = 'Efficiency'
    indepth = 'In-depth'

# yapf: disable
sc_work_cost_gross_incl_overtime = Metric(
    'SC Work Cost (gross incl overtime)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime),
)
sc_work_cost_gross_withAOE_incl_overtime = Metric(
    'SC Work Cost (gross with AOE incl overtime)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime),
)
total_work_hours_incl_overtime = Metric(
    'Total Work Hours (incl overtime)',
    MetricGroup.efficiency,
    SUM(CostmetricsMeta.total_work_hours),
)
sc_work_cost_gross = Metric(
    'SC Work Cost (gross)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross),
)
sc_work_cost_gross_withAOE = Metric(
    'SC Work Cost (gross with AOE)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE),
)
proactive_work_cost_gross = Metric(
    'Proactive Work Cost (gross)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.proactive_work_cost_gross),
)
proactive_work_cost_gross_withAOE = Metric(
    'Proactive Work Cost (gross with AOE)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.proactive_work_cost_gross_withAOE),
)
ticket_cost_gross = Metric(
    'Ticket Cost (gross)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime) / SUM(CostmetricsMeta.unique_tickets),
)
ticket_cost_gross_withAOE = Metric(
    'Ticket Cost (gross with AOE)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostmetricsMeta.unique_tickets),
)
iteration_cost_gross = Metric(
    'Iteration Cost (gross)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_incl_overtime) / SUM(CostmetricsMeta.iterations),
)
iteration_cost_gross_withAOE = Metric(
    'Iteration Cost (gross with AOE)',
    MetricGroup.cost,
    SUM(CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostmetricsMeta.iterations),
)
iterations_per_hour = Metric(
    'Iterations per hour',
    MetricGroup.efficiency,
    SUM(CostmetricsMeta.iterations) / SUM(CostmetricsMeta.sc_hours),
)
tickets_per_hour = Metric(
    'Tickets per hour',
    MetricGroup.efficiency,
    SUM(CostmetricsMeta.unique_tickets) / SUM(CostmetricsMeta.sc_hours),
)

# yapf: disable
support_service_cost_gross = Metric.from_metric('Support Service Cost (gross)', MetricGroup.cost, sc_work_cost_gross + proactive_work_cost_gross)
support_service_cost_gross_withAOE = Metric.from_metric('Support Service Cost (gross with AOE) ', MetricGroup.cost, sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE)

work_hour_cost_gross = Metric.from_metric('Work Hour Cost (gross)', MetricGroup.cost, (sc_work_cost_gross + proactive_work_cost_gross) / total_work_hours_incl_overtime)
work_hour_gross_withAOE = Metric.from_metric('Work Hour Cost (gross with AOE)', MetricGroup.cost, (sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE) / total_work_hours_incl_overtime)


basic_metrics = {
    ticket_cost_gross.name: ticket_cost_gross,
    iteration_cost_gross.name: iteration_cost_gross,
    iterations_per_hour.name: iterations_per_hour,
    tickets_per_hour.name: tickets_per_hour,
}

advanced_metrics = {
    sc_work_cost_gross.name: sc_work_cost_gross,
    proactive_work_cost_gross.name: proactive_work_cost_gross,
    work_hour_cost_gross.name: work_hour_cost_gross,
}

admin_metrics = {
    sc_work_cost_gross_incl_overtime.name: sc_work_cost_gross_incl_overtime,
    sc_work_cost_gross_withAOE.name: sc_work_cost_gross_withAOE,
    sc_work_cost_gross_withAOE_incl_overtime.name: sc_work_cost_gross_withAOE_incl_overtime,
    proactive_work_cost_gross_withAOE.name: proactive_work_cost_gross_withAOE,
    ticket_cost_gross_withAOE.name: ticket_cost_gross_withAOE,
    iteration_cost_gross_withAOE.name: iteration_cost_gross_withAOE,
    work_hour_gross_withAOE.name: work_hour_gross_withAOE,
    total_work_hours_incl_overtime.name: total_work_hours_incl_overtime,
    support_service_cost_gross.name: support_service_cost_gross,
    support_service_cost_gross_withAOE.name: support_service_cost_gross_withAOE,
}
# yapf: enable

advanced_role_metrics = ChainMap(basic_metrics, advanced_metrics)
admin_role_metrics = ChainMap(basic_metrics, advanced_metrics, admin_metrics)


def is_authorized_metric(metric: str, role: str) -> bool:
    return metric in get_metrics(role)


def get_metric(metric: str, role: str | None) -> Metric:
    return get_metrics(role).get(metric, NONE_METRIC)


def get_metrics_projections(
    role: str | None,
    projector: Callable[[Metric], str] = lambda x: x.name
) -> Iterable:
    return [projector(x) for x in get_metrics(role).values()]


def get_metrics(role: str | None) -> Mapping[str, Metric]:
    if is_advanced(role):
        return advanced_role_metrics
    if is_admin(role):
        return admin_role_metrics
    return basic_metrics


def is_admin(role: str | None) -> bool:
    return role == os.environ['ADMIN_ROLE']


def is_advanced(role: str | None) -> bool:
    return role == os.environ['ADVANCED_ROLE']


def get_emp_metrics() -> Mapping[str, Metric]:
    return {
        iteration_cost_gross.name: iteration_cost_gross,
        tickets_per_hour.name: tickets_per_hour,
    }


def get_emp_metrics_names() -> Iterable[str]:
    return get_emp_metrics().keys()
