SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @emp1 		        UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp2 		        UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @senior_support     UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
DECLARE @support_developer	UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @armenia		    UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @now 			    DATE = GETUTCDATE()

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,	tent_id, tent_name,	position_id,	    position_name,	        chapter_id,	level_id,	        has_support_processing_role,	location_id,	hired_at,	retired_at,		retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	NULL,		NULL,		NULL,	 NULL,		@support_developer,	'support_developer',	NULL,		@senior_support,	1,								@armenia,		NULL,		NULL,			0,			0				),
                        (	@emp2,	@emp2,	'emp2',	NULL,		NULL,		NULL,	 NULL,		NULL,			    NULL,			        NULL,		@senior_support,	1,								@armenia,		NULL,		NULL,			0,			0				)
