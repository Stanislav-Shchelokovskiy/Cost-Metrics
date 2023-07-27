from collections.abc import Callable

from celery import Celery, chord, chain
from celery.schedules import crontab
from celery.signals import worker_ready

import tasks.wf_tasks as wf_tasks
import tasks.cost_metrics_tasks as cost_metrics_tasks
import config as config


app = Celery(__name__)
app.conf.setdefault('broker_connection_retry_on_startup', True)


@worker_ready.connect
def on_startup(sender, **kwargs):
    tasks = [
        'update_cost_metrics',
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
            day_of_week=1,
        ),
        update_cost_metrics.s(),
    )


@app.task(name='update_cost_metrics')
def update_cost_metrics(**kwargs):
    chord([
        chain(
            upsert_wf_work_hours.si(),
            upsert_cost_metrics.si(),
        ),
    ])(cost_metrics_process_staged_data.si())


@app.task(name='upsert_wf_work_hours', bind=True)
def upsert_wf_work_hours(self, **kwargs):
    return run_retriable_task(
        self,
        wf_tasks.upsert_work_hours,
        **config.get_work_on_holidays_period(),
    )


@app.task(name='upsert_cost_metrics', bind=True)
def upsert_cost_metrics(self, **kwargs):
    return run_retriable_task(
        self,
        cost_metrics_tasks.update_cost_metrics,
        kwargs=config.get_cost_metrics_period(),
    )


@app.task(name='cost_metrics_process_staged_data', bind=True)
def cost_metrics_process_staged_data(self, **kwargs):
    return run_retriable_task(
        self,
        cost_metrics_tasks.process_staged_data,
    )


def run_retriable_task(task_instance, task: Callable, *args, **kwargs) -> str:
    try:
        return task(*args, **kwargs)
    except Exception as e:
        raise task_instance.retry(exc=e, countdown=600, max_retries=10)
