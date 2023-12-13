import pytest
from datetime import date
from dateutil.relativedelta import relativedelta
import config
from toolbox.utils.converters import DateTimeToSqlString


# yapf: disable
@pytest.mark.parametrize(
    'from_beginning, last_months, res, format',
    [
        (
            1,
            3,
            {
                'start': '2018-01-01',
                'end': DateTimeToSqlString.convert(date.today(), '-'),
            },
            config.Format.COSTMETRICS,
        ),
        (
            0,
            0,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(day=1), '-'),
                'end': DateTimeToSqlString.convert(date.today(), '-'),
            },
            config.Format.COSTMETRICS,
        ),
        (
            0,
            3,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(day=1, months=3), '-'),
                'end': DateTimeToSqlString.convert(date.today(), '-'),
            },
            config.Format.COSTMETRICS,
        ),
        (
            1,
            3,
            {
                'start': '20180101',
                'end': DateTimeToSqlString.convert(date.today()),
            },
            config.Format.WORKFLOW,
        ),
        (
            0,
            0,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(day=1)),
                'end': DateTimeToSqlString.convert(date.today()),
            },
            config.Format.WORKFLOW,
        ),
         (
            0,
            3,
            {
                'start': DateTimeToSqlString.convert(date.today() - relativedelta(day=1, months=3)),
                'end': DateTimeToSqlString.convert(date.today()),
            },
            config.Format.WORKFLOW,
        ),
    ],
)
# yapf: enable
def test_get_cost_metrics_period(
    from_beginning: int,
    last_months: int,
    res: dict,
    format: str,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.setenv('RECALCULATE_FROM_THE_BEGINNING', from_beginning)
        monkeypatch.setenv('RECALCULATE_FOR_LAST_MONTHS', last_months)
        assert config.get_period(format) == res
