from typing import Protocol
from server_models import CostMetricsParams


class TestCase(Protocol):
    start: str
    end: str
    group_by: str
    metric: str
    body: CostMetricsParams
    role: str
