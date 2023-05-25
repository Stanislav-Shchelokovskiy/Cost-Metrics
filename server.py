import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object
from collections.abc import Coroutine
from repository import LocalRepository
from config import get_cost_metrics_period_json


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


@app.get('/CostMetrics')
async def get_cost_metrics():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.cost_metrics.get_data()
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
    return await get_repsonse_async(get_cost_metrics_period_json())


@app.get('/GroupByPeriods')
async def get_group_by_periods():
    return await get_repsonse_async(
        LocalRepository.periods.get_group_by_periods_json()
    )


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
