DECLARE @json VARCHAR(MAX) = N'{employees_audit_json}'
DROP TABLE IF EXISTS #EmployeesAudit;
SELECT *
INTO #EmployeesAudit
FROM OPENJSON(@json)
	WITH (
		EntityOid			UNIQUEIDENTIFIER	'strict $.entityOid',
		EntityModified		DATETIME			'strict $.entityModified',
		ChangedProperties	NVARCHAR(1300)		'strict $.changedProperties',
		Chapter_Id			UNIQUEIDENTIFIER	'strict $.chapterId',
		Tribe_Id			UNIQUEIDENTIFIER	'strict $.tribeId',
		--tent_id			UNIQUEIDENTIFIER	'strict $.id',
		--squad_id			UNIQUEIDENTIFIER	'strict $.squadId',
		EmployeePosition_Id	UNIQUEIDENTIFIER	'strict $.employeePositionId',
		EmployeeLevel_Id	UNIQUEIDENTIFIER	'strict $.employeeLevelId',
		EmployeeLocation_id	UNIQUEIDENTIFIER	'strict $.employeeLocationId',
		HiredAt				DATE				'strict $.hiredAt',
		RetiredAt 			DATE 				'strict $.retiredAt'
	)