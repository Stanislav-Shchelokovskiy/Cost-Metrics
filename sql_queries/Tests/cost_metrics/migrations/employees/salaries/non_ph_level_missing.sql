SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @junior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000007'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'

DECLARE @support_developer	UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'

DECLARE @armenia			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @now 		DATE = GETUTCDATE()
DECLARE @hired_at 	DATETIME = DATEADD(MONTH, -8,  @now)

DECLARE @tribe1		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) 	 = 'tribe1'
DECLARE @chapter1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp1 		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,		 chapter_id,	level_id, 		 has_support_processing_role,	location_id,	hired_at,	retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer,	'support_developer', @chapter1,		@senior_support, 1,								@armenia,		@hired_at,	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		DATEADD(MONTH, -3, @now),	'Level',			@chapter1,	@tribe1,	@support_developer,		@junior_support,	@armenia,				@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -2, @now),	'Level',			@chapter1,	@tribe1,	@support_developer,		@middle_support,	@armenia,				@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -1, @now),	'Level',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@armenia,				@hired_at,	NULL		)
