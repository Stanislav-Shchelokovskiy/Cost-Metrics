SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/*******************
	Params
********************/
DECLARE @new_life_start DATE = '2022-10-01'

DECLARE @period_start	DATE = '{start}'
DECLARE @period_end		DATE = '{end}'

DECLARE @support_developers_chapter UNIQUEIDENTIFIER = '29B6E93D-8644-4977-9010-983076353DC6'

DECLARE @support_developer_ph	UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @chapter_leader			UNIQUEIDENTIFIER = '945FDE96-987B-4608-85F4-7393F00D341B'
DECLARE @tribe_leader			UNIQUEIDENTIFIER = '0CF0BDBA-7DE3-4A06-9493-8F90720526B7'
DECLARE @pm						UNIQUEIDENTIFIER = '835B63C4-D357-497A-A184-3F4FEAAA2AA7'
DECLARE @principal_pm			UNIQUEIDENTIFIER = 'E8D90D9A-4C9D-45A6-A828-02CD6FA14924'
DECLARE @developer				UNIQUEIDENTIFIER = '5739E91C-83AE-46CB-A9A0-32517CB1BAAA'
DECLARE @technical_writer		UNIQUEIDENTIFIER = '4D017739-BA85-4C71-AEFD-1B7098BE81A2'
DECLARE @squad_leader			UNIQUEIDENTIFIER = '520C9118-F21C-4B49-B937-A5ED2806B10C'

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
		--	#Postulate: ФОТ на работу в sc считается по цене часа, затраченного на работу в sc.
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
			-- #Postulate: Трейни не выкидываются
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
			AND e.scid IS NULL									-- #Postulate: Время работы считаем по тикетам, в которых овнер является юзером.
			AND EntityType IN (@question, @bug, @suggestion)	-- #Postulate: Учитываем только тикеты типа (question, suggestion, bug).
	) AS users_tickets_only
	WHERE tc.ticket_id IS NOT NULL
	/*	#Postulate: Все ответы и часы работы не в своём трайбе как есть переносятся как ответы и часы в основном трайбе.
		Перенос происходит помесячно.
		Don't group by anything else here. Otherwise make sure to filter result further by the new group field.*/
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
				--AND ticket_id IN ('8DE6294D-1D04-49BD-A7E9-771102A49879', '2B4E7D94-15FE-4C2B-BD9A-E629C713DF2C', '480B8439-E981-4A81-854B-2250AE9B128F')
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
			AND t.EntityType IN (@question, @bug, @suggestion) -- #Postulate: Учитываем только тикеты типа (question, suggestion, bug).
			AND	t.Created BETWEEN @period_start AND @period_end
	) AS tickets
	OUTER APPLY (
		SELECT	id, name
		FROM	DXStatisticsV2.dbo.get_ticket_tribes(tickets.Id, DEFAULT, DEFAULT)
	) AS tribes
	OUTER APPLY (
		SELECT	e.*
		FROM	#Employees AS e
		WHERE	e.scid = posts.Owner 
			AND posts.Created BETWEEN e.year_month AND e.next_year_month
	) AS employees
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
	/*	#Postulate: Все ответы и часы работы не в своём трайбе как есть переносятся как ответы и часы в основном трайбе.
		Перенос происходит помесячно.	*/
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


/****************************
	Dev performance factor
****************************/
DECLARE @create_draft	TINYINT = 0
DECLARE @post_draft		TINYINT = 2
DECLARE @min_duration	TINYINT = 3
DECLARE @description	TINYINT = 0

DROP TABLE IF EXISTS #DevPerformanceFactors;
WITH tickets AS (
	SELECT	FriendlyId AS firendly_id, Id AS ticket_id
	FROM	SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Tickets
	WHERE	EntityType = @question
),

emp_drafts_raw AS (
	SELECT	employees.scid AS emp_scid,
			employees.name AS emp_name,
			employees.tribe_id AS emp_tribe_id,
			employees.position_id,
			employees.chapter_id,
			employees.has_support_processing_role,
			psts.Ticket_id AS ticket_id,
			FIRST_VALUE(LastUpdated) OVER (PARTITION BY AuditOwner, psts.Ticket_id, ParentPost_Id, CAST(LastUpdated AS DATE) ORDER BY AuditAction ASC,  LastUpdated ASC)  AS draft_start,
			FIRST_VALUE(LastUpdated) OVER (PARTITION BY AuditOwner, psts.Ticket_id, ParentPost_Id, CAST(LastUpdated AS DATE) ORDER BY AuditAction DESC, LastUpdated DESC) AS draft_end
	FROM	( SELECT DISTINCT scid, name, tribe_id, position_id, chapter_id, has_support_processing_role FROM  #Employees )AS employees
			CROSS APPLY (
				SELECT	psts_inner.*
				FROM	scpaid_audit.[c1f0951c-3885-44cf-accb-1a390f34c342].scworkflow_DraftPosts AS psts_inner
						INNER JOIN tickets ON tickets.ticket_id = psts_inner.Ticket_id
				WHERE	psts_inner.LastUpdated BETWEEN @period_start AND @period_end
					AND psts_inner.PostType NOT IN (@note, @description)
					AND (psts_inner.AuditAction = @create_draft OR (psts_inner.AuditAction = @post_draft AND Post_Id IS NOT NULL))
					AND psts_inner.AuditOwner = employees.scid
			) AS psts
),

emp_drafts AS (
	SELECT	emp_scid,
			emp_name,
			position_id,
			chapter_id,
			has_support_processing_role,
			tribes.tribe_id,
			tribes.tribe_name,
			DATEDIFF(MINUTE, draft_start, draft_end) AS duration
	FROM emp_drafts_raw
		CROSS APPLY (
				SELECT	id AS tribe_id, name AS tribe_name
				FROM	DXStatisticsV2.dbo.get_ticket_tribes(ticket_id, DEFAULT, DEFAULT)
				WHERE	id = emp_tribe_id
		) AS tribes
	WHERE	DATEDIFF(MINUTE, draft_start, draft_end) > @min_duration
),

support_drafts AS (
	SELECT DISTINCT tribe_id, tribe_name, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY emp_median_duration ASC) OVER(PARTITION BY /*year_month,*/ tribe_id, tribe_name) AS median_duration
	FROM (	SELECT	DISTINCT tribe_id, tribe_name, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration ASC) OVER(PARTITION BY /*year_month,*/ tribe_id, tribe_name, emp_scid) AS emp_median_duration
			FROM	emp_drafts
			/*	#Postulate: Учитываются только сапортёры трайба, включая чаптер мэнеджеров и лидов поддержки.	*/
			WHERE	position_id IN (@support_developer_ph, @support_developer)
				OR (position_id = @chapter_leader	AND chapter_id = @support_developers_chapter)
				OR (position_id = @tribe_leader		AND has_support_processing_role = 1)
		) AS emp_medians
),

dev_drafts AS (
	SELECT DISTINCT tribe_id, tribe_name, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY emp_median_duration ASC) OVER(PARTITION BY /*year_month,*/ tribe_id, tribe_name) AS median_duration
	FROM (	SELECT	DISTINCT tribe_id, tribe_name, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration ASC) OVER(PARTITION BY /*year_month,*/ tribe_id, tribe_name, emp_scid) AS emp_median_duration
			FROM	emp_drafts
			WHERE	position_id IN (@developer, @pm, @principal_pm, @technical_writer)
				OR	(position_id IN (@chapter_leader, @tribe_leader, @squad_leader) AND has_support_processing_role = 0)
		) AS emp_medians
)

SELECT	d.tribe_id												AS tribe_id,
		d.tribe_name											AS tribe_name,
		d.median_duration										AS d_median_duration,
		s.median_duration										AS s_median_duration,
		/*	How many times devs slower than support.	*/
		IIF(ISNULL(d.median_duration * 1.0 / s.median_duration, 1) <= 1, 1,
			ISNULL(d.median_duration * 1.0 / s.median_duration, 1)) 	AS dev_factor
INTO	#DevPerformanceFactors
FROM	dev_drafts AS d
		LEFT JOIN support_drafts AS s ON s.tribe_id = d.tribe_id


/*******************
	Totals
********************/
DECLARE @devexpress_tribe_id	UNIQUEIDENTIFIER = '340E06F5-9B98-4923-97A4-CA02BA73F075'
DECLARE @current_month			DATE = DATEFROMPARTS(YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 1);

WITH emp_activity_in_tribe AS (
	SELECT	emp_crmid			AS emp_crmid,
			emp_scid			AS emp_scid,
			year_month			AS year_month,
			emp_tribe_id		AS emp_tribe_id,
			emp_tribe_name		AS emp_tribe_name,
			sc_hours			AS sc_hours,
			--------------------------------------
			SUM(unique_tickets)	AS unique_tickets,
			SUM(iterations)		AS iterations
			--------------------------------------
	FROM	#Iterations
	GROUP BY emp_crmid, emp_scid, year_month, emp_tribe_id, emp_tribe_name, sc_hours
),

emp_activity_in_tribe_with_external_activity AS (
	SELECT	emp_crmid,
			year_month,
			emp_tribe_id,
			emp_tribe_name,
			sc_hours,
			emp_activity_in_tribe.unique_tickets + ISNULL(external_activity.unique_tickets, 0)	AS unique_tickets,
			emp_activity_in_tribe.iterations	 + ISNULL(external_activity.iterations, 0)		AS iterations
	FROM	emp_activity_in_tribe
			OUTER APPLY (
				SELECT	COUNT(DISTINCT ExternalTicketId)	AS unique_tickets,
						COUNT(Id)							AS iterations
				FROM	DXStatisticsV2.dbo.ExternalAssignActions
				WHERE	Action = 'Reply'
					AND	Date BETWEEN year_month AND DATEADD(MONTH, 1, year_month)
					AND AssigneeId = emp_scid
			) AS external_activity
),

emp_activity_in_tribe_prefilter AS (
	SELECT	*,
			IIF(	(emp_crmid = 'A0917AB0-A985-11E5-827B-F46D0490CBCF' /*Khludov*/ AND year_month BETWEEN '2022-06-01' AND '2023-04-01')
				OR	(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= '2022-01-01')
				OR	emp_crmid IN (	'5039812F-60FF-475B-BCDB-067E98C86D2D' /*Shcheglov*/,
									'0D82BCB7-4F10-4439-B279-73FFD452ECE6' /*Gushchin*/), 1, 0) AS ignore_sc_activity
	FROM	emp_activity_in_tribe_with_external_activity
	
),

emp_activity_in_tribe_transformed AS (
	SELECT	emp_crmid,
			year_month,
			emp_tribe_id,
			emp_tribe_name,
			IIF(ignore_sc_activity = 1, 0, sc_hours)		AS sc_hours,
			IIF(ignore_sc_activity = 1, 0, unique_tickets)	AS unique_tickets,
			IIF(ignore_sc_activity = 1, 0, iterations)		AS iterations
	FROM	emp_activity_in_tribe_prefilter
),

emp_activity_reduced AS (
	SELECT	employees.year_month									AS year_month,
			employees.crmid											AS emp_crmid,
			employees.name											AS emp_name,
			employees.position_id									AS position_id,
			employees.chapter_id									AS chapter_id,
			employees.has_support_processing_role					AS has_support_processing_role,
			employees.position_name									AS position_name,
			employees.level_name									AS emp_level_name,
			employees.hourly_pay_net								AS hourly_pay_net,
			employees.hourly_pay_gross								AS hourly_pay_gross,
			employees.hourly_pay_gross_withAOE						AS hourly_pay_gross_withAOE,
			-----------------------------------------------------------------------------------
			/*	#Postulate: Все ответы и часы работы не в своём трайбе как есть переносятся как ответы и часы в основном трайбе. */
			ISNULL(employees.tribe_id, emps_empirical_tribe.id)		AS emp_tribe_id,
			ISNULL(employees.tribe_name, emps_empirical_tribe.name)	AS emp_tribe_name,
			-----------------------------------------------------------------------------------
			ISNULL(emps_activity_aggs.sc_hours, 0)					AS sc_hours,
			ISNULL(emps_activity_aggs.unique_tickets, 0)			AS unique_tickets,
			ISNULL(emps_activity_aggs.iterations, 0)				AS iterations,
			ISNULL(v.paid_hours, 0)									AS paid_vacation_hours,
			ISNULL(v.free_hours, 0)									AS free_vacation_hours,
			-----------------------------------------------------------------------------------
			CASE WHEN retired = 1 AND DATEDIFF(MONTH, employees.year_month, retired_at) = 0
					/*	#Postulate: Number of paid hours in the retirement month cannot be greater than number of working days before the retirement day x 8	*/
					THEN DXStatisticsV2.dbo.get_working_days(employees.year_month, employees.retired_at) * 8
				 WHEN retirement_period.retirement_start IS NOT NULL
					/*	#Postulate: If emp was retired for a wile and year_month falls in that period then we return 0 as paid_hours in that period.
									If emp was retired that month, then we return paid hours between year_month and retirement_start.
									If emp was hired that month, then we return paid hours between retirement_end and next month.	*/
					THEN IIF(employees.year_month = DATEFROMPARTS(YEAR(retirement_period.retirement_start), MONTH(retirement_period.retirement_start), 1),
								DXStatisticsV2.dbo.get_working_days(employees.year_month, retirement_period.retirement_start) * 8,
								IIF(employees.year_month = DATEFROMPARTS(YEAR(retirement_period.retirement_end), MONTH(retirement_period.retirement_end), 1),
									DXStatisticsV2.dbo.get_working_days(retirement_period.retirement_end, DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(employees.year_month), MONTH(employees.year_month), 1))) * 8, 0))
				 WHEN employees.year_month = @current_month
					/* Number of paid hours this (last) month cannot be greater than number of working days this month x 8	*/
					THEN DXStatisticsV2.dbo.get_working_days(@current_month, GETUTCDATE()) * 8
				 ELSE @working_hours_per_month
			END - ISNULL(v.free_hours, 0)							AS paid_hours 
			-----------------------------------------------------------------------------------
	FROM	#Employees AS employees
			OUTER APPLY (
				/*	Find tribe which emp worked most in.	*/
				SELECT  TOP 1	emps_transformed.emp_tribe_id	AS id,
								emps_transformed.emp_tribe_name AS name
				FROM	emp_activity_in_tribe_transformed AS emps_transformed
				WHERE	emps_transformed.emp_crmid = employees.crmid
				ORDER BY sc_hours DESC
			) AS emps_empirical_tribe
			OUTER APPLY (
				SELECT	emps_transformed.sc_hours,
						emps_transformed.unique_tickets,
						emps_transformed.iterations
				FROM	emp_activity_in_tribe_transformed AS emps_transformed
				WHERE	emps_transformed.emp_crmid	= employees.crmid
					AND emps_transformed.year_month	= employees.year_month
			) AS emps_activity_aggs
			LEFT JOIN #Vacations AS v ON	v.crmid			= employees.crmid
										AND	v.year_month	= employees.year_month
			OUTER APPLY (
				SELECT	audit_retired.RetiredAt AS retirement_start, 
						audit_hired.HiredAt		AS retirement_end
				FROM (	
						SELECT	 TOP 1 emp_audit.RetiredAt
						FROM    CRMAudit.dxcrm.Employees AS emp_audit
						WHERE	emp_audit.EntityOid = employees.crmid
							AND	emp_audit.EntityModified < DATEADD(MONTH, 1, employees.year_month)
							AND	emp_audit.RetiredAt IS NOT NULL
						ORDER BY emp_audit.EntityModified DESC	
					) AS audit_retired
					CROSS APPLY (
						SELECT TOP 1 emp_audit.HiredAt
						FROM CRMAudit.dxcrm.Employees AS emp_audit
						WHERE	emp_audit.EntityOid = employees.crmid
							AND emp_audit.EntityModified > audit_retired.RetiredAt
							AND emp_audit.HiredAt > audit_retired.RetiredAt
						ORDER BY emp_audit.EntityModified ASC
					) AS audit_hired
				WHERE	audit_retired.RetiredAt <  DATEADD(MONTH, 1, employees.year_month)
					AND audit_hired.HiredAt IS NOT NULL
					AND employees.year_month < audit_hired.HiredAt
			) AS retirement_period
),

emp_activity_sc_total_hours AS (
	SELECT	*,
			sc_hours + paid_vacation_hours * (IIF(sc_hours > paid_hours, paid_hours,  sc_hours) * 1.0 / paid_hours) AS sc_paidvacs_hours_incl_overtime
	FROM	emp_activity_reduced
	WHERE	paid_hours > 0
),

emp_activity_sc_total_hours_normalized AS (
	SELECT	*,
			IIF(sc_paidvacs_hours_incl_overtime > paid_hours, paid_hours, sc_paidvacs_hours_incl_overtime) AS sc_paidvacs_hours
	FROM	emp_activity_sc_total_hours
),

emp_activity AS (
	SELECT	year_month,
			emp_crmid,
			--------------------------------------------------------------------------------------------------
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= '2022-01-01', 
				@devexpress_tribe_id,
				emp_tribe_id)	AS emp_tribe_id,
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= '2022-01-01', 
			(SELECT TOP 1 Name FROM CRM.dbo.Tribes WHERE Id = @devexpress_tribe_id),
			emp_tribe_name)		AS emp_tribe_name,
			--------------------------------------------------------------------------------------------------
			emp_name,
			position_name,
			emp_level_name,
			hourly_pay_net,
			hourly_pay_gross,
			hourly_pay_gross_withAOE,
			paid_vacation_hours,
			free_vacation_hours,
			paid_hours,
			sc_hours,
			sc_paidvacs_hours,
			sc_paidvacs_hours_incl_overtime,
			unique_tickets,
			iterations,
			------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(sc_paidvacs_hours > paid_hours, paid_hours, sc_paidvacs_hours) * hourly_pay_gross 
			+ ISNULL(work_on_holidays.hours, 0) * hourly_pay_gross 											AS emp_sc_work_cost_gross,
			------------------------------------------------------------------------------------------------------------------------------------------------
			sc_paidvacs_hours_incl_overtime * hourly_pay_gross
			+ ISNULL(work_on_holidays.hours, 0) * hourly_pay_gross											AS emp_sc_work_cost_gross_incl_overtime,
			------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(sc_paidvacs_hours > paid_hours, paid_hours, sc_paidvacs_hours) * hourly_pay_gross_withAOE
			+ ISNULL(work_on_holidays.hours, 0) * hourly_pay_gross											AS emp_sc_work_cost_gross_withAOE,
			------------------------------------------------------------------------------------------------------------------------------------------------
			sc_paidvacs_hours_incl_overtime * hourly_pay_gross_withAOE
			+ ISNULL(work_on_holidays.hours, 0) * hourly_pay_gross											AS emp_sc_work_cost_gross_withAOE_incl_overtime,
			------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(sc_paidvacs_hours > paid_hours, 0,	paid_hours - sc_paidvacs_hours)							AS proactive_paidvacs_hours,
			------------------------------------------------------------------------------------------------------------------------------------------------
			position_id,
			chapter_id,
			has_support_processing_role
	FROM	emp_activity_sc_total_hours_normalized
			OUTER APPLY (
				SELECT	SUM(hours) AS hours
				FROM	DXStatisticsV2.dbo.EmployeesWorkOnHolidays AS woh
				WHERE	woh.crmid = emp_crmid
					AND	woh.date >= year_month AND woh.date < DATEADD(MONTH, 1, year_month)
			) AS work_on_holidays
	WHERE	emp_tribe_name IS NOT NULL
		AND emp_crmid NOT IN (	'04BFC59C-BD92-11E4-8260-F46D0490CBCF'/*Belym*/, 
								'A6FB4631-6A1F-47E0-A545-DC354069D540'/*Prohorov*/)
),

support_totals AS (
	SELECT	year_month										AS year_month,
			emp_tribe_name									AS emp_tribe_name,
			emp_name										AS emp_name,
			position_name									AS position_name,
			emp_level_name									AS emp_level_name,
			hourly_pay_net									AS hourly_pay_net,
			hourly_pay_gross								AS hourly_pay_gross,
			hourly_pay_gross_withAOE						AS hourly_pay_gross_withAOE,
			paid_vacation_hours								AS paid_vacation_hours,
			free_vacation_hours								AS free_vacation_hours,
			paid_hours										AS paid_hours,
			sc_hours										AS sc_hours,
			sc_paidvacs_hours								AS sc_paidvacs_hours,
			sc_paidvacs_hours_incl_overtime					AS sc_paidvacs_hours_incl_overtime,
			IIF(sc_hours < sc_paidvacs_hours, 0,
				sc_hours - sc_paidvacs_hours)				AS overtime_sc_hours,
			proactive_paidvacs_hours						AS proactive_paidvacs_hours,
			unique_tickets									AS unique_tickets,
			iterations										AS iterations,
			emp_sc_work_cost_gross_incl_overtime			AS emp_sc_work_cost_gross_incl_overtime,
			emp_sc_work_cost_gross_withAOE_incl_overtime	AS emp_sc_work_cost_gross_withAOE_incl_overtime,
			--***********************************************************************************************************************************************************
			sc_paidvacs_hours_incl_overtime + proactive_paidvacs_hours														AS emp_total_work_hours,
			SUM(sc_paidvacs_hours_incl_overtime + proactive_paidvacs_hours) OVER (PARTITION BY emp_tribe_id, year_month)	AS tribe_total_work_hours,
			SUM(sc_paidvacs_hours_incl_overtime + proactive_paidvacs_hours) OVER (PARTITION BY year_month)					AS chapter_total_work_hours,
			--***********************************************************************************************************************************************************
			emp_sc_work_cost_gross																							AS emp_sc_work_cost_gross,
			SUM(emp_sc_work_cost_gross) OVER (PARTITION BY emp_tribe_id, year_month)										AS tribe_sc_work_cost_gross,
			SUM(emp_sc_work_cost_gross) OVER (PARTITION BY year_month)														AS chapter_sc_work_cost_gross,
			--***********************************************************************************************************************************************************
			emp_sc_work_cost_gross_withAOE																					AS emp_sc_work_cost_gross_withAOE,
			SUM(emp_sc_work_cost_gross_withAOE) OVER (PARTITION BY emp_tribe_id, year_month)								AS tribe_sc_work_cost_gross_with_AOE,
			SUM(emp_sc_work_cost_gross_withAOE) OVER (PARTITION BY year_month)												AS chapter_sc_work_cost_gross_withAOE,
			--***********************************************************************************************************************************************************
			hourly_pay_gross * proactive_paidvacs_hours																		AS emp_proactive_work_cost_gross,
			SUM(hourly_pay_gross * proactive_paidvacs_hours) OVER (PARTITION BY emp_tribe_id, year_month)					AS tribe_proactive_work_cost_gross,
			SUM(hourly_pay_gross * proactive_paidvacs_hours) OVER (PARTITION BY year_month)									AS chapter_proactive_work_cost_gross,
			--***********************************************************************************************************************************************************
			hourly_pay_gross_withAOE * proactive_paidvacs_hours																AS emp_proactive_work_cost_gross_withAOE,
			SUM(hourly_pay_gross_withAOE * proactive_paidvacs_hours) OVER (PARTITION BY emp_tribe_id, year_month)			AS tribe_proactive_work_cost_gross_withAOE,
			SUM(hourly_pay_gross_withAOE * proactive_paidvacs_hours) OVER (PARTITION BY year_month)							AS chapter_proactive_work_cost_gross_withAOE,
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(unique_tickets = 0, 0,
			emp_sc_work_cost_gross_incl_overtime / unique_tickets)															AS emp_ticket_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)						OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_incl_overtime)	OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(unique_tickets)						OVER (PARTITION BY emp_tribe_id, year_month))						AS tribe_ticket_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)						OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_incl_overtime)	OVER (PARTITION BY year_month) * 1.0 
			/ SUM(unique_tickets)						OVER (PARTITION BY year_month))										AS chapter_ticket_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(unique_tickets = 0, 0,
			emp_sc_work_cost_gross_withAOE_incl_overtime / unique_tickets)													AS emp_ticket_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)								OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE_incl_overtime)	OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(unique_tickets)								OVER (PARTITION BY emp_tribe_id, year_month))				AS tribe_ticket_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)								OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE_incl_overtime)	OVER (PARTITION BY year_month) * 1.0 
			/ SUM(unique_tickets)								OVER (PARTITION BY year_month))								AS chapter_ticket_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(iterations = 0, 0,
			emp_sc_work_cost_gross_incl_overtime / iterations)																AS emp_iteration_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)							OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_incl_overtime)	OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(iterations)							OVER (PARTITION BY emp_tribe_id, year_month))						AS tribe_iteration_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)							OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_incl_overtime)	OVER (PARTITION BY year_month) * 1.0 
			/ SUM(iterations)							OVER (PARTITION BY year_month))										AS chapter_iteration_cost_gross,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(iterations = 0, 0,
			emp_sc_work_cost_gross_withAOE_incl_overtime / iterations)														AS emp_iteration_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)									OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE_incl_overtime)	OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(iterations)									OVER (PARTITION BY emp_tribe_id, year_month))				AS tribe_iteration_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)									OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE_incl_overtime)	OVER (PARTITION BY year_month) * 1.0 
			/ SUM(iterations)									OVER (PARTITION BY year_month))								AS chapter_iteration_cost_gross_withAOE,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(sc_hours = 0, 0,
			iterations * 1.0 / sc_hours) 																					AS emp_iterations_per_hour,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			/*	#Postulate: Средняя итерация по трайбу = сумма всех итераций в трайбе / сумму всех отработанных часов в трайбе.	*/
			IIF(SUM(sc_hours)	OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(iterations)		OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(sc_hours)		OVER (PARTITION BY emp_tribe_id, year_month))												AS tribe_iterations_per_hour,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(sc_hours)	OVER (PARTITION BY year_month) = 0, 0,
			SUM(iterations)		OVER (PARTITION BY year_month) * 1.0 
			/ SUM(sc_hours)		OVER (PARTITION BY year_month))																AS chapter_iterations_per_hour,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(unique_tickets = 0, 0,
			sc_hours * 1.0 / unique_tickets)																				AS emp_hours_per_ticket,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(sc_hours = 0, 0,
			unique_tickets * 1.0 / sc_hours) 																				AS emp_tickets_per_hour,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(sc_hours)	OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(unique_tickets)	OVER (PARTITION BY emp_tribe_id, year_month) * 1.0 
			/ SUM(sc_hours)		OVER (PARTITION BY emp_tribe_id, year_month))												AS tribe_tickets_per_hour,
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(sc_hours)	OVER (PARTITION BY year_month) = 0, 0,
			SUM(unique_tickets)	OVER (PARTITION BY year_month) * 1.0 
			/ SUM(sc_hours)		OVER (PARTITION BY year_month))																AS chapter_tickets_per_hour
			-------------------------------------------------------------------------------------------------------------------------------------------------------------
			--***********************************************************************************************************************************************************
	FROM	emp_activity
	WHERE	/*	#Postulate: Учитываются только сапортёры трайба, включая чаптер мэнеджеров и лидов поддержки.	*/
			 position_id IN (@support_developer_ph, @support_developer)
		OR	(position_id = @chapter_leader	AND chapter_id = @support_developers_chapter)
		OR	(position_id = @tribe_leader	AND has_support_processing_role = 1)
),

support_totals_ex AS (
	SELECT	*,
			tribe_sc_work_cost_gross			+ tribe_proactive_work_cost_gross												AS tribe_fot_gross,
			tribe_sc_work_cost_gross_with_AOE	+ tribe_proactive_work_cost_gross_withAOE										AS tribe_fot_gross_withAOE,
			chapter_sc_work_cost_gross			+ chapter_proactive_work_cost_gross												AS chapter_fot_gross,
			chapter_sc_work_cost_gross_withAOE	+ chapter_proactive_work_cost_gross_withAOE										AS chapter_fot_gross_withAOE,
			(tribe_sc_work_cost_gross			+ tribe_proactive_work_cost_gross)				* 1.0 / tribe_total_work_hours	AS tribe_hour_price_gross,
			(tribe_sc_work_cost_gross_with_AOE	+ tribe_proactive_work_cost_gross_withAOE)		* 1.0 / tribe_total_work_hours	AS tribe_hour_price_gross_withAOE,
			(chapter_sc_work_cost_gross			+ chapter_proactive_work_cost_gross)			* 1.0 / tribe_total_work_hours	AS chapter_hour_price_gross,
			(chapter_sc_work_cost_gross_withAOE	+ chapter_proactive_work_cost_gross_withAOE)	* 1.0 / tribe_total_work_hours	AS chapter_hour_price_gross_withAOE		
	FROM	support_totals
),

dev_tickets_per_hour AS (
	SELECT	tribe_id,
			s_totals.tribe_iterations_per_hour		/ dev_factor	AS tribe_iterations_per_hour,
			s_totals.chapter_iterations_per_hour	/ dev_factor	AS chapter_iterations_per_hour,
			s_totals.tribe_tickets_per_hour			/ dev_factor	AS tribe_tickets_per_hour,
			s_totals.chapter_tickets_per_hour		/ dev_factor	AS chapter_tickets_per_hour
	FROM	#DevPerformanceFactors AS dpf
			CROSS APPLY (
				SELECT	TOP 1 tribe_tickets_per_hour, chapter_tickets_per_hour, tribe_iterations_per_hour, chapter_iterations_per_hour
				FROM	support_totals
				WHERE	tribe_name = dpf.tribe_name
			) AS s_totals
),

dev_support_activity AS (
	SELECT	emp_activity.year_month									AS year_month,
			emp_activity.emp_tribe_name								AS emp_tribe_name,
			emp_activity.emp_name									AS emp_name,
			emp_activity.position_name								AS position_name,
			emp_activity.emp_level_name								AS emp_level_name,
			emp_activity.hourly_pay_net								AS hourly_pay_net,
			emp_activity.hourly_pay_gross							AS hourly_pay_gross,
			emp_activity.hourly_pay_gross_withAOE					AS hourly_pay_gross_withAOE,
			emp_activity.paid_vacation_hours						AS paid_vacation_hours,
			emp_activity.free_vacation_hours						AS free_vacation_hours,
			emp_activity.paid_hours									AS paid_hours,
			iterations												AS iterations,
			unique_tickets											AS unique_tickets,
			emp_tribe_id											AS emp_tribe_id,
			NULLIF(dtph.tribe_iterations_per_hour, 0)				AS tribe_iterations_per_hour,
			NULLIF(dtph.chapter_iterations_per_hour, 0)				AS chapter_iterations_per_hour,
			NULLIF(dtph.tribe_tickets_per_hour, 0)					AS tribe_tickets_per_hour,
			NULLIF(dtph.chapter_tickets_per_hour, 0)				AS chapter_tickets_per_hour,
			iterations / NULLIF(dtph.tribe_iterations_per_hour, 0)	AS probable_sc_hours
	FROM	emp_activity
			INNER JOIN dev_tickets_per_hour AS dtph ON dtph.tribe_id = emp_activity.emp_tribe_id
	WHERE	(position_id IN (@developer, @pm, @principal_pm, @technical_writer)
		OR (position_id IN (@chapter_leader, @tribe_leader, @squad_leader) AND has_support_processing_role = 0))
		AND iterations > 0
),

dev_sc_activity_hours AS (
	SELECT	*,
			ROUND(IIF(probable_sc_hours > paid_hours, paid_hours,  probable_sc_hours), 1) AS sc_hours,
			probable_sc_hours + paid_vacation_hours * (IIF(probable_sc_hours > paid_hours, paid_hours,  probable_sc_hours) * 1.0 / paid_hours) AS probable_sc_paidvacs_hours	
	FROM	dev_support_activity
),

dev_sc_activity_total_hours AS (
	SELECT	*,
			ROUND(IIF(probable_sc_paidvacs_hours > paid_hours, paid_hours,  probable_sc_paidvacs_hours), 1) AS sc_paidvacs_hours	
	FROM	dev_sc_activity_hours
),

dev_sc_activity_total_hours_normalized AS (
	SELECT	*,
			sc_paidvacs_hours * hourly_pay_gross			AS emp_sc_work_cost_gross,
			sc_paidvacs_hours * hourly_pay_gross_withAOE	AS emp_sc_work_cost_gross_withAOE					
	FROM	dev_sc_activity_total_hours
),

dev_support_cost AS (
	SELECT	*,
			emp_sc_work_cost_gross / NULLIF(iterations, 0)				AS emp_iteration_cost_gross,
			emp_sc_work_cost_gross / NULLIF(unique_tickets, 0)			AS emp_ticket_cost_gross,
			emp_sc_work_cost_gross_withAOE / NULLIF(iterations, 0)		AS emp_iteration_cost_gross_withAOE,
			emp_sc_work_cost_gross_withAOE / NULLIF(unique_tickets, 0)	AS emp_ticket_cost_gross_withAOE	
	FROM	dev_sc_activity_total_hours_normalized
),

dev_tribe_totals AS (
	SELECT	*,
			--------------------------------------------------------------------------------------------------------------------------
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY emp_tribe_id, year_month)			AS tribe_sc_work_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY year_month)							AS chapter_sc_work_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)			OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY emp_tribe_id, year_month)
			/ SUM(iterations)			OVER (PARTITION BY emp_tribe_id, year_month))			AS tribe_iteration_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)			OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY year_month)
			/ SUM(iterations)			OVER (PARTITION BY year_month))							AS chapter_iteration_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)		OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY emp_tribe_id, year_month)
			/ SUM(unique_tickets)		OVER (PARTITION BY emp_tribe_id, year_month))			AS tribe_ticket_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)		OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross)	OVER (PARTITION BY year_month)
			/ SUM(unique_tickets)		OVER (PARTITION BY year_month))							AS chapter_ticket_cost_gross,
			--------------------------------------------------------------------------------------------------------------------------
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY emp_tribe_id, year_month)	AS tribe_sc_work_cost_gross_with_AOE,
			--------------------------------------------------------------------------------------------------------------------------
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY emp_tribe_id, year_month)	AS chapter_sc_work_cost_gross_withAOE,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)					OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY emp_tribe_id, year_month)
			/ SUM(iterations)					OVER (PARTITION BY emp_tribe_id, year_month))	AS tribe_iteration_cost_gross_withAOE,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(iterations)					OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY year_month)
			/ SUM(iterations)					OVER (PARTITION BY year_month))					AS chapter_iteration_cost_gross_withAOE,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)				OVER (PARTITION BY emp_tribe_id, year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY emp_tribe_id, year_month)
			/ SUM(unique_tickets)				OVER (PARTITION BY emp_tribe_id, year_month))	AS tribe_ticket_cost_gross_withAOE,
			--------------------------------------------------------------------------------------------------------------------------
			IIF(SUM(unique_tickets)				OVER (PARTITION BY year_month) = 0, 0,
			SUM(emp_sc_work_cost_gross_withAOE)	OVER (PARTITION BY year_month)
			/ SUM(unique_tickets)				OVER (PARTITION BY year_month))					AS chapter_ticket_cost_gross_withAOE
			--------------------------------------------------------------------------------------------------------------------------
	FROM	dev_support_cost
)

SELECT	year_month                              AS {year_month},
		emp_tribe_name                          AS {emp_tribe_name},
		emp_name                                AS {emp_name},
		position_name                           AS {position_name},
		emp_level_name                          AS {emp_level_name},
		hourly_pay_net                          AS {hourly_pay_net},
		hourly_pay_gross                        AS {hourly_pay_gross},
		hourly_pay_gross_withAOE                AS {hourly_pay_gross_withAOE},
		paid_vacation_hours                     AS {paid_vacation_hours},
		free_vacation_hours                     AS {free_vacation_hours},
		paid_hours                              AS {paid_hours},
		sc_hours                                AS {sc_hours},
		sc_paidvacs_hours                       AS {sc_paidvacs_hours},
		NULL									AS {sc_paidvacs_hours_incl_overtime},
		NULL									AS {overtime_sc_hours},
		NULL									AS {proactive_paidvacs_hours},
		unique_tickets							AS {unique_tickets},
		iterations								AS {iterations},
		NULL									AS {emp_sc_work_cost_gross_incl_overtime},
		NULL									AS {emp_sc_work_cost_gross_withAOE_incl_overtime},
		NULL									AS {emp_total_work_hours},
		NULL									AS {tribe_total_work_hours},
		NULL									AS {chapter_total_work_hours},
		emp_sc_work_cost_gross					AS {emp_sc_work_cost_gross},
		tribe_sc_work_cost_gross				AS {tribe_sc_work_cost_gross},
		chapter_sc_work_cost_gross				AS {chapter_sc_work_cost_gross},
		emp_sc_work_cost_gross_withAOE			AS {emp_sc_work_cost_gross_withAOE},
		tribe_sc_work_cost_gross_with_AOE		AS {tribe_sc_work_cost_gross_with_AOE},
		chapter_sc_work_cost_gross_withAOE		AS {chapter_sc_work_cost_gross_withAOE},
		NULL									AS {emp_proactive_work_cost_gross},
		NULL									AS {tribe_proactive_work_cost_gross},
		NULL									AS {chapter_proactive_work_cost_gross},
		NULL									AS {emp_proactive_work_cost_gross_withAOE},
		NULL									AS {tribe_proactive_work_cost_gross_withAOE},
		NULL									AS {chapter_proactive_work_cost_gross_withAOE},
		emp_ticket_cost_gross					AS {emp_ticket_cost_gross},
		tribe_ticket_cost_gross					AS {tribe_ticket_cost_gross},
		chapter_ticket_cost_gross				AS {chapter_ticket_cost_gross},
		emp_ticket_cost_gross_withAOE			AS {emp_ticket_cost_gross_withAOE},
		tribe_ticket_cost_gross_withAOE			AS {tribe_ticket_cost_gross_withAOE},
		chapter_ticket_cost_gross_withAOE		AS {chapter_ticket_cost_gross_withAOE},
		emp_iteration_cost_gross				AS {emp_iteration_cost_gross},
		tribe_iteration_cost_gross				AS {tribe_iteration_cost_gross},
		chapter_iteration_cost_gross			AS {chapter_iteration_cost_gross},
		emp_iteration_cost_gross_withAOE		AS {emp_iteration_cost_gross_withAOE},
		tribe_iteration_cost_gross_withAOE		AS {tribe_iteration_cost_gross_withAOE},
		chapter_iteration_cost_gross_withAOE	AS {chapter_iteration_cost_gross_withAOE},
		NULL									AS {emp_iterations_per_hour},
		tribe_iterations_per_hour				AS {tribe_iterations_per_hour},
		chapter_iterations_per_hour				AS {chapter_iterations_per_hour},
		NULL									AS {emp_hours_per_ticket},
		NULL									AS {emp_tickets_per_hour},
		tribe_tickets_per_hour					AS {tribe_tickets_per_hour},
		chapter_tickets_per_hour				AS {chapter_tickets_per_hour},
		NULL									AS {tribe_fot_gross},
		NULL									AS {tribe_fot_gross_withAOE},
		NULL									AS {chapter_fot_gross},
		NULL									AS {chapter_fot_gross_withAOE},
		NULL									AS {tribe_hour_price_gross},
		NULL									AS {tribe_hour_price_gross_withAOE},
		NULL									AS {chapter_hour_price_gross},
		NULL									AS {chapter_hour_price_gross_withAOE},
		1										AS {is_dev_team}
FROM	dev_tribe_totals
WHERE	emp_iteration_cost_gross_withAOE IS NOT NULL
UNION ALL
SELECT	*,
		0 AS is_dev_team
FROM	support_totals_ex
ORDER BY year_month, emp_tribe_name, position_name, emp_name
