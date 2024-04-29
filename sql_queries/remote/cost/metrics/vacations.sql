DECLARE @full_day		 TINYINT = 0
DECLARE @first_half		 TINYINT = 1
DECLARE @second_half	 TINYINT = 2

DROP TABLE IF EXISTS #Vacations;
WITH vacations AS (
	SELECT	v.crmid																AS crmid,
			months.year_month													AS year_month,
			IIF(vac_start < months.year_month, months.year_month, vac_start)	AS vac_start,
			IIF(vac_end > months.next_month, months.next_month, vac_end)		AS vac_end,
			day_half															AS day_half,
			is_paid																AS is_paid
	FROM 	#Months AS months
			OUTER APPLY (
				SELECT	*
				FROM	#EmployeeVacations AS v
				WHERE	vac_start >= months.year_month AND vac_start < months.next_month
					OR	(vac_start < months.year_month AND vac_end > months.year_month)
			) AS v
)

SELECT	crmid,
		year_month AS year_month,
		SUM(CASE is_paid WHEN 1 THEN IIF(day_half != @full_day, 0.5, DXStatisticsV2.dbo.get_working_days(vac_start, vac_end)) * 8 ELSE 0 END) AS paid_hours,
		SUM(CASE is_paid WHEN 0 THEN IIF(day_half != @full_day, 0.5, DXStatisticsV2.dbo.get_working_days(vac_start, vac_end)) * 8 ELSE 0 END) AS free_hours
INTO	#Vacations
FROM	vacations
GROUP BY crmid, year_month
