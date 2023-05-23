import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object
from collections.abc import Coroutine
from repository import LocalRepository


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


@app.get('/cost_metrics')
async def get_cost_metrics():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.cost_metrics.get_data()
    )


@app.get('/cost_metrics/tribes')
async def get_cost_metrics_tribes():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.tribes.get_data()
    )


@app.get('/cost_metrics/positions')
async def get_cost_metrics_positions():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.positions.get_data()
    )


@app.get('/cost_metrics/employees')
async def get_cost_metrics_employees():
    return await get_repsonse_async(
        LocalRepository.cost_metrics.employees.get_data()
    )
