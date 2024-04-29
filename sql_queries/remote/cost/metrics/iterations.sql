DROP TABLE IF EXISTS #Iterations;
WITH iterations AS (
	SELECT 	e.crmid							AS emp_crmid,
			e.scid							AS emp_scid,
			e.name							AS emp_name,
			e.year_month					AS year_month,
			e.position_id					AS emp_position_id,
			e.chapter_id					AS emp_chapter_id,
			e.has_support_processing_role	AS has_support_processing_role,
			i.ticket_scid					AS ticket_scid,
			i.post_id						AS post_id
	FROM	#Employees AS e
			LEFT JOIN #IterationsRaw AS i ON i.emp_scid = e.scid AND i.year_month = e.year_month
),

iterations_reduced AS (
	SELECT	i.emp_crmid						AS emp_crmid,
			i.emp_scid						AS emp_scid,
			MIN(i.emp_name)					AS emp_name,
			i.year_month					AS year_month,
			i.emp_position_id				AS emp_position_id,
			i.emp_chapter_id				AS emp_chapter_id,
			i.has_support_processing_role	AS has_support_processing_role,
			-------------------------------------------------------
			COUNT(DISTINCT i.ticket_scid)	AS unique_tickets,
			COUNT(i.post_id)				AS iterations
			-------------------------------------------------------
	FROM	iterations AS i
	/*	#Postulate: All replies and work hours in non primary tribe are moved (as is) as replies and work hours in the primary tribe.
		The move is per month.	*/
	GROUP BY	i.emp_crmid, 
				i.emp_scid,
				i.year_month,
				emp_position_id,
				emp_chapter_id,
				has_support_processing_role
)

SELECT	i.*,
		wh.work_hours AS sc_hours
INTO	#Iterations
FROM	iterations_reduced AS i
		INNER JOIN #SCWorkHours AS wh ON	wh.emp_scid		= i.emp_scid 
										AND wh.year_month	= i.year_month

CREATE CLUSTERED INDEX idx ON #Iterations(emp_position_id, emp_chapter_id, has_support_processing_role, emp_crmid, year_month);
