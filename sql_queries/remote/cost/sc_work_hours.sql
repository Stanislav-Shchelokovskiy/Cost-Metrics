SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--EXEC DXStatisticsV2.dbo.update_employees_positions_audit @json = N'{employees_audit_json}';

DECLARE @employees_audit_json VARCHAR(MAX) = N'{employees_audit_json}'
DECLARE @employees 			VARCHAR(MAX) = N'{employees_json}'
DECLARE @start				DATE = '{start}'
DECLARE @end				DATE = '{end}'


DROP TABLE IF EXISTS #EmployeesPositionsAudit;
SELECT	*
INTO #EmployeesPositionsAudit
FROM (	SELECT	EntityOid                                                                                           AS crmid,
				IIF(LAG(EntityModified) OVER (ORDER BY EntityModified ASC) IS NULL,
					'1990-01-01', 
					DATEFROMPARTS(YEAR(EntityModified), MONTH(EntityModified), 1))                                  AS period_start,
				LEAD(DATEFROMPARTS(YEAR(EntityModified), MONTH(EntityModified), 1)) OVER (ORDER BY EntityModified)  AS period_end,
				EmployeePosition_Id	                                                                                AS position_id
		FROM	DXStatisticsV2.dbo.parse_employees_audit(@employees_audit_json)
		WHERE	ChangedProperties LIKE '%Position%'
			AND EmployeePosition_Id IS NOT NULL
			AND EmployeePosition_Id != CAST(0x0 AS UNIQUEIDENTIFIER)
	)	AS ea
WHERE period_end IS NULL OR period_end > period_start

CREATE CLUSTERED INDEX idx ON #EmployeesPositionsAudit(crmid, period_start, period_end);


DROP TABLE IF EXISTS #EmployeesTmp;
SELECT  crmid, scid, position_id
INTO	#EmployeesTmp
FROM    DXStatisticsV2.dbo.parse_employees(@employees)

CREATE CLUSTERED INDEX idx ON #EmployeesTmp(scid);

DROP TABLE IF EXISTS #TicketChanges;
SELECT  Ticket_Id									AS ticket_id,
		AuditOwner 									AS emp_scid,
		e.crmid			        					AS emp_crmid,
		e.position_id								AS emp_position_id,
		DATETIMEFROMPARTS(
			DATEPART(YEAR,	EntityModified),
			DATEPART(MONTH, EntityModified),
			DATEPART(DAY,	EntityModified),
			DATEPART(HOUR,	EntityModified),
			0, 0, 0 ) 								AS time_stamp,
		CAST(posts_audit.EntityModified AS DATE)	AS date
INTO 	#TicketChanges
FROM	scpaid_audit.[c1f0951c-3885-44cf-accb-1a390f34c342].scworkflow_Posts AS posts_audit
		CROSS APPLY (
			SELECT  TOP 1 t.Id
			FROM    SupportCenterPaid.[c1f0951c-3885-44cf-accb-1a390f34c342].Tickets AS t
					OUTER APPLY (
						SELECT  scid
						FROM    #EmployeesTmp 
						WHERE   scid = t.Owner
					) AS e
			WHERE	t.Id = posts_audit.Ticket_Id
				/* We take into account only tickets created by users. */
				AND e.scid IS NULL
				/* and tickets of type (question, suggestion, bug). */
				AND t.EntityType IN (1 /* Question */, 2 /* Bug */, 3 /* suggestion */)
		) AS users_tickets_only
		CROSS APPLY (
			SELECT  crmid, position_id
			FROM    #EmployeesTmp
			WHERE   scid = posts_audit.AuditOwner
		) AS e
WHERE	AuditAction IN (0 /* Insert */, 1 /* Update */)
	AND EntityModified BETWEEN @start AND @end
	/*	Throw away weekends work hours.	*/
	AND DATEPART(DW, EntityModified) NOT IN (7 /*saturday*/ , 1 /*sunday*/)
	AND Type NOT IN (3 /* Note */, 0 /* Description */)
	AND AuditOwner = Owner
	AND Ticket_Id IS NOT NULL


DROP TABLE IF EXISTS #SCWorkHours;
WITH sc_work_hoursTMP AS (
	SELECT  emp_scid	            AS emp_scid,
			date		            AS date,
			IIF(    
					--If is_holiday returns 1, we always take wf workhours.
					ISNULL(wf_wh.is_holiday, 0) = 1 OR
					-- If emp doesn't work today, we always return 0.
					(wf_wh.work_hours = 0 AND wf_wh.proactive_hours = 0) OR
					-- Otherwise, we take max of sc work hours and wf workhours for Support Developers only.
					(   ISNULL(emp_position_audit.position_id, emp_position_id) IN ('7A8E1B05-385E-4C91-B61E-81446B0C404A' /* Support Developer */,
																					'10D4EC1A-8EEA-4930-A88B-76D0CAC11E89' /* Support Developer PH */) AND
						sc_wh.work_hours < ISNULL(wf_wh.work_hours, 0)),
					wf_wh.work_hours,
					-- If none of the above, we take sc work hours.
					sc_wh.work_hours ) AS work_hours
	FROM    (   SELECT  emp_scid	                AS emp_scid,
						emp_crmid                   AS emp_crmid,
						emp_position_id             AS emp_position_id,
						date						AS date,
						COUNT(DISTINCT time_stamp)	AS work_hours
				FROM    #TicketChanges
				/*	All replies and work hours in non primary tent are moved (as is) as replies and work hours in the primary tent. */
				/*	Don't group by anything else here. Otherwise make sure to filter result further by the new group field. */
				GROUP BY emp_scid, emp_crmid, emp_position_id, date
			) AS sc_wh
			OUTER APPLY (
				SELECT  is_holiday, SUM(work_hours) AS work_hours, SUM(proactive_hours) AS proactive_hours
				FROM    DXStatisticsV2.dbo.EmployeesWFWorkHours
				WHERE	crmid = sc_wh.emp_crmid
					AND date = sc_wh.date
				GROUP BY crmid, date, is_holiday
			) AS wf_wh
			OUTER APPLY (
				SELECT TOP 1 position_id
				FROM    DXStatisticsV2.dbo.EmployeesPositionsAudit
				WHERE	crmid = sc_wh.emp_crmid
					AND period_start <= sc_wh.date 
					AND (period_end IS NULL OR period_end > sc_wh.date )
			) AS emp_position_audit
)

SELECT	emp_scid									AS emp_scid,
		DATEFROMPARTS(YEAR(date), MONTH(date), 1)	AS year_month,
		SUM(work_hours)							    AS work_hours
INTO	#SCWorkHours
FROM	sc_work_hoursTMP--DXStatisticsV2.dbo.sc_work_hoursTMP(@start, @end, @employees)
/*	Don't group by anything else here. Otherwise make sure to filter result further by the new group field. */
GROUP BY	emp_scid,
			DATEFROMPARTS(YEAR(date), MONTH(date), 1)

CREATE CLUSTERED INDEX idx ON #SCWorkHours(emp_scid, year_month);

DROP TABLE #EmployeesPositionsAudit
DROP TABLE #EmployeesTmp
DROP TABLE #TicketChanges
