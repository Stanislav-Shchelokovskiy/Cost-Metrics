from collections.abc import Sequence
from toolbox.sql.meta_data import MetaData, KnotMeta


class WorkOnHolidaysMeta(MetaData):
    crmid = 'crmid'
    date = 'date'
    hours = 'hours'


class NameKnotMeta(MetaData):
    name = KnotMeta.name


class CostmetricsEmployeesMeta(MetaData):
    name = NameKnotMeta.name
    tribe = 'tribe'
    position = 'position'

    def get_key_fields() -> Sequence[str]:
        return (
            CostmetricsEmployeesMeta.tribe,
            CostmetricsEmployeesMeta.position,
            CostmetricsEmployeesMeta.name,
        )


class CostmetricsMeta(MetaData):
    year_month = 'year_month'
    team = 'team'
    tribe_name = 'tribe_name'
    position_name = 'position_name'
    name = 'name'
    level_name = 'level_name'
    hourly_pay_net = 'hourly_pay_net'
    hourly_pay_gross = 'hourly_pay_gross'
    hourly_pay_gross_withAOE = 'hourly_pay_gross_withAOE'
    paid_vacation_hours = 'paid_vacation_hours'
    free_vacation_hours = 'free_vacation_hours'
    paid_hours = 'paid_hours'
    sc_hours = 'sc_hours'
    sc_paidvacs_hours = 'sc_paidvacs_hours'
    sc_paidvacs_hours_incl_overtime = 'sc_paidvacs_hours_incl_overtime'
    overtime_sc_hours = 'overtime_sc_hours'
    proactive_paidvacs_hours = 'proactive_paidvacs_hours'
    unique_tickets = 'unique_tickets'
    iterations = 'iterations'
    total_work_hours = 'total_work_hours'
    sc_work_cost_gross = 'sc_work_cost_gross'
    sc_work_cost_gross_incl_overtime = 'sc_work_cost_gross_incl_overtime'
    sc_work_cost_gross_withAOE = 'sc_work_cost_gross_withAOE'
    proactive_work_cost_gross = 'proactive_work_cost_gross'
    proactive_work_cost_gross_withAOE = 'proactive_work_cost_gross_withAOE'
    sc_work_cost_gross_withAOE_incl_overtime = 'sc_work_cost_gross_withAOE_incl_overtime'

    @staticmethod
    def get_key_fields() -> Sequence[str]:
        return (
            CostmetricsMeta.year_month,
            CostmetricsMeta.name,
        )

    @staticmethod
    def get_conflicting_fields() -> Sequence[str]:
        index_fields = set(CostmetricsMeta.get_key_fields())
        all_fields = set(CostmetricsMeta.get_values())
        return all_fields - index_fields
