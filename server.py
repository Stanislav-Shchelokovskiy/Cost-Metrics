import os
import toolbox.cache.view_state_cache as view_state_cache
from collections.abc import Coroutine
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object
from toolbox.server_models import ViewState
from repository import LocalRepository
from server_models import CostMetricsParams


app = FastAPI()

origins = JSON_to_object.convert(os.environ['CORS_ORIGINS'])

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


def get_response(json_data: str) -> Response:
    return Response(
        content=json_data,
        media_type='application/json',
    )


async def get_repsonse_async(task: Coroutine):
    return get_response(json_data=await task)


@app.get('/CostMetrics/Teams')
async def get_cost_metrics_teams():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.teams.get_data()
    )


@app.get('/CostMetrics/Tribes')
async def get_cost_metrics_tribes():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.tribes.get_data()
    )


@app.get('/CostMetrics/Positions')
async def get_cost_metrics_positions():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.positions.get_data()
    )


@app.get('/CostMetrics/Employees')
async def get_cost_metrics_employees():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.employees.get_data()
    )


@app.get('/CostMetrics/Period')
async def customers_activity_get_tickets_with_iterations_period():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.period.get_data()
    )


@app.get('/GroupByPeriods')
async def get_group_by_periods():
    return await get_repsonse_async(
        LocalRepository.periods.get_group_by_periods_json()
    )


@app.get('/CostMetrics/Metrics')
async def get_metrics():
    return await get_repsonse_async(LocalRepository.cost_metrics.get_metrics())


@app.get('/CostMetrics/AggBy')
async def get_agg_by():
    return await get_repsonse_async(LocalRepository.cost_metrics.get_agg_bys())


@app.get('/PeriodsArray')
async def get_periods_array(
    start: str,
    end: str,
    format: str,
):
    return await get_repsonse_async(
        LocalRepository.periods.generate_periods(
            start=start,
            end=end,
            format=format,
        )
    )


@app.post('/CostMetrics/Aggregates')
async def get_cost_metrics_aggregates(
    group_by_period: str,
    range_start: str,
    range_end: str,
    metric: str,
    agg_by: str,
    body: CostMetricsParams,
):
    return await get_repsonse_async(
        LocalRepository.cost_metrics.aggregates.get_data(
            group_by_period=group_by_period,
            range_start=range_start,
            range_end=range_end,
            metric=metric,
            agg_by=agg_by,
            **body.get_field_values(),
        )
    )


@app.post('/PushState')
def push_state(params: ViewState):
    state_id = view_state_cache.push_state(params.state)
    return get_response(json_data=state_id)


@app.get('/PullState')
def pull_state(state_id: str):
    state = view_state_cache.pull_state(state_id)
    return get_response(json_data=state)
