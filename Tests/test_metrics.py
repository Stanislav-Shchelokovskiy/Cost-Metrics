import pytest
from Tests.utils import (
    response_is_valid,
    network_post,
)
from Tests.test_case import TestCase
import Tests.cases as cases


@pytest.mark.e2e
@pytest.mark.parametrize(
    'resp_file,case', [
        ('sc_work_hours_incl_overtime', cases.sc_work_hours_incl_overtime),
        ('ticket_cost_gross', cases.ticket_cost_gross),
    ]
)
def test_aggregates(resp_file: str, case: TestCase, test_client):
    response = network_post(
        client=test_client,
        url='/CostMetrics/Aggregates?'+
            f'group_by_period={case.group_by}&'+
                f'range_start={case.start}&'+
                    f'range_end={case.end}&'+
                        f'metric={case.metric}&'+
                            f'role={case.role}',
        body=case.body,
    )
    assert response_is_valid(
        file=resp_file,
        check_file=f'aggs/{resp_file}',
        response=response,
    )
