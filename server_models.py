from pydantic import Field
from toolbox.server_models import (
    ServerModel,
    FilterParametersNode,
)


class CostMetricsParams(ServerModel):
    teams: FilterParametersNode | None = Field(alias='Teams')
    tribes: FilterParametersNode | None = Field(alias='Tribes')
    positions: FilterParametersNode | None = Field(alias='Positions')
    employees: FilterParametersNode | None = Field(alias='Employees')
