SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @chapter1					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @chapter2					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @support_developers_chapter UNIQUEIDENTIFIER = '29B6E93D-8644-4977-9010-983076353DC6'

DECLARE @emp1 						UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @middle_support				UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @armenia					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @support_developer			UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'

--#######################
--##### EMPLOYEES #######
--#######################
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,		retired_at,		retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,			NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@middle_support,	1,								@armenia,		NULL,			NULL,			0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,						Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Chapter',			@chapter1,						NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Chapter',			@chapter2,						NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
                            (	@emp1,		'2022-10-15T08:50:17.43',	'Chapter',			@support_developers_chapter,	NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-11-15T08:50:17.43',	'Chapter',			@chapter2,						NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-11-16T08:50:17.43',	'Chapter',			@chapter1,						NULL,		NULL,					NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2023-01-16T08:50:17.43',	'Chapter',			@chapter2,						NULL,		NULL,					NULL,				NULL,					NULL,		NULL		)
