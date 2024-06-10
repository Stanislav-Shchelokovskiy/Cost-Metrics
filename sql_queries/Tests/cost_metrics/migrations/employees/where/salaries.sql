SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO


DECLARE @middle2                UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000066'
DECLARE @trainee_support	    UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @middle_support		    UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @support_developer_ph   UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @support_developer	    UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @philippines            UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
DECLARE @armenia		        UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @now 		DATE = GETUTCDATE()
DECLARE @hired_at 	DATETIME = '2022-08-01'
DECLARE @emp1 		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp2 		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,			position_name,			chapter_id,	level_id,           has_support_processing_role,	location_id,	hired_at,	retired_at,		retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,			NULL,		NULL,		@support_developer_ph,	'support_developer_ph',	NULL,		@middle2,           1,							    @philippines,	@hired_at,	NULL,			0,			0				),
                        (	@emp2,	@emp2,	'emp2',	NULL,		NULL,		    NULL,	    NULL,		@support_developer,	    'support_developer',	NULL,		@middle_support,	1,								@armenia,		@hired_at,  NULL,			0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Level',			NULL,		NULL,		NULL,		            @middle2,	        NULL,					NULL,		NULL		),
							(	@emp2,		'2022-10-14T08:50:17.43',	'Level',			NULL,		NULL,		NULL,		            @trainee_support,	NULL,					NULL,		NULL		),
							(	@emp2,		'2022-10-15T08:50:17.43',	'Level',			NULL,		NULL,		NULL,		            @middle_support,	NULL,					NULL,		NULL		)
							