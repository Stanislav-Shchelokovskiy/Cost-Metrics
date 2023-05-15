import pytest
from configs.config import get_cost_metrics_period, get_work_on_holidays_period
from datetime import date, timedelta
from toolbox.utils.converters import DateTimeToSqlString


def test_get_cost_metrics_period():
    assert get_cost_metrics_period() == {
        'start': '2018-01-01',
        'end': DateTimeToSqlString.convert(date.today(), '-'),
    }


def test_get_work_on_holidays_period():
    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setenv('RECALCULATE_FROM_THE_BEGINNING', 1)
        get_work_on_holidays_period() == {
            'start': '20180101',
            'end': DateTimeToSqlString.convert(date.today()),
        }

        monkeypatch.setenv('RECALCULATE_FROM_THE_BEGINNING', 0)
        assert get_work_on_holidays_period() == {
            'start': DateTimeToSqlString.convert(date.today() - timedelta(days=date.today().weekday())),
            'end': DateTimeToSqlString.convert(date.today()),
        }
