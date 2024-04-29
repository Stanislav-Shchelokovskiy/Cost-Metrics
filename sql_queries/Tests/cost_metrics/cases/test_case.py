from collections.abc import Iterable, Mapping
from typing import Any, Protocol


class TestCase(Protocol):
    params: Mapping[str, Any]
    dtfields: Iterable[str]
    tbl: str
    want: Mapping[str, Any]
    queries: Iterable[str]
