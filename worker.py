import os
from collections.abc import Callable

from celery import Celery, chord, chain
from celery.signals import worker_ready

import tasks.wf_tasks as wf_tasks
import tasks.cost_metrics_tasks as cost_metrics_tasks
import tasks.employees as employees
import config as config


app = Celery(__name__)
app.conf.setdefault('broker_connection_retry_on_startup', True)


@worker_ready.connect
def on_startup(sender, **kwargs):
    if not int(os.environ['UPDATE_ON_STARTUP']):
        return

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
        config.get_schedule(),
        update_cost_metrics.s(),
    )


@app.task(name='get_employees', bind=True)
def get_employees(self, **kwargs):
    return run_retriable_task(
        self,
        employees.get_employees,
        **config.get_period(config.Format.COSTMETRICS),
    )


@app.task(name='get_employees_audit', bind=True)
def get_employees_audit(self, *args, **kwargs):
    return run_retriable_task(
        self,
        employees.get_employees_audit,
        employees_json=args[0],
    )


@app.task(name='get_vacations', bind=True)
def get_vacations(self, *args, **kwargs):
    return run_retriable_task(
        self,
        employees.get_vacations,
        *args[0],
        **config.get_period(config.Format.COSTMETRICS),
    )


@app.task(name='get_positions', bind=True)
def get_positions(self, *args, **kwargs):
    return run_retriable_task(
        self,
        employees.get_positions,
        *args[0],
    )


@app.task(name='get_locations', bind=True)
def get_locations(self, *args, **kwargs):
    return run_retriable_task(
        self,
        employees.get_locations,
        *args[0],
    )


@app.task(name='get_levels', bind=True)
def get_levels(self, *args, **kwargs):
    return run_retriable_task(
        self,
        employees.get_levels,
        *args[0],
    )


@app.task(name='update_cost_metrics')
def update_cost_metrics(**kwargs):
    chord(
        [
            chain(
                upsert_wf_work_hours.si(),
                get_employees.si(),
                get_employees_audit.s(),
                get_vacations.s(),
                get_positions.s(),
                get_locations.s(),
                get_levels.s(),
                upsert_cost_metrics.s(),
            ),
        ]
    )(process_staged_data.si())


@app.task(name='upsert_wf_work_hours', bind=True)
def upsert_wf_work_hours(self, **kwargs):
    return run_retriable_task(
        self,
        wf_tasks.upsert_work_hours,
        **config.get_period(config.Format.WORKFLOW),
    )


@app.task(name='upsert_cost_metrics', bind=True)
def upsert_cost_metrics(self, *args, **kwargs):
    (
        employees,
        employees_audit,
        employees_positions_audit,
        vacations,
        positions,
        locations,
        levels,
    ) = args[0]
    return run_retriable_task(
        self,
        cost_metrics_tasks.upsert_cost_metrics,
        kwargs=config.get_period(config.Format.COSTMETRICS),
        employees_json=employees,
        employees_audit_json=employees_audit,
        employees_positions_audit_json=employees_positions_audit,
        vacations_json=vacations,
        positions_json=positions,
        locations_json=locations,
        levels_json=levels,
    )


@app.task(name='cost_metrics_process_staged_data', bind=True)
def process_staged_data(self, **kwargs):
    return run_retriable_task(
        self,
        cost_metrics_tasks.process_staged_data,
        years_of_history=config.years_of_history(config.Format.SQLITE),
    )


def run_retriable_task(task_instance, task: Callable, *args, **kwargs) -> str:
    try:
        return task(*args, **kwargs)
    except Exception as e:
        raise task_instance.retry(exc=e, countdown=600, max_retries=10)
