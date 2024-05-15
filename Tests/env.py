import pytest
from os import getcwd
from wrapt import decorator
from collections.abc import Callable, Iterable


ADVANCED = 'advanced'
ADMIN = 'admin'


def __prepare_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setenv('SQLITE_DATABASE', f'{getcwd()}/Tests/test_db')
    monkeypatch.setenv('AUTH_ENABLED', 0)
    monkeypatch.setenv('SERVER_PORT', 11003)
    monkeypatch.setenv('CORS_ORIGINS', [])
    monkeypatch.setenv('ADMIN_ROLE', ADMIN)
    monkeypatch.setenv('ADVANCED_ROLE', ADVANCED)
    monkeypatch.setenv('REDIS_SERVICE', 'localhost')
    monkeypatch.setenv('REDIS_PORT', '6379')


@decorator
def with_env(
    callable: Callable[..., None],
    instance,
    args: Iterable,
    kwargs: dict,
):
    with pytest.MonkeyPatch.context() as monkeypatch:
        __prepare_env(monkeypatch)
        return callable(**kwargs)
