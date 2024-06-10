SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @emp1 				UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

DECLARE @armenia			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @estonia			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @other				UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @non_active			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'

DECLARE @support_developer	UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
--#######################
--##### EMPLOYEES #######
--#######################
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,	tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,	retired_at,	retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,		NULL,		NULL,		@support_developer,	'support_developer',	NULL,		@senior_support,	1,								@armenia,		NULL,		NULL,		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Location',			NULL,		NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Location',			NULL,		NULL,		NULL,					NULL,				@armenia,				NULL,		NULL		),
							(	@emp1,		'2022-10-15T08:50:17.43',	'Location',			NULL,		NULL,		NULL,				    NULL,				@other,	    			NULL,		NULL		),
							(	@emp1,		'2022-11-15T08:50:17.43',	'Location',			NULL,		NULL,		NULL,					NULL,				@non_active,			NULL,		NULL		),
							(	@emp1,		'2022-11-16T08:50:17.43',	'Location',			NULL,		NULL,		NULL,				    NULL,				@estonia,				NULL,		NULL		),
							(	@emp1,		'2023-01-16T08:50:17.43',	'Location',			NULL,		NULL,		NULL,					NULL,				@armenia,				NULL,		NULL		)
