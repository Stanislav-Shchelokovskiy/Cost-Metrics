SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @employees VARCHAR(MAX) = N'{employees_json}'
DECLARE @start	DATE = '{start}'
DECLARE @end	DATE = '{end}'

DROP TABLE IF EXISTS #SCWorkHours;

SELECT	emp_scid									AS emp_scid,
		DATEFROMPARTS(YEAR(date), MONTH(date), 1)	AS year_month,
		SUM(work_hours)							    AS work_hours
INTO	#SCWorkHours
FROM	DXStatisticsV2.dbo.sc_work_hours(@start, @end, @employees)
/*	Don't group by anything else here. Otherwise make sure to filter result further by the new group field. */
GROUP BY	emp_scid,
			DATEFROMPARTS(YEAR(date), MONTH(date), 1)

CREATE CLUSTERED INDEX idx ON #SCWorkHours(emp_scid, year_month)
