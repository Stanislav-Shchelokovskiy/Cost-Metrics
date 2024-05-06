SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @emp1 			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @senior_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @now 			DATE = GETUTCDATE()

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,	tent_id, tent_name,	position_id,	position_name,	chapter_id,	level_id,	has_support_processing_role,	location_id,	hired_at,	retired_at,		retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,		NULL,	 NULL,		NULL,			NULL,			NULL,		NULL,		1,								@armenia,		NULL,		NULL,			0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		DATEADD(MONTH, -1,  @now),	'Position',			NULL,		NULL,		@senior_support,		NULL,				NULL,					NULL,		NULL		)
