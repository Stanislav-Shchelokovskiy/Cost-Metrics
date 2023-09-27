from collections.abc import Sequence
from toolbox.sql.meta_data import MetaData, KnotMeta


class WFMeta(MetaData):
    crmid = 'crmid'
    date = 'date'
    hours = 'hours'


class NameKnotMeta(MetaData):
    name = KnotMeta.name


class CostmetricsEmployeesMeta(MetaData):
    crmid = 'crmid'
    name = NameKnotMeta.name
    team = 'team'
    tribe = 'tribe'
    tent = 'tent'
    position = 'position'

    @classmethod
    def get_index_fields(
         cls,
        *args,
        **kwargs,
    ) -> Sequence[str]:
        return (
            cls.team,
            cls.tribe,
            cls.tent,
            cls.position,
            cls.name,
            cls.crmid,
        )


class CostmetricsMeta(MetaData):
    emp_crmid = 'emp_crmid'
    emp_scid = 'emp_scid'
    position_id = 'position_id'
    tribe_id = 'tribe_id'
    tent_id = 'tent_id'
    year_month = 'year_month'
    team = 'team'
    tribe_name = 'tribe_name'
    tent_name = 'tent_name'
    position_name = 'position_name'
    name = 'name'
    level_name = 'level_name'
    level_value = 'level_value'
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

    @classmethod
    def get_index_fields(
         cls,
        *args,
        **kwargs,
    ) -> Sequence[str]:
        return (
            cls.year_month,
            cls.team,
            cls.tribe_id,
            cls.tent_id,
            cls.position_id,
            cls.emp_scid,
        )

    @classmethod
    def get_key_fields(
        cls,
        *args,
        **kwargs,
    ) -> Sequence[str]:
        return (
            cls.year_month,
            cls.emp_scid,
        )
