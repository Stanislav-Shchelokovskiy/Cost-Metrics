SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @support_developer_ph	UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @chapter_leader			UNIQUEIDENTIFIER = '945FDE96-987B-4608-85F4-7393F00D341B'
DECLARE @tribe_leader			UNIQUEIDENTIFIER = '0CF0BDBA-7DE3-4A06-9493-8F90720526B7'

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @emp1 			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @senior_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,	position_name,	chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,	retired_at,	retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,			NULL,		NULL,		NULL,			NULL,			NULL,		@senior_support,	1,								@armenia,		NULL,		NULL,		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Position',			NULL,		NULL,		@support_developer,		NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Position',			NULL,		NULL,		@chapter_leader,		NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-10-15T08:50:17.43',	'Position',			NULL,		NULL,		@tribe_leader,	    	NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-11-15T08:50:17.43',	'Position',			NULL,		NULL,		@support_developer,		NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2022-11-16T08:50:17.43',	'Position',			NULL,		NULL,		@support_developer_ph,	NULL,				NULL,					NULL,		NULL		),
							(	@emp1,		'2023-01-16T08:50:17.43',	'Position',			NULL,		NULL,		@chapter_leader,		NULL,				NULL,					NULL,		NULL		)
