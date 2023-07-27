from pydantic import Field
from toolbox.server_models import (
    ServerModel,
    FilterParametersNode,
)


class EmployeeParams(ServerModel):
    teams: FilterParametersNode[str] | None = Field(alias='Teams')
    tribes: FilterParametersNode[str] | None = Field(alias='Tribes')
    tents: FilterParametersNode[str] | None = Field(alias='Tents')
    positions: FilterParametersNode[str] | None = Field(alias='Positions')


class CostMetricsParams(EmployeeParams):
    employees: FilterParametersNode[str] | None = Field(alias='Employees')
