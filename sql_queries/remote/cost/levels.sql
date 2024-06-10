DECLARE @json VARCHAR(MAX) = N'{levels_json}'

DROP TABLE IF EXISTS #EmployeeLevels;

SELECT  *
INTO    #EmployeeLevels
FROM    DXStatisticsV2.dbo.parse_levels(@json)

CREATE CLUSTERED INDEX idx ON #EmployeeLevels(id);
