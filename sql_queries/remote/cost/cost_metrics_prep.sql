SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*******************
	Params
********************/
DECLARE @new_life_start DATE = '2022-10-01'

DECLARE @period_start	DATE = '{start}'
DECLARE @period_end		DATE = '{end}'

DECLARE @working_hours_per_month TINYINT = 168


/*******************
	Months
********************/
DROP TABLE IF EXISTS #Months;
WITH months(year_month, next_month) AS (
	SELECT	DATEFROMPARTS(YEAR(@period_start), MONTH(@period_start), 1),
			DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@period_start), MONTH(@period_start), 1))
	UNION ALL
	SELECT	DATEADD(MONTH, 1, year_month),
			/*	next month cannot be greater than @period_end	*/
			IIF(DATEADD(MONTH, 1, next_month) > @period_end, @period_end, DATEADD(MONTH, 1, next_month))
	FROM months
	WHERE DATEADD(MONTH, 1, year_month) < @period_end
)

SELECT	*
INTO	#Months
FROM	months


/*******************
	Vacations
********************/
DECLARE @full_day		 TINYINT = 0
DECLARE @first_half		 TINYINT = 1
DECLARE @second_half	 TINYINT = 2
DECLARE @without_payment TINYINT = 1

DROP TABLE IF EXISTS #Vacations;
WITH vacations_start AS (
	SELECT	Employee_Id,
			DATEADD(HOUR, CASE WHEN DayHalf = @second_half THEN 12 ELSE 0 END, StartDate) AS vac_start,
			Days,
			DayHalf,
			StartDate,
			IIF(EmployeeVacationSpecification_Id = @without_payment, 0, 1) AS is_paid
	FROM	CRM.dbo.EmployeeVacations
),

vacations_end AS (
	SELECT	*,
			DATEADD(HOUR, 24 * Days, vac_start) AS vac_end
	FROM	vacations_start
	WHERE	DATEADD(HOUR, 24 * Days, vac_start) > @period_start
),

vacations_raw AS (
	SELECT	v.Employee_Id														AS crmid,
			months.year_month													AS year_month,
			IIF(vac_start < months.year_month, months.year_month, vac_start)	AS vac_start,
			IIF(vac_end > months.next_month, months.next_month, vac_end)		AS vac_end,
			DayHalf																AS day_half,
			is_paid																AS is_paid
	FROM #Months AS months
		OUTER APPLY (
			SELECT	*
			FROM	vacations_end AS v
			WHERE	vac_start >= months.year_month AND vac_start < months.next_month
				OR	(vac_start < months.year_month AND vac_end > months.year_month)
		) AS v
)

SELECT	crmid,
		year_month AS year_month,
		SUM(CASE is_paid WHEN 1 THEN IIF(day_half != 0, 0.5, DXStatisticsV2.dbo.get_working_days(vac_start, vac_end)) * 8 ELSE 0 END) AS paid_hours,
		SUM(CASE is_paid WHEN 0 THEN IIF(day_half != 0, 0.5, DXStatisticsV2.dbo.get_working_days(vac_start, vac_end)) * 8 ELSE 0 END) AS free_hours
INTO	#Vacations
FROM	vacations_raw
GROUP BY crmid, year_month

CREATE CLUSTERED INDEX idx ON #Vacations(crmid, year_month)


/*******************
	Employees
********************/

/*	net				= clear, without taxes and administrative/operating expenses
	gross			= with taxes
	gross_withAOE	= gross with administrative/operating expenses	*/

DECLARE @now			DATE = GETUTCDATE()

DECLARE @before_oct_2022	TINYINT = 0
DECLARE @after_oct_2022		TINYINT = 1
DECLARE @not_applicable		TINYINT = 2

DECLARE @php CHAR(3) = 'PHP'
DECLARE @eur CHAR(3) = 'EUR'
DECLARE @php_to_usd DECIMAL(5,3) = 0.018
DECLARE @eur_to_usd DECIMAL(5,3) = 1.0

DECLARE @philippines	UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'

DECLARE @null_date DATE = '1990-01-01'

DROP TABLE IF EXISTS #Employees
SELECT	months.year_month														AS year_month,
		DATEADD(MONTH, 1, months.year_month)									AS next_year_month,
		employees.crmid															AS crmid,
		employees.scid															AS scid,
		employees.name															AS name,
		ISNULL(emps_levels.level_name, 
			ISNULL(emp_position_audit.position_name, employees.position_name))	AS level_name,
		ISNULL(tax_coefficients.value, 1)										AS tax_coefficient,
		--	#Postulate: SC fot is calculated by using sc work hour price.
		-------------------------------------------------------------------------------------------------------
		ROUND(	(
					ISNULL(salaries.value, IIF(employees.crmid IS NOT NULL, 0, NULL))
					* CASE salaries.currency	WHEN @php THEN @php_to_usd
												WHEN @eur THEN @eur_to_usd
												ELSE 1.0 END
				 )
				/ @working_hours_per_month, 3)									AS hourly_pay_net,
		-------------------------------------------------------------------------------------------------------
		ROUND(	(
					ISNULL(salaries.value, IIF(employees.crmid IS NOT NULL, 0, NULL))
					* CASE salaries.currency	WHEN @php THEN @php_to_usd
												WHEN @eur THEN @eur_to_usd
												ELSE 1.0 END
					* ISNULL(tax_coefficients.value, 1)
				 )
				/ @working_hours_per_month, 3)									AS hourly_pay_gross,
		-------------------------------------------------------------------------------------------------------
		ROUND(	(
					ISNULL(salaries.value, IIF(employees.crmid IS NOT NULL, 0, NULL))
					* CASE salaries.currency	WHEN @php THEN @php_to_usd
												WHEN @eur THEN @eur_to_usd
												ELSE 1.0 END
					* ISNULL(tax_coefficients.value, 1)
					+ ISNULL(operating_expenses.value_usd, 0)
				 )
				/ @working_hours_per_month, 3)									AS hourly_pay_gross_withAOE,
		-------------------------------------------------------------------------------------------------------
		employees.retired														AS retired,
		ISNULL(emp_hired_audit.hired_at, employees.hired_at)					AS hired_at,
		employees.retired_at													AS retired_at,
		ISNULL(emp_tribe_audit.tribe_id, employees.tribe_id)					AS tribe_id,
		ISNULL(emp_tribe_audit.tribe_name, employees.tribe_name)				AS tribe_name,
		ISNULL(emp_position_audit.position_id, employees.position_id)			AS position_id,
		ISNULL(emp_position_audit.position_name, employees.position_name)		AS position_name,
		ISNULL(emp_chapter_audit.chapter_id, employees.chapter_id)				AS chapter_id,
		employees.has_support_processing_role									AS has_support_processing_role,
		emp_location_audit.location_id											AS audit_location_id,
		emp_location_audit.location_name										AS audit_location_name,
		employees.location_id													AS actual_location_id
INTO	#Employees
FROM	#Months AS months
		OUTER APPLY (
			-- #Postulate: Trainees aren't thrown away
			SELECT	e.*
			FROM	DXStatisticsV2.dbo.support_analytics_employees() AS e
		) AS employees
		OUTER APPLY (
			SELECT	 MIN(emp_audit.HiredAt) AS hired_at
			FROM	CRMAudit.dxcrm.Employees AS emp_audit 
			WHERE	emp_audit.EntityOid = employees.crmid
		)	AS emp_hired_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	emps_audit_outer.Tribe_Id														AS tribe_id,
							tribe.Name																		AS tribe_name,
							emps_audit_outer.period_start													AS period_start,
							LEAD(emps_audit_outer.period_end) OVER (ORDER BY emps_audit_outer.period_end)	AS period_end
					FROM (	SELECT	emps_audit_inner.EntityModified				AS period_end,
									IIF(LAG(emps_audit_inner.EntityModified) OVER (ORDER BY emps_audit_inner.EntityModified ASC) IS NULL, @null_date,
											emps_audit_inner.EntityModified)	AS period_start,
									emps_audit_inner.Tribe_Id
							FROM	CRMAudit.dxcrm.Employees AS emps_audit_inner
							WHERE	emps_audit_inner.EntityOid = employees.crmid
								AND emps_audit_inner.ChangedProperties LIKE '%Tribe%'
								AND emps_audit_inner.Tribe_Id IS NOT NULL
						)	AS emps_audit_outer
						CROSS APPLY (
							SELECT TOP 1 Name 
							FROM crm.dbo.Tribes 
							WHERE Id = emps_audit_outer.Tribe_Id
						) AS tribe
				) AS emps_audit
			WHERE	emps_audit.period_start <= months.year_month 
				AND (emps_audit.period_end IS NULL OR months.year_month < emps_audit.period_end)
		) AS emp_tribe_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	emps_audit_outer.position_id									AS position_id,
							(	SELECT TOP 1 ep.Name 
								FROM CRM.dbo.EmployeePositions AS ep 
								WHERE ep.Id = emps_audit_outer.position_id)					AS position_name,
							emps_audit_outer.period_start									AS period_start,
							LEAD(emps_audit_outer.period_end) OVER (ORDER BY period_end)	AS period_end
					FROM (	SELECT	emps_audit_inner.EntityModified				AS period_end,
									IIF(LAG(emps_audit_inner.EntityModified) OVER (ORDER BY emps_audit_inner.EntityModified ASC) IS NULL, @null_date, 
											emps_audit_inner.EntityModified)	AS period_start,
									emps_audit_inner.EmployeePosition_Id		AS position_id
							FROM	CRMAudit.dxcrm.Employees AS emps_audit_inner
							WHERE	emps_audit_inner.EntityOid = employees.crmid
								AND emps_audit_inner.ChangedProperties LIKE '%Position%'
								AND emps_audit_inner.EmployeePosition_Id IS NOT NULL
						)	AS emps_audit_outer
				) AS emps_audit
			WHERE	emps_audit.period_start <= months.year_month 
				AND (emps_audit.period_end IS NULL OR months.year_month < emps_audit.period_end)
		)	AS emp_position_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	emps_audit_outer.chapter_id										AS chapter_id,
							emps_audit_outer.period_start									AS period_start,
							LEAD(emps_audit_outer.period_end) OVER (ORDER BY period_end)	AS period_end
					FROM (	SELECT	emps_audit_inner.EntityModified				AS period_end,
									IIF(LAG(emps_audit_inner.EntityModified) OVER (ORDER BY emps_audit_inner.EntityModified ASC) IS NULL, @null_date, 
											emps_audit_inner.EntityModified)	AS period_start,
									emps_audit_inner.Chapter_Id					AS chapter_id
							FROM	CRMAudit.dxcrm.Employees AS emps_audit_inner
							WHERE	emps_audit_inner.EntityOid = employees.crmid
								AND emps_audit_inner.ChangedProperties LIKE '%Chapter%'
								AND emps_audit_inner.Chapter_Id IS NOT NULL
						)	AS emps_audit_outer
				) AS emps_audit
			WHERE	emps_audit.period_start <= months.year_month 
				AND (emps_audit.period_end IS NULL OR months.year_month < emps_audit.period_end)
		)	AS emp_chapter_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	IIF(locations.IsActive = 0, NULL, emps_audit_outer.location_id)	AS location_id,
							IIF(locations.IsActive = 0, NULL, locations.Name)				AS location_name,
							emps_audit_outer.period_start									AS period_start,
							LEAD(emps_audit_outer.period_end) OVER (ORDER BY period_end)	AS period_end
					FROM (	SELECT	emps_audit_inner.EntityModified				AS period_end,
									IIF(LAG(emps_audit_inner.EntityModified) OVER (ORDER BY emps_audit_inner.EntityModified ASC) IS NULL, @null_date, 
											emps_audit_inner.EntityModified)	AS period_start,
									emps_audit_inner.EmployeeLocation_id		AS location_id
							FROM	CRMAudit.dxcrm.Employees AS emps_audit_inner
							WHERE	emps_audit_inner.EntityOid = employees.crmid
								AND emps_audit_inner.ChangedProperties LIKE '%Location%'
						)	AS emps_audit_outer
						CROSS APPLY (
							SELECT	Name, IsActive
							FROM	CRM.dbo.EmployeeLocations AS l
							WHERE	l.Id = emps_audit_outer.location_id
						) AS locations
				) AS emps_audit
			WHERE	emps_audit.period_start <= months.year_month 
				AND (emps_audit.period_end IS NULL OR months.year_month < emps_audit.period_end)
		)	AS emp_location_audit
		OUTER APPLY (
			/*	If level_id is null, then we calculate it using EmployeesSalaries below.	
				Don't change just this part. Change also probable_level_num calculation below.	*/
			SELECT	TOP 1 emps_audit.EmployeeLevel_Id AS level_id
			FROM	CRMAudit.dxcrm.Employees AS emps_audit
			WHERE	emps_audit.EntityOid = employees.crmid
				AND emps_audit.EntityModified < months.year_month
				AND emps_audit.ChangedProperties LIKE '%Level%'
			ORDER BY emps_audit.EntityModified DESC
		) AS emp_level_audit
		CROSS APPLY (
			SELECT	es_inner.level_id, es_inner.value, es_inner.currency, es_inner.period
			FROM	DXStatisticsV2.dbo.EmployeesSalaries AS es_inner
			WHERE	es_inner.level_id = ISNULL(
						emp_level_audit.level_id,
						/*	IF emp_level_audit.level_id is missing, then we split period [hired_at, now] into level_num chunks (level_period_in_months).
							Then we divide period [months.year_month, now] by level_period_in_months to obtain probable_level_num.
							Then use this probable_level_num to obtain level_id that would be most probable emp level at that period. */
						(	SELECT	TOP 1 level_id
							FROM	DXStatisticsV2.dbo.EmployeesSalaries
							WHERE	probable_level_num IS NOT NULL 
									AND probable_level_num =	ISNULL((SELECT (SELECT TOP 1 level_num FROM DXStatisticsV2.dbo.EmployeesSalaries WHERE level_id = ISNULL(employees.level_id, emp_position_audit.position_id))
																		-  FLOOR(DATEDIFF(MONTH, months.year_month, @now) /
																				 CEILING((DATEDIFF(MONTH, ISNULL(ISNULL(emp_hired_audit.hired_at, employees.hired_at), months.year_month), @now) + 1) * 1.0 /
																						 (SELECT TOP 1 level_num FROM DXStatisticsV2.dbo.EmployeesSalaries WHERE level_id = ISNULL(employees.level_id, emp_position_audit.position_id))))), 1)
									AND	period = IIF(ISNULL(emp_location_audit.location_id, employees.location_id) = @philippines, @not_applicable, IIF(months.year_month < @new_life_start, @before_oct_2022, @after_oct_2022)))
						) AND (es_inner.location_id IS NULL OR es_inner.location_id = ISNULL(emp_location_audit.location_id, employees.location_id))
		) AS salaries
		OUTER APPLY (
			SELECT	TOP 1 eoe.value_usd
			FROM	DXStatisticsV2.dbo.EmployeesOperatingExpenses AS eoe
			WHERE	((emp_location_audit.location_id IS NULL AND eoe.location_id IS NULL) OR eoe.location_id = emp_location_audit.location_id)
				AND eoe.actual_since <= months.year_month
			ORDER BY eoe.actual_since DESC
		) AS operating_expenses
		OUTER APPLY (
			SELECT	TOP 1 etc.value
			FROM	DXStatisticsV2.dbo.EmployeesTaxCoefficients AS etc
			WHERE	((emp_location_audit.location_id IS NULL AND etc.location_id IS NULL) OR etc.location_id = emp_location_audit.location_id)
				AND etc.actual_since <= months.year_month
				AND etc.self_employed = IIF(EXISTS(SELECT TOP 1 ese.crmid FROM DXStatisticsV2.dbo.EmployeesSelfEmployed AS ese WHERE ese.crmid = employees.crmid), 1, 0)
			ORDER BY etc.actual_since DESC
		) AS tax_coefficients
		OUTER APPLY (
			SELECT	TOP 1 el.Name AS level_name
			FROM	CRM.dbo.EmployeeLevels AS el
			WHERE	el.Id = salaries.level_id
		) AS emps_levels
		/*	throw away never hired employees or employees after retirement	*/
WHERE	(emp_position_audit.position_id IS NOT NULL OR employees.position_id IS NOT NULL)
		AND months.year_month > ISNULL(ISNULL(emp_hired_audit.hired_at, employees.hired_at), @null_date)
		AND months.year_month < ISNULL(employees.retired_at, '9999-01-01')	
		AND	(	salaries.period = @not_applicable	-- ph guys
				/*	regular guys corresponding to correct salary period as left joining EmployeesSalaries duplicated them	*/
				OR (months.year_month <  @new_life_start AND salaries.period = @before_oct_2022)
				OR (months.year_month >= @new_life_start AND salaries.period = @after_oct_2022))

CREATE CLUSTERED INDEX idx ON #Employees(scid, year_month)
CREATE NONCLUSTERED INDEX idx_ ON #Employees(position_id, chapter_id, has_support_processing_role) 
INCLUDE(year_month, crmid, name, level_name, hourly_pay_net, hourly_pay_gross, hourly_pay_gross_withAOE, retired, retired_at, tribe_id, tribe_name)


/*******************
	WorkingHours
********************/
DECLARE @question		TINYINT = 1
DECLARE @bug			TINYINT = 2
DECLARE @suggestion		TINYINT = 3

DROP TABLE IF EXISTS #WorkingHours
SELECT	tc.emp_scid						AS emp_scid,
		year_month						AS year_month,
		COUNT(DISTINCT tc.time_stamp)	AS hours_worked
INTO #WorkingHours
FROM (
		SELECT	EntityOid						AS ticket_id,
				AuditOwner						AS emp_scid,	
				DATETIMEFROMPARTS(
					DATEPART(YEAR,	EntityModified),
					DATEPART(MONTH, EntityModified),
					DATEPART(DAY,	EntityModified),
					DATEPART(HOUR,	EntityModified),
					0, 0, 0 )					AS time_stamp,
				DATEFROMPARTS(
					YEAR(EntityModified),
					MONTH(EntityModified), 1)	AS year_month
		FROM	scpaid_audit.[c1f0951c-3885-44cf-accb-1a390f34c342].scworkflow_Tickets AS audit_tickets
		WHERE	EntityModified BETWEEN @period_start AND @period_end
		UNION
		SELECT	Ticket_Id,
				AuditOwner,	
				DATETIMEFROMPARTS(
					DATEPART(YEAR,	EntityModified),
					DATEPART(MONTH, EntityModified),
					DATEPART(DAY,	EntityModified),
					DATEPART(HOUR,	EntityModified),
					0, 0, 0 ),
				DATEFROMPARTS(
					YEAR(EntityModified),
					MONTH(EntityModified), 1)							
		FROM	scpaid_audit.[c1f0951c-3885-44cf-accb-1a390f34c342].scworkflow_TicketProperties AS audit_ticket_propertiess
		WHERE	EntityModified BETWEEN @period_start AND @period_end
	) AS tc
	CROSS APPLY (
		SELECT  Id
		FROM	SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Tickets AS t
				LEFT JOIN #Employees AS e ON e.scid = t.Owner
		WHERE	Id = tc.ticket_id
			AND e.scid IS NULL									-- #Postulate: We take into account only tickets created by users.
			AND EntityType IN (@question, @bug, @suggestion)	-- #Postulate: and tickets of type (question, suggestion, bug).
	) AS users_tickets_only
	WHERE 	tc.ticket_id IS NOT NULL
		/*	Throw away weekends work hours.	*/
		AND	DATEPART(DW, time_stamp) NOT IN (7 /*saturday*/ , 1/*sunday*/)
	/*	#Postulate: All replies and work hours in non primary tribe are moved (as is) as replies and work hours in the primary tribe.
		The move is per month.	*/
	/*	Don't group by anything else here. Otherwise make sure to filter result further by the new group field.*/
GROUP BY	tc.emp_scid,
			year_month

CREATE CLUSTERED INDEX idx ON #WorkingHours(emp_scid, year_month)


/*******************
	Posts
********************/
DECLARE @note			TINYINT = 3

DROP TABLE IF EXISTS #Posts
SELECT	posts.Ticket_Id							AS ticket_id,
		posts.Id								AS post_id,
		posts.Created							AS post_created,
		DATEFROMPARTS(
			YEAR(posts.Created),
			MONTH(posts.Created),1)				AS year_month,
		tribes.id								AS tribe_id,
		tribes.name								AS tribe_name,
		posts.Owner								AS user_scid,
		tickets.is_ticket_owner					AS is_ticket_owner,
		employees.crmid							AS emp_crmid,
		employees.position_id					AS emp_position_id,
		employees.name							AS emp_name,
		employees.position_name					AS emp_position_name,
		employees.chapter_id					AS emp_chapter_id,
		employees.has_support_processing_role	AS has_support_processing_role
INTO	#Posts
FROM (	SELECT	psts.Created, psts.Owner, psts.Ticket_Id, psts.Id
		FROM	SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Posts AS psts
		WHERE	psts.Created BETWEEN @period_start AND @period_end
			AND psts.Type  != @note
	) AS posts
	OUTER APPLY (
		SELECT TOP 1 u.Id
		FROM	crm.dbo.Employees  AS e
				INNER JOIN CRM.dbo.Customers AS c ON c.Id  = e.Id
				INNER JOIN SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Users AS u ON u.FriendlyId = c.FriendlyId
		WHERE	e.IsServiceUser = 1 AND u.Id = posts.Owner
	) AS serivce_users
	CROSS APPLY (
		SELECT	t.Id, CASE WHEN t.Owner = posts.Owner THEN 1 ELSE 0 END AS is_ticket_owner
		FROM	SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Tickets AS t
		WHERE	t.Id = posts.Ticket_Id
			AND t.EntityType IN (@question, @bug, @suggestion) -- #Postulate: Take into account only questions, suggestions, bugs.
	) AS tickets
	OUTER APPLY (
		SELECT	e.*
		FROM	#Employees AS e
		WHERE	e.scid = posts.Owner 
			AND posts.Created BETWEEN e.year_month AND e.next_year_month
	) AS employees
	OUTER APPLY (
		SELECT	id, name
		FROM	DXStatisticsV2.dbo.get_ticket_tribes(tickets.Id, DEFAULT, employees.tribe_id)
	) AS tribes
	/*	Post owner is not service user	*/
	WHERE serivce_users.Id IS NULL

CREATE CLUSTERED INDEX idx ON #Posts(tribe_id, ticket_id, post_created)
CREATE NONCLUSTERED INDEX idx_ ON #Posts(emp_crmid, year_month, tribe_id) INCLUDE(post_id)


/*******************
	Iterations
********************/
DROP TABLE IF EXISTS #Iterations;
WITH posts_with_prev_emp_crmid AS (
	SELECT	*, LAG(emp_crmid) OVER (PARTITION BY tribe_id, ticket_id ORDER BY post_created) AS prev_emp_crmid
	FROM	#Posts
),

posts_split_into_iterations AS (
	SELECT	*, SUM(IIF(prev_emp_crmid IS NOT NULL AND emp_crmid IS NULL, 1, 0)) OVER (PARTITION BY tribe_id, ticket_id ORDER BY post_created) AS iteration_no
	FROM posts_with_prev_emp_crmid
),

iterations_raw AS (
	SELECT	*,
			MIN(post_created) OVER (PARTITION BY tribe_id, ticket_id, iteration_no) AS iteration_start,
			MAX(post_created) OVER (PARTITION BY tribe_id, ticket_id, iteration_no) AS iteration_end,
			IIF(MIN(CASE WHEN emp_crmid IS NULL THEN 0 ELSE 1 END)		OVER (PARTITION BY tribe_id, ticket_id, iteration_no) = 0 AND 
				MAX(CASE WHEN emp_crmid IS NOT NULL THEN 1 ELSE 0 END)	OVER (PARTITION BY tribe_id, ticket_id, iteration_no) = 1,
				1, 0 ) AS is_iteration
	FROM posts_split_into_iterations
),

iterations AS (
	SELECT	ticket_id,
			post_id,
			post_created,
			is_ticket_owner,
			iteration_no,
			iteration_start,
			iteration_end,
			emp_crmid,
			emp_name,
			user_scid,
			tribe_name,
			tribe_id,
			DATEFROMPARTS(YEAR(post_created), MONTH(post_created), 1) AS year_month,
			emp_position_id,
			emp_chapter_id,
			has_support_processing_role
	FROM	iterations_raw
	WHERE	is_iteration = 1 
		AND	emp_crmid IS NOT NULL
		/*	Sequential answers are considered to be different iterations. ex T1161862, T1163662.
			This is because is_iteration is set to 1 from the very start to the very end of the iteration.
			We may want add additional conditions to recognize such cases and collapse them.*/
		--AND post_created = iteration_end
),

iterations_reduced AS (
	SELECT	i.emp_crmid						AS emp_crmid,
			i.user_scid						AS emp_scid,
			i.tribe_id						AS tribe_id,
			emp_main_tribes.tribe_id		AS emp_tribe_id,
			MIN(i.emp_name)					AS emp_name,
			emp_main_tribes.tribe_name		AS emp_tribe_name,
			i.tribe_name					AS tribe_name,
			i.year_month					AS year_month,
			emp_position_id					AS emp_position_id,
			emp_chapter_id					AS emp_chapter_id,
			has_support_processing_role		AS has_support_processing_role,
			-------------------------------------------------------
			COUNT(DISTINCT i.ticket_id)		AS unique_tickets,
			COUNT(i.post_id)				AS iterations
			-------------------------------------------------------
	FROM	iterations AS i
			OUTER APPLY (
				/*	Calc emp primary tribe on monthly basis.
					Emp main tribe is the tribe which emp has most posts in.	*/
				SELECT TOP 1 tribe_id,
							 tribe_name
				FROM	 #Posts AS psts
				WHERE	 psts.emp_crmid		= i.emp_crmid
					 AND psts.year_month	= i.year_month
				GROUP BY psts.emp_crmid, psts.year_month, psts.tribe_id, psts.tribe_name
				HAVING	 COUNT(psts.post_id) = (	SELECT MAX(psts_outer.posts)
													FROM (	SELECT	COUNT(psts_inner.post_id) AS posts
															FROM	#Posts AS psts_inner
															WHERE	psts_inner.emp_crmid	= psts.emp_crmid
																AND psts_inner.year_month	= psts.year_month
															GROUP BY emp_crmid, year_month, tribe_id) AS psts_outer)
			) AS emp_main_tribes
	/*	#Postulate: All replies and work hours in non primary tribe are moved (as is) as replies and work hours in the primary tribe.
		The move is per month.	*/
	GROUP BY	i.emp_crmid, 
				i.user_scid,
				i.year_month,
				emp_main_tribes.tribe_id, 
				emp_main_tribes.tribe_name, 
				i.tribe_id, 
				i.tribe_name,
				emp_position_id,
				emp_chapter_id,
				has_support_processing_role
)

SELECT	i.*,
		wh.hours_worked AS sc_hours
INTO	#Iterations
FROM	iterations_reduced AS i
		INNER JOIN #WorkingHours AS wh ON	wh.emp_scid		= i.emp_scid 
										AND wh.year_month	= i.year_month

CREATE CLUSTERED INDEX idx ON #Iterations(emp_position_id, emp_chapter_id, has_support_processing_role, emp_crmid, year_month, emp_tribe_id);