import os
import toolbox.cache.view_state_cache as view_state_cache
from fastapi import FastAPI, Cookie, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object
from toolbox.server_models import ViewState
from repository import LocalRepository
from server_models import CostMetricsParams, AdvancedModeParams


class CustomJSONResponse(Response):
    media_type = 'application/json'


app = FastAPI(default_response_class=CustomJSONResponse)

origins = JSON_to_object.convert(os.environ['CORS_ORIGINS'])

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


@app.get('/CostMetrics/Teams')
async def get_cost_metrics_teams():
    return await LocalRepository.cost_metrics.teams.get_data()


@app.get('/CostMetrics/Tribes')
async def get_cost_metrics_tribes():
    return await LocalRepository.cost_metrics.tribes.get_data()


@app.get('/CostMetrics/Positions')
async def get_cost_metrics_positions():
    return await LocalRepository.cost_metrics.positions.get_data()


@app.get('/CostMetrics/Employees')
async def get_cost_metrics_employees():
    return await LocalRepository.cost_metrics.employees.get_data()


@app.get('/CostMetrics/Period')
async def customers_activity_get_tickets_with_iterations_period():
    return await LocalRepository.cost_metrics.period.get_data()


@app.get('/GroupByPeriods')
async def get_group_by_periods():
    return await LocalRepository.periods.get_group_by_periods_json()


@app.get('/CostMetrics/Metrics')
async def get_metrics(mode: str | None = Cookie(None)):
    return await LocalRepository.cost_metrics.get_metrics(mode=os.environ['ADVANCED_MODE_NAME'])#mode


@app.get('/CostMetrics/AggBy')
async def get_aggbys():
    return await LocalRepository.cost_metrics.get_aggbys()


@app.get('/PeriodsArray')
async def get_periods_array(
    start: str,
    end: str,
    format: str,
):
    return await LocalRepository.periods.generate_periods(
        start=start,
        end=end,
        format=format,
    )


@app.post('/CostMetrics/Aggregates')
async def get_cost_metrics_aggregates(
    group_by_period: str,
    range_start: str,
    range_end: str,
    metric: str,
    body: CostMetricsParams,
    mode: str | None = Cookie(None),
):
    return await LocalRepository.cost_metrics.aggregates.get_data(
        group_by_period=group_by_period,
        range_start=range_start,
        range_end=range_end,
        metric=metric,
        mode=os.environ['ADVANCED_MODE_NAME'],#mode,
        **body.get_field_values(),
    )


@app.post('/CostMetrics/Raw')
async def get_cost_metrics_raw(
    range_start: str,
    range_end: str,
    body: CostMetricsParams,
    mode: str | None = Cookie(None),
):
    return await LocalRepository.cost_metrics.raw.get_data(
        range_start=range_start,
        range_end=range_end,
        mode=os.environ['ADVANCED_MODE_NAME'],  #mode,
        **body.get_field_values(),
    )


@app.post('/EnableAdvancedMode', status_code=status.HTTP_201_CREATED)
async def enable_advanced_mode(body: AdvancedModeParams, response: Response):
    if body.code == os.environ['ADVANCED_MODE_CODE']:
        response.set_cookie(
            key='mode',
            value=os.environ['ADVANCED_MODE_NAME'],
            max_age=2628288,
        )
    else:
        response.status_code = status.HTTP_200_OK


@app.post('/PushState')
def push_state(params: ViewState):
    state_id = view_state_cache.push_state(params.state)
    return state_id


@app.get('/PullState')
def pull_state(state_id: str):
    return view_state_cache.pull_state(state_id)
