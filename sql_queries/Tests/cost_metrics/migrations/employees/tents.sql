SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE CRMAudit
GO

--#### Tent_Employee ####
DECLARE @emp1   UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tent3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @tent4	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
INSERT INTO dxcrm.Tent_Employee (	Employee_Id,	Tent_Id,	EntityModified,				AuditAction	)
VALUES							(	@emp1, 			@tent1, 	'2023-06-04 11:54:44.340', 	0			),
								(	@emp1, 			@tent1, 	'2023-07-04 11:54:44.340', 	2			),
								(	@emp1, 			@tent2, 	'2023-07-05 11:54:44.340', 	0			),
								(	@emp1, 			@tent2, 	'2023-07-06 11:53:44.340', 	2			),
								(	@emp1, 			@tent3, 	'2023-08-06 11:54:44.340', 	3			),
								(	@emp1, 			@tent3, 	'2023-09-13 11:54:44.340', 	2			),
								(	@emp1, 			@tent2, 	'2023-11-05 11:54:44.340', 	0			)

USE DXStatisticsV2
GO

DECLARE @support_developer 	UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @middle_support 	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @armenia 			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @tribe1	    UNIQUEIDENTIFIER 	= '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) 		= 'tribe1'
DECLARE @chapter1   UNIQUEIDENTIFIER 	= '00000000-0000-0000-0000-000000000001'
DECLARE @emp1       UNIQUEIDENTIFIER 	= '00000000-0000-0000-0000-000000000001'
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,		retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@middle_support,	1,								@armenia,		'2023-05-04',	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	 Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,				RetiredAt	)
VALUES						(	@emp1,		'2022-09-04T08:50:17.43',	'Level',			@chapter1,	 @tribe1,	@support_developer,		@middle_support,	@armenia,				'2022-06-16T00:00:00',	NULL		)				
