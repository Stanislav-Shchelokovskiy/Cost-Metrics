DECLARE @json VARCHAR(MAX) = N'{employees_json}'

DROP TABLE IF EXISTS #EmployeesFromJson;

SELECT	*
INTO    #EmployeesFromJson
FROM    DXStatisticsV2.dbo.parse_employees(@json)
