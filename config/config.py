import os
from datetime import date
from dateutil.relativedelta import relativedelta
from toolbox.utils.converters import DateTimeToSqlString


def get_cost_metrics_period() -> dict[str, str]:
    return get_period('-')


def get_work_on_holidays_period() -> dict[str, str]:
    return get_period()


def get_period(separator=''):
    return {
        'start': DateTimeToSqlString.convert(get_start(), separator),
        'end': DateTimeToSqlString.convert(get_end(), separator),
    }


def get_end():
    return date.today()


def get_start():
    if int(os.environ['RECALCULATE_FROM_THE_BEGINNING']) == 1:
        return date(2018, 1, 1)
    return get_end() - offset_in_months()


def offset_in_months():
    return relativedelta(day=1)
