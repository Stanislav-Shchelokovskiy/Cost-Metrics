from pydantic import Field
from toolbox.server_models import (
    ServerModel,
    FilterParametersNode,
)


class CostMetricsParams(ServerModel):
    teams: FilterParametersNode[str] | None = Field(alias='Teams')
    tribes: FilterParametersNode[str] | None = Field(alias='Tribes')
    positions: FilterParametersNode[str] | None = Field(alias='Positions')
    employees: FilterParametersNode[str] | None = Field(alias='Employees')


class EmployeeParams(ServerModel):
    tribes: FilterParametersNode
    positions: FilterParametersNode
