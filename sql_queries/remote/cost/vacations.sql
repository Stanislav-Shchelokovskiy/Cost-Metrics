DECLARE @json VARCHAR(MAX) = N'{vacations_json}'

DROP TABLE IF EXISTS #EmployeeVacations;

SELECT	*,
		DATEADD(HOUR, 24 * days, vac_start) AS vac_end
INTO 	#EmployeeVacations
FROM	DXStatisticsV2.dbo.parse_vacations(@json)
