import os
from collections.abc import Iterable, Callable, Mapping
from collections import ChainMap
from sql_queries.meta import CostMetrics
from toolbox.sql.aggs import (
    Metric,
    SUM,
    COUNT_DISTINCT,
    AVG,
    NONE_METRIC,
)


class MetricGroup:
    employees = 'Employees'
    cost = 'Cost'
    workflow = 'Workflow'
    productivity = 'Productivity'
    performance = 'Performance'


# yapf: disable
sc_work_cost_gross_incl_overtime = Metric(
    'SC Work Cost (gross incl overtime)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_incl_overtime),
)
sc_work_cost_gross_withAOE_incl_overtime = Metric(
    'SC Work Cost (gross with AOE incl overtime)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_withAOE_incl_overtime),
)
sc_work_cost_gross = Metric(
    'SC Work Cost (gross)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross),
)
sc_work_cost_gross_withAOE = Metric(
    'SC Work Cost (gross with AOE)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_withAOE),
)
proactive_work_cost_gross = Metric(
    'Proactive Work Cost (gross)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.proactive_work_cost_gross),
)
proactive_work_cost_gross_withAOE = Metric(
    'Proactive Work Cost (gross with AOE)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.proactive_work_cost_gross_withAOE),
)
ticket_cost_gross = Metric(
    'Ticket Cost (gross)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_incl_overtime) / SUM(CostMetrics.unique_tickets),
)
ticket_cost_gross_withAOE = Metric(
    'Ticket Cost (gross with AOE)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostMetrics.unique_tickets),
)
iteration_cost_gross = Metric(
    'Iteration Cost (gross)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_incl_overtime) / SUM(CostMetrics.iterations),
)
iteration_cost_gross_withAOE = Metric(
    'Iteration Cost (gross with AOE)',
    '',
    MetricGroup.cost,
    SUM(CostMetrics.sc_work_cost_gross_withAOE_incl_overtime) / SUM(CostMetrics.iterations),
)

total_work_hours_incl_overtime = Metric(
    'Total Work Hours (incl overtime)',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.total_work_hours),
)
sc_work_hours_incl_overtime = Metric(
    'SC Work Hours (incl overtime)',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.sc_hours),
)
sc_work_hours_incl_leaves = Metric(
    'SC Work Hours (incl leaves)',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.sc_paidvacs_hours),
)
sc_work_hours_incl_leaves_overtime = Metric(
    'SC Work Hours (incl leaves and overtime)',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.sc_paidvacs_hours_incl_overtime),
)
proactive_work_hours_incl_leaves = Metric(
    'Proactive Work Hours (incl leaves)',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.proactive_paidvacs_hours),
)
paid_leave_hours = Metric(
    'Paid Leave Hours',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.paid_vacation_hours),
)
unpaid_leave_hours = Metric(
    'Unpaid Leave Hours',
    '',
    MetricGroup.workflow,
    SUM(CostMetrics.free_vacation_hours),
)
overtime_sc_hours = Metric(
    'Overtime',
    '',
    MetricGroup.workflow,
    AVG(CostMetrics.overtime_sc_hours),
)

iterations_per_hour = Metric(
    'Iterations per Hour',
    '',
    MetricGroup.performance,
    SUM(CostMetrics.iterations) / SUM(CostMetrics.sc_hours),
)

tickets_per_hour = Metric(
    'Tickets per Hour',
    '',
    MetricGroup.performance,
    SUM(CostMetrics.unique_tickets) / SUM(CostMetrics.sc_hours),
)
sc_proactive_work_ratio = Metric(
    'SC to Proactive Work Ratio',
    'SC / Proactive Work Ratio',
    MetricGroup.productivity,
    SUM(CostMetrics.sc_paidvacs_hours_incl_overtime) / SUM(CostMetrics.proactive_paidvacs_hours),
)

emp_availability = Metric(
    'Employee Availability',
    'Availability',
    MetricGroup.employees,
    COUNT_DISTINCT(CostMetrics.emp_crmid),
)
emp_level = Metric(
    'Employee Level',
    'Level',
    MetricGroup.employees,
    AVG(CostMetrics.level_value),
)


support_service_cost_gross = Metric.from_metric('Support Service Cost (gross)', '', MetricGroup.cost, sc_work_cost_gross + proactive_work_cost_gross)
support_service_cost_gross_withAOE = Metric.from_metric('Support Service Cost (gross with AOE)', '', MetricGroup.cost, sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE)

work_hour_cost_gross = Metric.from_metric('Work Hour Cost (gross)', '',  MetricGroup.cost, (sc_work_cost_gross + proactive_work_cost_gross) / total_work_hours_incl_overtime)
work_hour_gross_withAOE = Metric.from_metric('Work Hour Cost (gross with AOE)', '', MetricGroup.cost, (sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE) / total_work_hours_incl_overtime)


basic_metrics = {
    ticket_cost_gross.name: ticket_cost_gross,
    iteration_cost_gross.name: iteration_cost_gross,
    iterations_per_hour.name: iterations_per_hour,
    tickets_per_hour.name: tickets_per_hour,
}

advanced_metrics = {
    sc_work_hours_incl_overtime.name: sc_work_hours_incl_overtime,
    # sc_work_hours_incl_leaves.name: sc_work_hours_incl_leaves,
    # sc_work_hours_incl_leaves_overtime.name: sc_work_hours_incl_leaves_overtime,
    proactive_work_hours_incl_leaves.name: proactive_work_hours_incl_leaves,
    total_work_hours_incl_overtime.name: total_work_hours_incl_overtime,
    sc_proactive_work_ratio.name: sc_proactive_work_ratio,
    overtime_sc_hours.name: overtime_sc_hours,
    # sc_work_cost_gross_incl_overtime.name: sc_work_cost_gross_incl_overtime,
}

admin_metrics = {
    # sc_work_cost_gross_withAOE.name: sc_work_cost_gross_withAOE,
    # sc_work_cost_gross_withAOE_incl_overtime.name: sc_work_cost_gross_withAOE_incl_overtime,
    # proactive_work_cost_gross_withAOE.name: proactive_work_cost_gross_withAOE,
    # ticket_cost_gross_withAOE.name: ticket_cost_gross_withAOE,
    # iteration_cost_gross_withAOE.name: iteration_cost_gross_withAOE,
    # work_hour_gross_withAOE.name: work_hour_gross_withAOE,
    # support_service_cost_gross_withAOE.name: support_service_cost_gross_withAOE,
    support_service_cost_gross.name: support_service_cost_gross,
    proactive_work_cost_gross.name: proactive_work_cost_gross,
    work_hour_cost_gross.name: work_hour_cost_gross,
    paid_leave_hours.name: paid_leave_hours,
    unpaid_leave_hours.name: unpaid_leave_hours,
    emp_availability.name: emp_availability,
    emp_level.name: emp_level,
    sc_work_cost_gross.name: sc_work_cost_gross,
}
# yapf: enable

advanced_role_metrics = ChainMap(basic_metrics, advanced_metrics)
admin_role_metrics = ChainMap(basic_metrics, advanced_metrics, admin_metrics)


def is_authorized_metric(metric: str, role: str) -> bool:
    return metric in get_metrics(role)


def get_metric(metric: str, role: str | None) -> Metric:
    return get_metrics(role).get(metric, NONE_METRIC)


def select_metrics(
    role: str | None,
    projector: Callable[[Metric], str] = lambda x: x,
    filter: Callable[[Metric], bool] = lambda x: True,
) -> Iterable:
    return [
        projector(metric) for metric in get_metrics(role).values()
        if filter(metric)
    ]


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
