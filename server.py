import toolbox.cache.async_cache.view_state_cache as view_state_cache
from collections.abc import Mapping
from fastapi import FastAPI, status, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from prometheus_client import make_asgi_app
from config import cors_origins
from toolbox.utils.fastapi.decorators import with_authorization, AuthResponse
from toolbox.server_models import ViewState
from toolbox.sql.aggs.metrics_usage import track_metric_usage
from repository import LocalRepository
from server_models import CostMetricsParams, EmployeeParams, Range
from utils import authorize_state_access


class CustomJSONResponse(Response):
    media_type = 'application/json'


app = FastAPI(default_response_class=CustomJSONResponse)

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins(),
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)


async def role(response: AuthResponse) -> Mapping:
    json: Mapping = await response.json()
    try:
        apps = json['value']
        app_role_id = apps[0]['appRoleId']
        return {'role': app_role_id}
    except Exception:
        return dict()


@app.get('/CostMetrics/Teams')
async def get_teams():
    return await LocalRepository.metrics.teams.get_data()


@app.get('/CostMetrics/Tribes')
async def get_tribes():
    return await LocalRepository.metrics.tribes.get_data()


@app.get('/CostMetrics/Tents')
async def get_tents():
    return await LocalRepository.metrics.tents.get_data()


@app.get('/CostMetrics/Positions')
async def get_positions():
    return await LocalRepository.metrics.positions.get_data()


@app.post('/CostMetrics/Employees')
async def get_employees(body: EmployeeParams):
    return await LocalRepository.metrics.employees.get_data(
        **body.get_field_values()
    )


@app.get('/CostMetrics/Period')
async def get_period():
    return await LocalRepository.metrics.period.get_data()


@app.get('/GroupByPeriods')
async def get_group_by_periods():
    return await LocalRepository.periods.get_group_by_periods_json()


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


@app.post('/DisplayFilter')
async def get_display_filter(body: CostMetricsParams):
    return await LocalRepository.display_filter.generate_display_filter(body)


@app.get('/CostMetrics/Metrics')
@with_authorization(role)
async def get_metrics(role: str = ''):
    return await LocalRepository.metrics.get_metrics(role=role)


@app.get('/CostMetrics/MetricDescription')
@with_authorization(role)
async def get_help(metric: str, role: str = ''):
    return await LocalRepository.help.get_description(metric, role)


@app.post('/CostMetrics/Aggregates')
@with_authorization(role)
@track_metric_usage(LocalRepository.metrics, 'cost_metrics')
async def get_aggregates(
    group_by_period: str,
    range_start: str,
    range_end: str,
    metric: str,
    body: CostMetricsParams,
    response: Response,
    access_token: str | None = Header(None, alias='Authorization'),
    role: str = '',
):
    return await LocalRepository.metrics.aggregates.get_data(
        group_by_period=group_by_period,
        range=Range(range_start, range_end),
        metric=metric,
        role=role,
        **body.get_field_values(),
    )


@app.post('/CostMetrics/Raw')
@with_authorization(role)
async def get_raw(
    range_start: str,
    range_end: str,
    body: CostMetricsParams,
    response: Response,
    access_token: str | None = Header(None, alias='Authorization'),
    role: str = '',
):
    return await LocalRepository.metrics.raw.get_data(
        range=Range(range_start, range_end),
        role=role,
        **body.get_field_values(),
    )


@app.post('/PushState')
@with_authorization(role)
async def push_state(
    body: ViewState,
    response: Response,
    access_token: str | None = Header(None, alias='Authorization'),
):
    return await view_state_cache.push_state(body.state)


@app.get('/PullState', status_code=status.HTTP_200_OK)
@with_authorization(role)
async def pull_state(
    state_id: str,
    response: Response,
    access_token: str | None = Header(None, alias='Authorization'),
    role: str | None = None,
):
    state = await view_state_cache.pull_state(state_id)
    default = '{}'
    res = await authorize_state_access(
        role=role,
        state=state,
        default=default,
    )
    if state is None:
        response.status_code = status.HTTP_404_NOT_FOUND
    elif res == default:
        response.status_code = status.HTTP_403_FORBIDDEN
    return res


metrics_app = make_asgi_app()
app.mount('/metrics', metrics_app)
