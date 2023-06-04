import os
from typing import NamedTuple
from collections.abc import Iterable, Mapping
from collections import ChainMap
from sql_queries.meta.cost_metrics import CostmetricsMeta


class Metric(NamedTuple):
    name: str
    expression: str

    def __str__(self) -> str:
        return self.expression

    def __add__(self, other: 'Metric'):
        return Metric('', f'{self.expression} + {other.expression}')

    def __mul__(self, other: float):
        return Metric('', f'({self.expression}) * {other}')

    def __truediv__(self, other: 'Metric'):
        return Metric('', f'({self.expression}) / {other.expression}')

    def __eq__(self, other: 'Metric') -> bool:
        return self.expression == other.expression

    @classmethod
    def from_metric(cls, name: str, metric: 'Metric'):
        return cls(name, metric.expression)


sc_work_cost_gross_incl_overtime = Metric(
    'SC Work Cost (gross incl overtime)',
    f'SUM({CostmetricsMeta.sc_work_cost_gross_incl_overtime})',
)
sc_work_cost_gross_withAOE_incl_overtime = Metric(
    'SC Work Cost (gross with AOE incl overtime)',
    f'SUM({CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime})',
)
total_work_hours = Metric(
    'Total Work Hours',
    f'SUM({CostmetricsMeta.total_work_hours})',
)
sc_work_cost_gross = Metric(
    'SC Work Cost (gross)',
    f'SUM({CostmetricsMeta.sc_work_cost_gross})',
)
sc_work_cost_gross_withAOE = Metric(
    'SC Work Cost (gross with AOE)',
    f'SUM({CostmetricsMeta.sc_work_cost_gross_withAOE})',
)
proactive_work_cost_gross = Metric(
    'Proactive Work Cost (gross)',
    f'SUM({CostmetricsMeta.proactive_work_cost_gross})',
)
proactive_work_cost_gross_withAOE = Metric(
    'Proactive Work Cost (gross with AOE)',
    f'SUM({CostmetricsMeta.proactive_work_cost_gross_withAOE})',
)
ticket_cost_gross = Metric(
    'Ticket Cost (gross)',
    f'IIF(SUM({CostmetricsMeta.unique_tickets})	= 0, 0, SUM({CostmetricsMeta.sc_work_cost_gross_incl_overtime}) * 1.0 / SUM({CostmetricsMeta.unique_tickets}))',
)
ticket_cost_gross_withAOE = Metric(
    'Ticket Cost (gross with AOE)',
    f'IIF(SUM({CostmetricsMeta.unique_tickets})	= 0, 0, SUM({CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime}) * 1.0 / SUM({CostmetricsMeta.unique_tickets}))',
)
iteration_cost_gross = Metric(
    'Iteration Cost (gross)',
    f'IIF(SUM({CostmetricsMeta.iterations})	= 0, 0, SUM({CostmetricsMeta.sc_work_cost_gross_incl_overtime}) * 1.0 / SUM({CostmetricsMeta.iterations}))',
)
iteration_cost_gross_withAOE = Metric(
    'Iteration Cost (gross with AOE)',
    f'IIF(SUM({CostmetricsMeta.iterations})	= 0, 0, SUM({CostmetricsMeta.sc_work_cost_gross_withAOE_incl_overtime}) * 1.0 / SUM({CostmetricsMeta.iterations}))',
)
iterations_per_hour = Metric(
    'Iterations per hour',
    f'IIF(SUM({CostmetricsMeta.sc_hours})	= 0, 0, SUM({CostmetricsMeta.iterations}) * 1.0 / SUM({CostmetricsMeta.sc_hours}))',
)
tickets_per_hour = Metric(
    'Tickets per hour',
    f'IIF(SUM({CostmetricsMeta.sc_hours})	= 0, 0, SUM({CostmetricsMeta.unique_tickets}) * 1.0 / SUM({CostmetricsMeta.sc_hours}))',
)

# yapf: disable
fot_gross = Metric.from_metric('FOT (gross)', sc_work_cost_gross + proactive_work_cost_gross)
fot_gross_withAOE = Metric.from_metric('FOT (gross with AOE)', sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE)

hour_price_gross = Metric.from_metric('Hour price (gross)', (sc_work_cost_gross+proactive_work_cost_gross) * 1.0 / total_work_hours)
hour_price_gross_withAOE = Metric.from_metric('Hour price (gross with AOE)', (sc_work_cost_gross_withAOE + proactive_work_cost_gross_withAOE) * 1.0 / total_work_hours)


metrics = {
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


advanced_metrics = {
    fot_gross.name: fot_gross,
    fot_gross_withAOE.name: fot_gross_withAOE,
}


none_metric = Metric('Fake', 'SUM(0)')
def get_metric(kwargs: dict) -> Metric:
    metrics = get_metrics(kwargs['mode'])
    return metrics.get(kwargs['metric'], none_metric)


def get_metrics_descs(mode: str | None) -> Iterable[Mapping[str, Metric]]:
    res = get_metrics(mode)
    return [{'name': x} for x in res.keys()]


def get_metrics(mode: str | None)-> Mapping[str, Metric]:
    return ChainMap(advanced_metrics, metrics) if advanced_mode_enabled(mode) else metrics


def advanced_mode_enabled(mode: str | None) -> bool:
    return mode == os.environ['ADVANCED_MODE_NAME']
# yapf: enable
