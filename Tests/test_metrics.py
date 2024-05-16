import pytest
from Tests.utils import (
    response_is_valid,
    network_post,
)
from Tests.test_case import TestCase
import Tests.cases as cases


# yapf: disable
@pytest.mark.e2e
@pytest.mark.parametrize(
    'resp_file,case', [
        ('ticket_cost_gross', cases.ticket_cost_gross),
        ('iteration_cost_gross', cases.iteration_cost_gross),
        ('iterations_per_hour', cases.iterations_per_hour),
        ('tickets_per_hour', cases.tickets_per_hour),
        ('sc_work_hours_incl_overtime', cases.sc_work_hours_incl_overtime),
        ('proactive_work_hours_incl_leaves', cases.proactive_work_hours_incl_leaves),
        ('total_work_hours_incl_overtime', cases.total_work_hours_incl_overtime),
        ('sc_proactive_work_ratio', cases.sc_proactive_work_ratio),
        ('overtime_sc_hours', cases.overtime_sc_hours),
        ('support_service_cost_gross', cases.support_service_cost_gross),
        ('proactive_work_cost_gross', cases.proactive_work_cost_gross),
        ('work_hour_cost_gross', cases.work_hour_cost_gross),
        ('paid_leave_hours', cases.paid_leave_hours),
        ('unpaid_leave_hours', cases.unpaid_leave_hours),
        ('emp_availability', cases.emp_availability),
        ('emp_level', cases.emp_level),
        ('sc_work_cost_gross', cases.sc_work_cost_gross),
    ]
)
def test_aggregates(resp_file: str, case: TestCase, test_client):
    response = network_post(
        client=test_client,
        url='/CostMetrics/Aggregates?'+
                f'group_by_period={case.group_by}&' +
                    f'range_start={case.start}&' +
                        f'range_end={case.end}&' +
                            f'metric={case.metric}&' +
                                f'role={case.role}',
        body=case.body,
    )
    assert response_is_valid(
        file=resp_file,
        check_file=f'aggs/{resp_file}',
        response=response,
    )


@pytest.mark.e2e
@pytest.mark.parametrize('resp_file,case', [
    ('teams', cases.teams),
    ('tents', cases.tents),
    ('tribes', cases.tribes),
    ('positions', cases.positions),
    ('employees', cases.employees),
])
def test_raw(resp_file: str, case: TestCase, test_client):
    response = network_post(
        client=test_client,
        url='/CostMetrics/Raw?' +
                f'range_start={case.start}&' +
                    f'range_end={case.end}&' +
                        f'role={case.role}',
        body=case.body,
    )
    assert response_is_valid(
        file=resp_file,
        check_file=f'raw/{resp_file}',
        response=response,
    )
