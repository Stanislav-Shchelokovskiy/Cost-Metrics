/*******************
	Totals
********************/
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
