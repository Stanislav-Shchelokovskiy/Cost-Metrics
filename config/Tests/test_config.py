import pytest
from collections.abc import Callable
from datetime import date
from dateutil.relativedelta import relativedelta
import config
from toolbox.utils.converters import DateTimeToSqlString


# yapf: disable
@pytest.mark.parametrize(
    'from_beginning, res, callable',
    [
        (
            1,
            {
                'start': '2018-01-01',
                'end': DateTimeToSqlString.convert(date.today(), '-'),
            },
            config.get_cost_metrics_period,
        ),
        (
            0,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(months=3, day=1), '-'),
                'end': DateTimeToSqlString.convert(date.today(), '-'),
            },
            config.get_cost_metrics_period,
        ),
        (
            1,
            {
                'start': '20180101',
                'end': DateTimeToSqlString.convert(date.today()),
            },
            config.get_work_on_holidays_period,
        ),
        (
            0,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(months=3, day=1)),
                'end': DateTimeToSqlString.convert(date.today()),
            },
            config.get_work_on_holidays_period,
        ),
    ],
)
# yapf: enable
def test_get_cost_metrics_period(
    from_beginning: int,
    res: dict,
    callable: Callable,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setenv('RECALCULATE_FROM_THE_BEGINNING', from_beginning)
        assert callable() == res
