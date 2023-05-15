import os
import repository.server_repository as server_repository
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from toolbox.utils.converters import JSON_to_object


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


@app.get('/get_cost_metrics')
def get_cost_metrics():
    # yapf: disable
    #df_json = server_repository.customers_activity_get_tickets_with_iterations_period()
    # yapf: enable
    return get_response(json_data='{"cost": "metrics"}')