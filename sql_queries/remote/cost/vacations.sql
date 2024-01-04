DECLARE @json VARCHAR(MAX) = N'{vacations_json}'

DROP TABLE IF EXISTS #EmployeeVacations;

WITH vacations AS (
	SELECT	crmid,
			days,
			day_half,
			IIF(vacation_type = 1 /* without_payment */, 0, 1) 									AS is_paid,
			DATEADD(HOUR, CASE WHEN day_half = 2 /* second_half */ THEN 12 ELSE 0 END, start) 	AS vac_start
	FROM	OPENJSON(@json, '$') WITH (
				crmid        	UNIQUEIDENTIFIER    'strict $.employeeID',
				vacation_type  	TINYINT		    	'strict $.vacationType',
				vacation_status TINYINT			   	'strict $.vacationStatus',
				start   		DATETIME			'strict $.startDate',
				days			FLOAT				'strict $.days',
				day_half		TINYINT				'strict $.dayHalf'
			) AS v
	WHERE	vacation_status = 2 /* processed */
)

SELECT	*,
		DATEADD(HOUR, 24 * days, vac_start) AS vac_end
INTO 	#EmployeeVacations
FROM	vacations
