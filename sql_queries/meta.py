from collections.abc import Sequence
from toolbox.sql.meta_data import MetaData, KnotMeta


class WorkOnHolidaysMeta(MetaData):
    crmid = 'crmid'
    date = 'date'
    hours = 'hours'


class NameKnotMeta(MetaData):
    name = KnotMeta.name


class CostmetricsEmployeesMeta(MetaData):
    name = 'name'
    tribe = 'tribe'

    def get_key_fields() -> Sequence[str]:
        return (
            CostmetricsEmployeesMeta.tribe,
            CostmetricsEmployeesMeta.name,
        )


class CostmetricsMeta(MetaData):
    year_month = 'year_month'
    emp_tribe_name = 'emp_tribe_name'
    emp_name = 'emp_name'
    position_name = 'position_name'
    emp_level_name = 'emp_level_name'
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
    emp_sc_work_cost_gross_incl_overtime = 'emp_sc_work_cost_gross_incl_overtime'
    emp_sc_work_cost_gross_withAOE_incl_overtime = 'emp_sc_work_cost_gross_withAOE_incl_overtime'
    emp_total_work_hours = 'emp_total_work_hours'
    tribe_total_work_hours = 'tribe_total_work_hours'
    chapter_total_work_hours = 'chapter_total_work_hours'
    emp_sc_work_cost_gross = 'emp_sc_work_cost_gross'
    tribe_sc_work_cost_gross = 'tribe_sc_work_cost_gross'
    chapter_sc_work_cost_gross = 'chapter_sc_work_cost_gross'
    emp_sc_work_cost_gross_withAOE = 'emp_sc_work_cost_gross_withAOE'
    tribe_sc_work_cost_gross_with_AOE = 'tribe_sc_work_cost_gross_with_AOE'
    chapter_sc_work_cost_gross_withAOE = 'chapter_sc_work_cost_gross_withAOE'
    emp_proactive_work_cost_gross = 'emp_proactive_work_cost_gross'
    tribe_proactive_work_cost_gross = 'tribe_proactive_work_cost_gross'
    chapter_proactive_work_cost_gross = 'chapter_proactive_work_cost_gross'
    emp_proactive_work_cost_gross_withAOE = 'emp_proactive_work_cost_gross_withAOE'
    tribe_proactive_work_cost_gross_withAOE = 'tribe_proactive_work_cost_gross_withAOE'
    chapter_proactive_work_cost_gross_withAOE = 'chapter_proactive_work_cost_gross_withAOE'
    emp_ticket_cost_gross = 'emp_ticket_cost_gross'
    tribe_ticket_cost_gross = 'tribe_ticket_cost_gross'
    chapter_ticket_cost_gross = 'chapter_ticket_cost_gross'
    emp_ticket_cost_gross_withAOE = 'emp_ticket_cost_gross_withAOE'
    tribe_ticket_cost_gross_withAOE = 'tribe_ticket_cost_gross_withAOE'
    chapter_ticket_cost_gross_withAOE = 'chapter_ticket_cost_gross_withAOE'
    emp_iteration_cost_gross = 'emp_iteration_cost_gross'
    tribe_iteration_cost_gross = 'tribe_iteration_cost_gross'
    chapter_iteration_cost_gross = 'chapter_iteration_cost_gross'
    emp_iteration_cost_gross_withAOE = 'emp_iteration_cost_gross_withAOE'
    tribe_iteration_cost_gross_withAOE = 'tribe_iteration_cost_gross_withAOE'
    chapter_iteration_cost_gross_withAOE = 'chapter_iteration_cost_gross_withAOE'
    emp_iterations_per_hour = 'emp_iterations_per_hour'
    tribe_iterations_per_hour = 'tribe_iterations_per_hour'
    chapter_iterations_per_hour = 'chapter_iterations_per_hour'
    emp_hours_per_ticket = 'emp_hours_per_ticket'
    emp_tickets_per_hour = 'emp_tickets_per_hour'
    tribe_tickets_per_hour = 'tribe_tickets_per_hour'
    chapter_tickets_per_hour = 'chapter_tickets_per_hour'
    tribe_fot_gross = 'tribe_fot_gross'
    tribe_fot_gross_withAOE = 'tribe_fot_gross_withAOE'
    chapter_fot_gross = 'chapter_fot_gross'
    chapter_fot_gross_withAOE = 'chapter_fot_gross_withAOE'
    tribe_hour_price_gross = 'tribe_hour_price_gross'
    tribe_hour_price_gross_withAOE = 'tribe_hour_price_gross_withAOE'
    chapter_hour_price_gross = 'chapter_hour_price_gross'
    chapter_hour_price_gross_withAOE = 'chapter_hour_price_gross_withAOE'
    is_dev_team = 'is_dev_team'

    @staticmethod
    def get_metrics() -> Sequence[str]:
        return (
            {'name':CostmetricsMeta.emp_total_work_hours},
            {'name':CostmetricsMeta.tribe_total_work_hours},
            {'name':CostmetricsMeta.chapter_total_work_hours},
            {'name':CostmetricsMeta.emp_sc_work_cost_gross},
            {'name':CostmetricsMeta.tribe_sc_work_cost_gross},
            {'name':CostmetricsMeta.chapter_sc_work_cost_gross},
            {'name':CostmetricsMeta.emp_sc_work_cost_gross_withAOE},
            {'name':CostmetricsMeta.tribe_sc_work_cost_gross_with_AOE},
            {'name':CostmetricsMeta.chapter_sc_work_cost_gross_withAOE},
            {'name':CostmetricsMeta.emp_proactive_work_cost_gross},
            {'name':CostmetricsMeta.tribe_proactive_work_cost_gross},
            {'name':CostmetricsMeta.chapter_proactive_work_cost_gross},
            {'name':CostmetricsMeta.emp_proactive_work_cost_gross_withAOE},
            {'name':CostmetricsMeta.tribe_proactive_work_cost_gross_withAOE},
            {'name':CostmetricsMeta.chapter_proactive_work_cost_gross_withAOE},
            {'name':CostmetricsMeta.emp_ticket_cost_gross},
            {'name':CostmetricsMeta.tribe_ticket_cost_gross},
            {'name':CostmetricsMeta.chapter_ticket_cost_gross},
            {'name':CostmetricsMeta.emp_ticket_cost_gross_withAOE},
            {'name':CostmetricsMeta.tribe_ticket_cost_gross_withAOE},
            {'name':CostmetricsMeta.chapter_ticket_cost_gross_withAOE},
            {'name':CostmetricsMeta.emp_iteration_cost_gross},
            {'name':CostmetricsMeta.tribe_iteration_cost_gross},
            {'name':CostmetricsMeta.chapter_iteration_cost_gross},
            {'name':CostmetricsMeta.emp_iteration_cost_gross_withAOE},
            {'name':CostmetricsMeta.tribe_iteration_cost_gross_withAOE},
            {'name':CostmetricsMeta.chapter_iteration_cost_gross_withAOE},
            {'name':CostmetricsMeta.emp_iterations_per_hour},
            {'name':CostmetricsMeta.tribe_iterations_per_hour},
            {'name':CostmetricsMeta.chapter_iterations_per_hour},
            {'name':CostmetricsMeta.emp_hours_per_ticket},
            {'name':CostmetricsMeta.emp_tickets_per_hour},
            {'name':CostmetricsMeta.tribe_tickets_per_hour},
            {'name':CostmetricsMeta.chapter_tickets_per_hour},
            {'name':CostmetricsMeta.tribe_fot_gross},
            {'name':CostmetricsMeta.tribe_fot_gross_withAOE},
            {'name':CostmetricsMeta.chapter_fot_gross},
            {'name':CostmetricsMeta.chapter_fot_gross_withAOE},
            {'name':CostmetricsMeta.tribe_hour_price_gross},
            {'name':CostmetricsMeta.tribe_hour_price_gross_withAOE},
            {'name':CostmetricsMeta.chapter_hour_price_gross},
            {'name':CostmetricsMeta.chapter_hour_price_gross_withAOE},
        )

    @staticmethod
    def get_key_fields() -> Sequence[str]:
        return (
            CostmetricsMeta.year_month,
            CostmetricsMeta.emp_tribe_name,
            CostmetricsMeta.position_name,
            CostmetricsMeta.emp_level_name,
            CostmetricsMeta.emp_name,
        )

    @staticmethod
    def get_conflicting_fields() -> Sequence[str]:
        index_fields = set(CostmetricsMeta.get_key_fields())
        all_fields = set(CostmetricsMeta.get_values())
        return all_fields - index_fields
