import pytest
import os
from pathlib import Path
from Tests.env import with_env
from fastapi.testclient import TestClient
from toolbox.sql.sql_query import SqlQuery
from toolbox.sql.query_executors.sqlite_query_executor import SQLiteNonQueryExecutor


client = None


@with_env
def create_client():
    global client
    from server import app
    client = TestClient(app=app)


@pytest.fixture
def test_client() -> TestClient:
    if not client:
        create_client()
    return client


def pytest_configure(config: pytest.Config):
    #if 'e2e' in config.invocation_params.args:
    build_db()


@with_env
def build_db():
    Path(os.environ['SQLITE_DATABASE']).unlink(True)

    SQLiteNonQueryExecutor().execute(
        prep_queries=[
            SqlQuery(
                query_file_path='Tests/migrations.sql',
                format_params={},
            )
        ]
    )
