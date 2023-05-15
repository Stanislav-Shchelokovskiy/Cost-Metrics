import os
from datetime import date, timedelta
from toolbox.utils.converters import DateTimeToSqlString


def get_cost_metrics_period() -> dict[str, str]:
    return {
        'start': '2018-01-01',
        'end': DateTimeToSqlString.convert(date.today(), '-'),
    }

def get_work_on_holidays_period() -> dict[str, str]:
    today = date.today()
    if int(os.environ['RECALCULATE_FROM_THE_BEGINNING']) == 0: 
        return {
            'start': DateTimeToSqlString.convert(today - timedelta(days=today.weekday())),
            'end': DateTimeToSqlString.convert(today),
        }
    return {
        'start': '20180101',
        'end': DateTimeToSqlString.convert(today),
    }
