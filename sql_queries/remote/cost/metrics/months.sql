DECLARE @start	DATE = '{start}'
DECLARE @end	DATE = '{end}'

DROP TABLE IF EXISTS #Months;
WITH months(year_month, next_month) AS (
	SELECT	DATEFROMPARTS(YEAR(@start), MONTH(@start), 1),
			DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@start), MONTH(@start), 1))
	UNION ALL
	SELECT	DATEADD(MONTH, 1, year_month),
			/*	next month cannot be greater than @end	*/
			IIF(DATEADD(MONTH, 1, next_month) > @end, @end, DATEADD(MONTH, 1, next_month))
	FROM 	months
	WHERE 	DATEADD(MONTH, 1, year_month) <= @end
)

SELECT	*
INTO	#Months
FROM	months
OPTION(MAXRECURSION 1000)
