DECLARE @json VARCHAR(MAX) = N'{employees_audit_json}'

DROP TABLE IF EXISTS #EmployeesAudit;

SELECT 	*
INTO 	#EmployeesAudit
FROM 	DXStatisticsV2.dbo.parse_employees_audit(@json)

CREATE CLUSTERED INDEX idx ON #EmployeesAudit(EntityOid)
