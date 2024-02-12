SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @employees_audit_json	VARCHAR(MAX) = N'{employees_audit_json}'
DECLARE @employees_json 		VARCHAR(MAX) = N'{employees_json}'
DECLARE @start					DATE = '{start}'
DECLARE @end					DATE = '{end}'

EXEC update_employees_sc_work_hours @start=@start, @end=@end, @employees_json=@employees_json, @employees_audit_json=@employees_audit_json

SELECT	scid										AS emp_scid,
		DATEFROMPARTS(YEAR(date), MONTH(date), 1)	AS year_month,
		SUM(work_hours)							    AS work_hours
INTO	#SCWorkHours
FROM	DXStatisticsV2.dbo.EmployeesSCWorkHours
WHERE	date BETWEEN @start AND @end
/*	Don't group by anything else here. Otherwise make sure to filter result further by the new group field. */
GROUP BY	scid,
			DATEFROMPARTS(YEAR(date), MONTH(date), 1)

CREATE CLUSTERED INDEX idx ON #SCWorkHours(emp_scid, year_month);
