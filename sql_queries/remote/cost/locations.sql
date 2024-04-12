DECLARE @json VARCHAR(MAX) = N'{locations_json}'

DROP TABLE IF EXISTS #EmployeeLocations;

SELECT  *
INTO    #EmployeeLocations
FROM    DXStatisticsV2.dbo.parse_locations(@json)

CREATE CLUSTERED INDEX idx ON #EmployeeLocations(id);
