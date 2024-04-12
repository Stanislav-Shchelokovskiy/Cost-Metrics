DECLARE @json VARCHAR(MAX) = N'{positions_json}'

DROP TABLE IF EXISTS #EmployeePositions;

SELECT  *
INTO    #EmployeePositions
FROM    DXStatisticsV2.dbo.parse_positions(@json)

CREATE CLUSTERED INDEX idx ON #EmployeePositions(id);
