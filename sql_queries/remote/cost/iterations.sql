DECLARE @json   VARCHAR(MAX) = N'{employees_json}'
DECLARE @start	DATE = '{start}'
DECLARE @end	DATE = '{end}'

DROP TABLE IF EXISTS #IterationsRaw;

SELECT	emp_scid        AS emp_scid,
        tribe_id        AS tribe_id,
        tribe_name	AS tribe_name,
        tent_id		AS tent_id,
        tent_name	AS tent_name,
        ticket_scid     AS ticket_scid,
        post_id         AS post_id,
        DATEFROMPARTS(YEAR(post_created), MONTH(post_created), 1) AS year_month
INTO    #IterationsRaw
FROM    DXStatisticsV2.dbo.get_iterations(@start, @end, @employees)

CREATE CLUSTERED INDEX idx ON #IterationsRaw(emp_scid, year_month, tribe_id, tent_id)
