from enum import Enum
from celery.schedules import crontab
from datetime import date
from dateutil.relativedelta import relativedelta
from toolbox.utils.converters import DateTimeToSqlString
from toolbox.utils.env import recalculate_from_beginning, recalculate_for_last_n_months


class Format(Enum):
    WORKFLOW = 'workflow'
    COSTMETRICS = 'costmetrics'
    SQLITE = 'sqlite'


def get_period(format: Format) -> dict[str, str]:
    separator = '' if format == Format.WORKFLOW else '-'
    return {
        'start': DateTimeToSqlString.convert(get_start(), separator),
        'end': DateTimeToSqlString.convert(get_end(), separator),
    }


def get_end():
    return date.today()


def get_start():
    if recalculate_from_beginning():
        return get_end() - relativedelta(days=365 * 5)
    return get_end() - offset_in_months()


def offset_in_months():
    months = recalculate_for_last_n_months()
    return relativedelta(day=1, months=months)


def years_of_history(format: str):
    return {
        Format.SQLITE: '5 YEARS',
    }[format]


def get_schedule():
    """
    Returns schedule which runs calculation every first day of each month for last N months.
    So, RECALCULATE_FOR_LAST_MONTHS should be 1 or greater.
    """
    return crontab(
        minute=0,
        hour=1,
        day_of_month=1,
    )
