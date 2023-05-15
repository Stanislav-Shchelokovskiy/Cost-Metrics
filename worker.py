from collections.abc import Callable

from celery import Celery, chord
from celery.schedules import crontab
from celery.signals import worker_ready

import tasks.wf_tasks as wf_tasks
import configs.config as config


app = Celery(__name__)


@worker_ready.connect
def on_startup(sender, **kwargs):
    tasks = [
        'upsert_work_on_holidays',
    ]

    sender_app: Celery = sender.app
    with sender_app.connection() as conn:
        for task in tasks:
            sender_app.send_task(
                name=task,
                connection=conn,
            )


@app.on_after_configure.connect
def setup_periodic_tasks(sender, **kwargs):
    sender.add_periodic_task(
        crontab(
            minute=0,
            hour=1,
            day_of_week='1-5',
        ),
        upsert_work_on_holidays.s(),
    )


@app.task(name='upsert_work_on_holidays', bind=True)
def upsert_work_on_holidays(self, **kwargs):
    return run_retriable_task(
        self,
        wf_tasks.upsert_work_on_holidays,
        **config.get_work_on_holidays_period(),
    )


def run_retriable_task(task_instance, task: Callable, *args, **kwargs) -> str:
    try:
        return task(*args, **kwargs)
    except Exception as e:
        raise task_instance.retry(exc=e, countdown=600, max_retries=10)
