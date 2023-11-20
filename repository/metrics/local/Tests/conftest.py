import pytest
import toolbox.sql.generators.Tests.filter_cases as filter_cases


@pytest.fixture(scope='module')
def single_in_filter_cases():
    return filter_cases.single_in_filter_cases


@pytest.fixture
def right_half_open_interval_filter_cases():
    return filter_cases.right_half_open_interval_filter_cases
