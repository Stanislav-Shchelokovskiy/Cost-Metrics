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

DECLARE @devexpress_tribe_id	UNIQUEIDENTIFIER = '340E06F5-9B98-4923-97A4-CA02BA73F075'
DECLARE @current_month			DATE = DATEFROMPARTS(YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 1)

DECLARE @support 	TINYINT = 0
DECLARE @devs		TINYINT = 1;

WITH emp_activity_in_tribe AS (
	SELECT	emp_crmid			AS emp_crmid,
			emp_scid			AS emp_scid,
			year_month			AS year_month,
			emp_tribe_id		AS emp_tribe_id,
			emp_tent_id			AS emp_tent_id,
			emp_tribe_name		AS emp_tribe_name,
			emp_tent_name		AS emp_tent_name,
			sc_hours			AS sc_hours,
			--------------------------------------
			SUM(unique_tickets)	AS unique_tickets,
			SUM(iterations)		AS iterations
			--------------------------------------
	FROM	#Iterations
	GROUP BY emp_crmid, emp_scid, year_month, emp_tribe_id, emp_tribe_name, emp_tent_id, emp_tent_name, sc_hours
),

emp_activity_in_tribe_with_external_activity AS (
	SELECT	emp_crmid,
			year_month,
			emp_tribe_id,
			emp_tent_id,
			emp_tribe_name,
			emp_tent_name,
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
			emp_tent_id,
			emp_tribe_name,
			emp_tent_name,
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
			--********************************************************************************************
			/*	#Postulate: All replies and work hours in non primary tribe are moved (as is) as replies and work hours in the primary tribe.	*/
			ISNULL(employees.tribe_id, emps_empirical_tribe_tent.tribe_id)				AS emp_tribe_id,
			ISNULL(employees.tribe_name, emps_empirical_tribe_tent.tribe_name)			AS emp_tribe_name,
			----------------------------------------------------------------------------------------------
			IIF(employees.year_month > @tents_introduction_date,
				ISNULL(employees.tent_id, emps_empirical_tribe_tent.tent_id), NULL)		AS emp_tent_id,
			----------------------------------------------------------------------------------------------
			IIF(employees.year_month > @tents_introduction_date,
				ISNULL(employees.tent_name, emps_empirical_tribe_tent.tent_name), NULL)	AS emp_tent_name,
			--********************************************************************************************
			ISNULL(emps_activity_aggs.sc_hours, 0)					AS sc_hours,
			ISNULL(wf_proactive.hours, 0)							AS wf_proactive_hours,
			ISNULL(emps_activity_aggs.unique_tickets, 0)			AS unique_tickets,
			ISNULL(emps_activity_aggs.iterations, 0)				AS iterations,
			ISNULL(v.paid_hours, 0)									AS paid_vacation_hours,
			ISNULL(v.free_hours, 0)									AS free_vacation_hours,
			-----------------------------------------------------------------------------------------------
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
				SELECT  TOP 1	emps_transformed.emp_tribe_id	AS tribe_id,
								emps_transformed.emp_tribe_name AS tribe_name,
								emps_transformed.emp_tent_id	AS tent_id,
								emps_transformed.emp_tent_name	AS tent_name
				FROM	emp_activity_in_tribe_transformed AS emps_transformed
				WHERE	emps_transformed.emp_crmid = employees.crmid
				ORDER BY sc_hours DESC
			) AS emps_empirical_tribe_tent
			OUTER APPLY (
				SELECT	emps_transformed.sc_hours,
						emps_transformed.unique_tickets,
						emps_transformed.iterations
				FROM	emp_activity_in_tribe_transformed AS emps_transformed
				WHERE	emps_transformed.emp_crmid	= employees.crmid
					AND emps_transformed.year_month	= employees.year_month
			) AS emps_activity_aggs
			OUTER APPLY (
				SELECT	SUM(hours) AS hours
				FROM	DXStatisticsV2.dbo.EmployeesProactiveHours AS eph
				WHERE	eph.crmid = employees.crmid
					AND	eph.date >= year_month AND eph.date < DATEADD(MONTH, 1, year_month)
			) AS wf_proactive
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

emp_activity_by_team AS (
	SELECT 	*,
			CASE
				WHEN	/*	#Postulate: Take into account only tribe suppor including support chapter managers and support leaders.	*/
						position_id IN (@support_developer_ph, @support_developer)
					OR	(position_id = @chapter_leader	AND chapter_id = @support_developers_chapter)
					OR	(position_id = @tribe_leader	AND has_support_processing_role = 1)
				THEN @support
				WHEN
						position_id IN (@developer, @pm, @principal_pm, @technical_writer)
					OR 	(position_id IN (@chapter_leader, @tribe_leader, @squad_leader) AND has_support_processing_role = 0)
				THEN @devs
				ELSE NULL
			END AS team
	FROM 	emp_activity_reduced
),

emp_activity_with_dev_sc_hours AS (
	SELECT
		year_month,
		emp_crmid,
		emp_name,
		position_id,
		chapter_id,
		emp_tribe_id,
		emp_tent_id,
		emp_tribe_name,
		emp_tent_name,
		has_support_processing_role,
		position_name,
		emp_level_name,
		hourly_pay_net,
		hourly_pay_gross,
		hourly_pay_gross_withAOE,
		IIF(team = @support, 
			IIF(sc_hours > wf_proactive_hours,  sc_hours - wf_proactive_hours, 0), /* pure sc hours. We take proactive hours from wf into account. */
			paid_hours * ISNULL(eds.perc_of_worktime_spent_on_support,
									IIF(emp_tribe_id = '7EA63303-B033-4CCA-800A-B8461E2E8364' /* IDETeam */, 0.5,
										IIF(SUM(eds.perc_of_worktime_spent_on_support) OVER (PARTITION BY emp_tribe_name) = 0, 0,
											SUM(eds.perc_of_worktime_spent_on_support) OVER (PARTITION BY emp_tribe_name) * 1.0
											/ SUM(CASE WHEN eds.perc_of_worktime_spent_on_support IS NULL OR eds.perc_of_worktime_spent_on_support = 0 
														THEN 0 ELSE 1 END) OVER (PARTITION BY emp_tribe_name))))) AS sc_hours,
		wf_proactive_hours,
		unique_tickets,
		iterations,
		paid_vacation_hours,
		free_vacation_hours,
		paid_hours,
		team
	FROM  	emp_activity_by_team AS emp_activity
			LEFT JOIN DXStatisticsV2.dbo.EmployeesDevSupport AS eds ON eds.crmid = emp_activity.emp_crmid
	WHERE paid_hours > 0
		AND team IS NOT NULL
		AND	emp_tribe_id IS NOT NULL 
		AND emp_tribe_id != '25F4510A-8122-4B69-8E6B-3091BC05B4CD' /*Internal*/
		AND emp_crmid NOT IN (	'04BFC59C-BD92-11E4-8260-F46D0490CBCF'/*Belym*/, 
								'A6FB4631-6A1F-47E0-A545-DC354069D540'/*Prohorov*/)
),

emp_activity_with_sc_paidvacs_hours_incl_overtime AS (
	SELECT	*,
			sc_hours + paid_vacation_hours * (IIF(sc_hours > paid_hours, paid_hours,  sc_hours) * 1.0 / paid_hours) AS sc_paidvacs_hours_incl_overtime
	FROM	emp_activity_with_dev_sc_hours
),

emp_activity_with_sc_paidvacs_hours AS (
	SELECT	*,
			IIF(sc_paidvacs_hours_incl_overtime > paid_hours, paid_hours, sc_paidvacs_hours_incl_overtime) AS sc_paidvacs_hours
	FROM	emp_activity_with_sc_paidvacs_hours_incl_overtime
),

emp_activity_with_total_hours AS (
	SELECT	*,
			/* proactive_paidvacs_hours = [required] proactive hours from wf plus [optional] (paid_hours - wf_proactive_hours - pure sc hours) */
			wf_proactive_hours + IIF(sc_paidvacs_hours > paid_hours - wf_proactive_hours, 0, paid_hours - wf_proactive_hours - sc_paidvacs_hours) AS proactive_paidvacs_hours
	FROM	emp_activity_with_sc_paidvacs_hours
),

emp_activity AS (
	SELECT	year_month,
			emp_crmid,
			--------------------------------------------------------------------------------------------------
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= '2022-01-01', 
				@devexpress_tribe_id,
				emp_tribe_id)	AS emp_tribe_id,
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= @tents_introduction_date, 
				@devexpress_tent_id,
				emp_tent_id)	AS emp_tent_id,
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= '2022-01-01', 
				(SELECT TOP 1 Name FROM CRM.dbo.Tribes WHERE Id = @devexpress_tribe_id),
				emp_tribe_name)	AS emp_tribe_name,
			IIF(emp_crmid = 'BE79612E-8677-4C33-923A-5F555AE12A77' /*Skorkin*/ AND year_month >= @tents_introduction_date, 
				(SELECT TOP 1 Name FROM CRM.dbo.Tents WHERE Id = @devexpress_tent_id),
				emp_tent_name)	AS emp_tent_name,
			--------------------------------------------------------------------------------------------------
			emp_name,
			position_name,
			emp_level_name,
			hourly_pay_net,
			hourly_pay_gross,
			hourly_pay_gross_withAOE,
			unique_tickets,
			iterations,
			paid_vacation_hours,
			free_vacation_hours,
			paid_hours,
			team,
			sc_hours,
			sc_paidvacs_hours,
			sc_paidvacs_hours_incl_overtime,
			proactive_paidvacs_hours,
			IIF(sc_hours < sc_paidvacs_hours, 0, sc_hours - sc_paidvacs_hours) 								AS overtime_sc_hours,
			------------------------------------------------------------------------------------------------------------------------------------------------
			sc_paidvacs_hours_incl_overtime + proactive_paidvacs_hours										AS emp_total_work_hours,
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
			hourly_pay_gross * proactive_paidvacs_hours														AS emp_proactive_work_cost_gross,
			------------------------------------------------------------------------------------------------------------------------------------------------
			hourly_pay_gross_withAOE * proactive_paidvacs_hours												AS emp_proactive_work_cost_gross_withAOE,
			------------------------------------------------------------------------------------------------------------------------------------------------
			sc_paidvacs_hours_incl_overtime * hourly_pay_gross_withAOE
			+ ISNULL(work_on_holidays.hours, 0) * hourly_pay_gross											AS emp_sc_work_cost_gross_withAOE_incl_overtime
			------------------------------------------------------------------------------------------------------------------------------------------------
	FROM	emp_activity_with_total_hours
			OUTER APPLY (
				SELECT	SUM(hours) AS hours
				FROM	DXStatisticsV2.dbo.EmployeesWorkOnHolidays AS woh
				WHERE	woh.crmid = emp_crmid
					AND	woh.date >= year_month AND woh.date < DATEADD(MONTH, 1, year_month)
			) AS work_on_holidays
)

SELECT 	emp_crmid										AS {emp_crmid},
		year_month										AS {year_month},
		CASE team
			WHEN @support 	THEN 'Support'
			WHEN @devs		THEN 'DevTeam'
		END												AS {team},
		emp_tribe_name									AS {tribe_name},
		emp_tent_name									AS {tent_name},
		emp_name										AS {name},
		position_name									AS {position_name},
		emp_level_name									AS {level_name},
		hourly_pay_net									AS {hourly_pay_net},
		hourly_pay_gross								AS {hourly_pay_gross},
		hourly_pay_gross_withAOE						AS {hourly_pay_gross_withAOE},
		paid_vacation_hours								AS {paid_vacation_hours},
		free_vacation_hours								AS {free_vacation_hours},
		paid_hours										AS {paid_hours},
		sc_hours										AS {sc_hours},
		sc_paidvacs_hours								AS {sc_paidvacs_hours},
		sc_paidvacs_hours_incl_overtime					AS {sc_paidvacs_hours_incl_overtime},
		overtime_sc_hours								AS {overtime_sc_hours},
		proactive_paidvacs_hours						AS {proactive_paidvacs_hours},
		unique_tickets									AS {unique_tickets},
		iterations										AS {iterations},
		emp_total_work_hours							AS {total_work_hours},
		emp_sc_work_cost_gross							AS {sc_work_cost_gross},
		emp_sc_work_cost_gross_incl_overtime			AS {sc_work_cost_gross_incl_overtime},
		emp_sc_work_cost_gross_withAOE					AS {sc_work_cost_gross_withAOE},
		emp_proactive_work_cost_gross					AS {proactive_work_cost_gross},
		emp_proactive_work_cost_gross_withAOE			AS {proactive_work_cost_gross_withAOE},
		emp_sc_work_cost_gross_withAOE_incl_overtime	AS {sc_work_cost_gross_withAOE_incl_overtime}
FROM 	emp_activity
