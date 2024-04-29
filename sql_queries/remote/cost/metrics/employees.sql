DECLARE @start	DATE = '{start}'
DECLARE @end	DATE = '{end}'
DECLARE @new_life_start DATE = '2022-10-01'
DECLARE @working_hours_per_month TINYINT = 168

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

DECLARE @philippines UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'

DECLARE @tents_introduction_date	DATE = '2023-04-01'
DECLARE @relocation_date	DATE = '2022-03-01'

DECLARE @null_date	DATE = '1990-01-01'


DROP TABLE IF EXISTS #Employees
SELECT	months.year_month														AS year_month,
		DATEADD(MONTH, 1, months.year_month)									AS next_year_month,
		employees.crmid															AS crmid,
		employees.scid															AS scid,
		employees.name															AS name,
		ISNULL(emps_levels.level_name, 
			ISNULL(emp_position_audit.position_name, employees.position_name))	AS level_name,
		salaries.level_value													AS level_value,
		ISNULL(tax_coefficients.value, 1)										AS tax_coefficient,
		--	#Postulate: SC fot is calculated by using sc work hour price.
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ROUND(salaries.value_usd / @working_hours_per_month, 3)																					AS hourly_pay_net,
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ROUND(salaries.value_usd * ISNULL(tax_coefficients.value, 1) / @working_hours_per_month, 3)												AS hourly_pay_gross,
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		ROUND((salaries.value_usd * ISNULL(tax_coefficients.value, 1) + ISNULL(operating_expenses.value_usd, 0)) / @working_hours_per_month, 3)	AS hourly_pay_gross_withAOE,
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		employees.retired														AS retired,
		ISNULL(emp_hired_audit.hired_at, employees.hired_at)					AS hired_at,
		employees.retired_at													AS retired_at,
		ISNULL(emp_tribe_audit.tribe_id, employees.tribe_id)					AS tribe_id,
		IIF(emp_tribe_audit.tribe_id IS NULL,
			employees.tribe_name, emp_tribe_audit.tribe_name)					AS tribe_name,
		-------------------------------------------------------------------------------------------------------
		IIF(months.year_month > @tents_introduction_date,
			ISNULL(emp_tent_audit.tent_id, employees.tent_id), NULL)			AS tent_id,
		-------------------------------------------------------------------------------------------------------
		IIF(months.year_month > @tents_introduction_date,
			ISNULL(emp_tent_audit.tent_name, employees.tent_name), NULL)		AS tent_name,
		-------------------------------------------------------------------------------------------------------
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
			FROM	#EmployeesFromJson AS e
			WHERE	e.is_service_user = 0
		) AS employees
		OUTER APPLY (
			SELECT	 MIN(HiredAt) AS hired_at
			FROM	#EmployeesAudit
			WHERE	EntityOid = employees.crmid
		)	AS emp_hired_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	ea.chapter_id								AS chapter_id,
							ea.period_start								AS period_start,
							LEAD(period_end) OVER (ORDER BY period_end)	AS period_end,
							modified									AS modified
					FROM (	SELECT	IIF(LAG(EntityModified) OVER (ORDER BY EntityModified ASC) IS NULL,
										@null_date,
										DXStatisticsV2.dbo.round_to_nearest_month(EntityModified))	AS period_start,
									DXStatisticsV2.dbo.round_to_nearest_month(EntityModified)		AS period_end,
									Chapter_Id														AS chapter_id,
									EntityModified													AS modified
							FROM	#EmployeesAudit
							WHERE	EntityOid = employees.crmid
								AND ChangedProperties LIKE '%Chapter%'
								AND Chapter_Id IS NOT NULL
						) AS ea
				) AS ea_outer
			WHERE	ea_outer.period_start <= months.year_month 
				AND (ea_outer.period_end IS NULL OR ea_outer.period_end > months.year_month)
			ORDER BY ea_outer.modified DESC
		)	AS emp_chapter_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	ea.tribe_id											AS tribe_id,
							ISNULL(tribe.Name, (SELECT TOP 1 Name
												FROM	CRMAudit.dxcrm.Tribes
												WHERE 	EntityOid = ea.tribe_id
													AND Name != 'TO DELETE'
												ORDER BY EntityModified DESC))	AS tribe_name,
							ea.period_start										AS period_start,
							LEAD(ea.period_end) OVER (ORDER BY ea.period_end)	AS period_end,
							modified											AS modified
					FROM (	SELECT	IIF(LAG(EntityModified) OVER (ORDER BY EntityModified ASC) IS NULL,
										@null_date,
										DXStatisticsV2.dbo.round_to_nearest_month(EntityModified))	AS period_start,
									DXStatisticsV2.dbo.round_to_nearest_month(EntityModified)		AS period_end,
									Tribe_Id														AS tribe_id,
									EntityModified													AS modified
							FROM	#EmployeesAudit
							WHERE	EntityOid = employees.crmid
								AND ChangedProperties LIKE '%Tribe%'
								AND Tribe_Id IS NOT NULL
								AND Tribe_Id != CAST(0x0 AS UNIQUEIDENTIFIER)
						)	AS ea
						LEFT JOIN CRM.dbo.Tribes AS tribe ON tribe.Id = ea.tribe_id
				) AS ea_outer
			WHERE	ea_outer.period_start <= months.year_month 
				AND (ea_outer.period_end IS NULL OR ea_outer.period_end > months.year_month)
			ORDER BY ea_outer.modified DESC
		) AS emp_tribe_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	tent_id																									AS tent_id,
							tent_name																								AS tent_name,
							LAG(DXStatisticsV2.dbo.round_to_nearest_month(removed_at), 1, @null_date) OVER (ORDER BY removed_at) 	AS period_start,
							IIF(YEAR(removed_at) != YEAR(added_at) AND MONTH(removed_at) != MONTH(added_at),
								DXStatisticsV2.dbo.round_to_nearest_month(removed_at), 
								removed_at)																							AS period_end,
							removed_at																								AS modified
					FROM (	SELECT	*,
									IIF(added_at != removed_at, DATEDIFF(DAY, added_at, removed_at), NULL) AS days_in_tent
							FROM (	SELECT	Tent_Id											AS tent_id,
											t.Name											AS tent_name,
											MIN(EntityModified) OVER (PARTITION BY Tent_Id) AS added_at,
											MAX(EntityModified) OVER (PARTITION BY Tent_Id) AS removed_at,
											AuditAction
									FROM	CRMAudit.dxcrm.Tent_Employee AS te
											LEFT JOIN CRM.dbo.Tents AS t ON t.Id = te.Tent_Id
									WHERE	Employee_Id = employees.crmid
								) AS ea_inner
						) AS ea
					WHERE	AuditAction = 2 /* DELETED */
						AND	(days_in_tent IS NULL OR days_in_tent > 1)
			) AS ea_outer
			WHERE	ea_outer.period_start <= months.year_month 
				AND (ea_outer.period_end IS NULL OR ea_outer.period_end > months.year_month)
			ORDER BY ea_outer.modified DESC
		) AS emp_tent_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	ea.position_id									AS position_id,
							(	SELECT TOP 1 ep.name 
								FROM #EmployeePositions AS ep 
								WHERE ep.id = ea.position_id)				AS position_name,
							ea.period_start									AS period_start,
							LEAD(ea.period_end) OVER (ORDER BY period_end)	AS period_end
					FROM (	SELECT	IIF(LAG(EntityModified) OVER (ORDER BY EntityModified ASC) IS NULL,
										@null_date, 
										EntityModified)	AS period_start,
									EntityModified		AS period_end,
									EmployeePosition_Id	AS position_id
							FROM	#EmployeesAudit
							WHERE	EntityOid = employees.crmid
								AND ChangedProperties LIKE '%Position%'
								AND EmployeePosition_Id IS NOT NULL
						)	AS ea
				) AS ea_outer
			WHERE	DATEFROMPARTS(YEAR(ea_outer.period_start), MONTH(ea_outer.period_start), 1)  <= months.year_month 
				AND (ea_outer.period_end IS NULL OR ea_outer.period_end > months.year_month)
            ORDER BY ea_outer.period_start DESC
		) AS emp_position_audit
		OUTER APPLY (
			/*	If level_id is null, then we calculate it using EmployeesSalaries below.	
				Don't change just this part. Change also probable_level_num calculation below.	*/
			SELECT	TOP 1 EmployeeLevel_Id AS level_id
			FROM	#EmployeesAudit
			WHERE	EntityOid = employees.crmid
				AND DATEFROMPARTS(YEAR(EntityModified), MONTH(EntityModified), 1) <= months.year_month
				AND ChangedProperties LIKE '%Level%'
			ORDER BY EntityModified DESC
		) AS emp_level_audit
		OUTER APPLY (
			SELECT TOP 1 *
			FROM (	SELECT	IIF(locations.is_active = 0, NULL, ea.location_id)	AS location_id,
							IIF(locations.is_active = 0, NULL, locations.name)	AS location_name,
							ea.period_start										AS period_start,
							LEAD(ea.period_end) OVER (ORDER BY period_end)		AS period_end,
							modified											AS modified
					FROM (	SELECT	IIF(LAG(EntityModified) OVER (ORDER BY EntityModified ASC) IS NULL,
										@null_date,
										DXStatisticsV2.dbo.round_to_nearest_month(EntityModified))	AS period_start,
									DXStatisticsV2.dbo.round_to_nearest_month(EntityModified)		AS period_end,
									EmployeeLocation_id												AS location_id,
									EntityModified													AS modified
							FROM	#EmployeesAudit
							WHERE	EntityOid = employees.crmid
								AND ChangedProperties LIKE '%Location%'
						)	AS ea
						CROSS APPLY (
							SELECT	name, is_active
							FROM	#EmployeeLocations AS l
							WHERE	l.id = ea.location_id
						) AS locations
				) AS ea_outer
			WHERE	ea_outer.period_start <= months.year_month 
				AND (ea_outer.period_end IS NULL OR ea_outer.period_end > months.year_month)
			ORDER BY ea_outer.modified DESC
		) AS emp_location_audit
		CROSS APPLY (
			SELECT	es_inner.value * CASE es_inner.currency	WHEN @php THEN @php_to_usd
															WHEN @eur THEN @eur_to_usd
															ELSE 1.0 END  AS value_usd,
					es_inner.level_id,
					es_inner.period,
					es_inner.level_value
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
			WHERE	((emp_location_audit.location_id IS NULL AND eoe.location_id IS NULL) OR eoe.location_id = ISNULL(emp_location_audit.location_id, employees.location_id))
				AND eoe.actual_since <= months.year_month
			ORDER BY eoe.actual_since DESC
		) AS operating_expenses
		OUTER APPLY (
			SELECT	TOP 1 etc.value
			FROM	DXStatisticsV2.dbo.EmployeesTaxCoefficients AS etc
			WHERE	((emp_location_audit.location_id IS NULL AND etc.location_id IS NULL) OR etc.location_id = ISNULL(emp_location_audit.location_id, IIF(months.year_month >= @relocation_date, employees.location_id, NULL)))
				AND etc.actual_since <= months.year_month
				AND etc.self_employed = IIF(EXISTS(SELECT TOP 1 ese.crmid FROM DXStatisticsV2.dbo.EmployeesSelfEmployed AS ese WHERE ese.crmid = employees.crmid), 1, 0)
			ORDER BY etc.actual_since DESC
		) AS tax_coefficients
		OUTER APPLY (
			SELECT	TOP 1 el.name AS level_name
			FROM	#EmployeeLevels AS el
			WHERE	el.id = salaries.level_id
		) AS emps_levels
		/*	throw away never hired employees or employees after retirement	*/
WHERE	(emp_position_audit.position_id IS NOT NULL OR employees.position_id IS NOT NULL)
		AND months.year_month > ISNULL(ISNULL(emp_hired_audit.hired_at, employees.hired_at), @null_date)
		AND months.year_month < ISNULL(employees.retired_at, '9999-01-01')	
		AND	(	salaries.level_value IS NULL -- if level isn't found, we will fail on alter column level_value below stopping future processing.
				OR	salaries.period = @not_applicable	-- ph guys
				/*	regular guys corresponding to correct salary period as left joining EmployeesSalaries duplicated them	*/
				OR (months.year_month <  @new_life_start AND salaries.period = @before_oct_2022)
				OR (months.year_month >= @new_life_start AND salaries.period = @after_oct_2022))

ALTER TABLE #Employees ALTER COLUMN level_value FLOAT NOT NULL -- if we fail here, this means EmployeesSalaries is outdated.

CREATE CLUSTERED INDEX idx ON #Employees(scid, year_month)
CREATE NONCLUSTERED INDEX idx_ ON #Employees(position_id, chapter_id, has_support_processing_role) 
INCLUDE(year_month, crmid, name, level_name, hourly_pay_net, hourly_pay_gross, hourly_pay_gross_withAOE, retired, retired_at, tribe_id, tribe_name, tent_id, tent_name)
