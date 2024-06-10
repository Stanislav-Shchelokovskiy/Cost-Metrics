from typing import Any
from collections.abc import Sequence, Callable
from toolbox.sql.meta_data import MetaData
from toolbox.sql.field import Field, TEXT, NUMERIC, INTEGER
import toolbox.sql.generators.sqlite.statements as sqlite_index


class CostMetrics(MetaData):
    year_month = Field(TEXT)
    emp_scid = Field(TEXT)
    emp_crmid = Field(TEXT)
    position_id = Field(TEXT)
    tribe_id = Field(TEXT)
    tent_id = Field(TEXT)
    team = Field(TEXT)
    tribe_name = Field(TEXT)
    tent_name = Field(TEXT)
    name = Field(TEXT)
    position_name = Field(TEXT)
    level_name = Field(TEXT)
    level_value = Field(NUMERIC)
    hourly_pay_net = Field(NUMERIC)
    hourly_pay_gross = Field(NUMERIC)
    hourly_pay_gross_withAOE = Field(NUMERIC)
    paid_vacation_hours = Field(NUMERIC)
    free_vacation_hours = Field(NUMERIC)
    paid_hours = Field(NUMERIC)
    sc_hours = Field(NUMERIC)
    sc_paidvacs_hours = Field(NUMERIC)
    sc_paidvacs_hours_incl_overtime = Field(NUMERIC)
    overtime_sc_hours = Field(NUMERIC)
    proactive_paidvacs_hours = Field(NUMERIC)
    unique_tickets = Field(INTEGER)
    iterations = Field(INTEGER)
    total_work_hours = Field(NUMERIC)
    sc_work_cost_gross = Field(NUMERIC)
    sc_work_cost_gross_incl_overtime = Field(NUMERIC)
    sc_work_cost_gross_withAOE = Field(NUMERIC)
    proactive_work_cost_gross = Field(NUMERIC)
    proactive_work_cost_gross_withAOE = Field(NUMERIC)
    sc_work_cost_gross_withAOE_incl_overtime = Field(NUMERIC)

    @classmethod
    def get_indices(cls) -> Sequence[str]:
        tbl = cls.get_name()
        return (
            sqlite_index.create_index(
                tbl=tbl,
                cols=(
                    cls.year_month,
                    cls.team,
                    cls.tribe_id,
                    cls.tent_id,
                    cls.position_id,
                    cls.emp_scid,
                ),
            ),
        )

    @classmethod
    def get_key_fields(
        cls,
        projector: Callable[[Field], Any] = str,
        *exfields: Field,
    ) -> Sequence[str]:
        return MetaData.get_key_fields(
            projector,
            cls.year_month,
            cls.emp_scid,
        )
