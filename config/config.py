import os
from datetime import date
from dateutil.relativedelta import relativedelta
from toolbox.utils.converters import DateTimeToSqlString
from toolbox.utils.env import recalculate_from_beginning


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
    if recalculate_from_beginning():
        return date(2018, 1, 1)
    return get_end() - offset_in_months()


def offset_in_months():
    months = int(os.environ.get('RECALCULATE_FOR_LAST_MONTHS', 0))
    return relativedelta(day=1, months=months)
