import os
import toolbox.cache.view_state_cache as view_state_cache
from fastapi import FastAPI, Cookie, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object
from toolbox.server_models import ViewState
from repository import LocalRepository
from server_models import CostMetricsParams, EmployeeParams
from utils import authorize_state_access


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


@app.post('/CostMetrics/Employees')
async def get_cost_metrics_employees(body: EmployeeParams):
    return await LocalRepository.cost_metrics.employees.get_data(
        **body.get_field_values()
    )


@app.get('/CostMetrics/Period')
async def customers_activity_get_tickets_with_iterations_period():
    return await LocalRepository.cost_metrics.period.get_data()


@app.get('/GroupByPeriods')
async def get_group_by_periods():
    return await LocalRepository.periods.get_group_by_periods_json()


@app.get('/CostMetrics/Metrics')
async def get_metrics(role: str | None = Cookie(None)):
    return await LocalRepository.cost_metrics.get_metrics(role=role)


@app.get('/CostMetrics/MetricDescription')
async def get_help(metric: str, role: str | None = Cookie(None)):
    return await LocalRepository.help.get_description(metric, role)


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
    role: str | None = Cookie(None),
):
    return await LocalRepository.cost_metrics.aggregates.get_data(
        group_by_period=group_by_period,
        range_start=range_start,
        range_end=range_end,
        metric=metric,
        role=role,
        **body.get_field_values(),
    )


@app.post('/DisplayFilter')
async def get_display_filter(body: CostMetricsParams):
    return await LocalRepository.display_filter.generate_display_filter(body)


@app.post('/CostMetrics/Raw')
async def get_cost_metrics_raw(
    range_start: str,
    range_end: str,
    body: CostMetricsParams,
    role: str | None = Cookie(None),
):
    return await LocalRepository.cost_metrics.raw.get_data(
        range_start=range_start,
        range_end=range_end,
        role=role,
        **body.get_field_values(),
    )


@app.post('/PushState')
def push_state(params: ViewState):
    state_id = view_state_cache.push_state(params.state)
    return state_id


@app.get('/PullState', status_code=status.HTTP_200_OK)
def pull_state(
    state_id: str,
    response: Response,
    role: str | None = Cookie(None),
):
    state = view_state_cache.pull_state(state_id)
    default = '{}'
    res = authorize_state_access(
        role=role,
        state=state,
        default=default,
    )
    if state is None:
        response.status_code = status.HTTP_404_NOT_FOUND
    elif res == default:
        response.status_code = status.HTTP_403_FORBIDDEN
    return res
