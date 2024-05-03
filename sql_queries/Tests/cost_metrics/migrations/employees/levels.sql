SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle_dev			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'

DECLARE @tribe1				UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name 		VARCHAR(20) 	 = 'tribe1'
DECLARE @chapter1			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp1 				UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @armenia			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @support_developer	UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'

--#######################
--##### EMPLOYEES #######
--#######################
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,		retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@middle_support,	1,								@armenia,		'2023-05-04',	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,				RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@trainee_support,	@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@middle_dev,		@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-10-15T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@middle_support,	@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-11-15T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@middle_dev,		@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-11-16T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@middle_support,	@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-12-16T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL		)
