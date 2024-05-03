SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @junior1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000011'
DECLARE @junior2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000022'
DECLARE @junior3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000033'
DECLARE @junior4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000044'
DECLARE @middle1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000055'
DECLARE @middle2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000066'

DECLARE @support_developer_ph UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'

DECLARE @philippines UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @now 		DATE = GETUTCDATE()
DECLARE @hired_at 	DATETIME = DATEADD(MONTH, -12,  @now)

DECLARE @tribe1		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) 	 = 'tribe1'
DECLARE @chapter1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp1 		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,			position_name,			chapter_id,	level_id, has_support_processing_role,	location_id,	hired_at,	retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer_ph,	'support_developer_ph',	@chapter1,	@middle2, 1,							@philippines,	@hired_at,	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		DATEADD(MONTH, -3, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@junior4,			@philippines,			@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -2, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@middle1,			@philippines,			@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -1, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@middle2,			@philippines,			@hired_at,	NULL		)
