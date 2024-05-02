SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

CREATE DATABASE CRM
CREATE DATABASE CRMAudit
CREATE DATABASE DXStatisticsV2
GO

USE CRM
GO

--#######################
--####### TRIBES ########
--#######################
CREATE TABLE Tribes (
	Id		UNIQUEIDENTIFIER,
	Name	VARCHAR(20)
)
INSERT INTO Tribes
VALUES	('00000000-0000-0000-0000-000000000001',	'tribe1')
--#######################
--######## TENTS ########
--#######################
CREATE TABLE Tents (
	Id		UNIQUEIDENTIFIER,
	Name	VARCHAR(20)
)

USE CRMAudit
GO

CREATE SCHEMA dxcrm
GO

--#### Tent_Employee ####
CREATE TABLE dxcrm.Tent_Employee (
	Employee_Id		UNIQUEIDENTIFIER,
	Tent_Id			UNIQUEIDENTIFIER,
	EntityModified	DATETIME,
	AuditAction		TINYINT
)

--##### Tribes Audit ####
CREATE TABLE dxcrm.Tribes (
	EntityModified	DATETIME,
	EntityOid		UNIQUEIDENTIFIER,
	Name			VARCHAR(20)
)

USE DXStatisticsV2
GO
--#######################
--###### POSITIONS ######
--#######################
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
CREATE TABLE Positions (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Positions
VALUES	(@support_developer,	'support_developer'	)
--######################
--####### LEVELS #######
--######################
DECLARE @senior_support UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
CREATE TABLE Levels (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Levels
VALUES	(@senior_support, 'senior_support' )
--######################
--##### LOCATIONS ######
--######################
DECLARE @philippines	UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @other			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @non_active		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'

DROP TABLE IF EXISTS Locations
CREATE TABLE Locations (
	id			UNIQUEIDENTIFIER PRIMARY KEY,
	name		VARCHAR(30),
	is_active	BIT
)
INSERT INTO Locations
VALUES	(@philippines,	'philippines',	1),
		(@armenia,		'armenia',		1),
		(@other,		'other',		1),
        (@non_active,   'non_active',   0)
--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @tribe1		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20)      = 'tribe1'
DECLARE @chapter1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @emp1 		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
CREATE TABLE Employees (
	crmid						UNIQUEIDENTIFIER,
	scid						UNIQUEIDENTIFIER,
	name						VARCHAR(20),
	tribe_id					UNIQUEIDENTIFIER,
	tribe_name					VARCHAR(20),
	tent_id						UNIQUEIDENTIFIER,
	tent_name					VARCHAR(20),
	position_id					UNIQUEIDENTIFIER,
	position_name				VARCHAR(20),
	chapter_id					UNIQUEIDENTIFIER,
	level_id					UNIQUEIDENTIFIER,
	has_support_processing_role	TINYINT,
	location_id					UNIQUEIDENTIFIER,
	hired_at					DATETIME,
	retired_at					DATETIME,
	retired						TINYINT,
	is_service_user				TINYINT
)
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,		retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@senior_support,	1,								@armenia,		'2023-05-04',	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
CREATE TABLE EmployeesAudit (
	EntityOid			UNIQUEIDENTIFIER,
	EntityModified		DATETIME,
	ChangedProperties	VARCHAR(50),
	Chapter_Id			UNIQUEIDENTIFIER,
	Tribe_Id			UNIQUEIDENTIFIER,
	EmployeePosition_Id	UNIQUEIDENTIFIER,
	EmployeeLevel_Id	UNIQUEIDENTIFIER,
	EmployeeLocation_id	UNIQUEIDENTIFIER,
	HiredAt				DATETIME,
	RetiredAt			DATETIME
)
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,				RetiredAt	)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Level',			@chapter1,	@tribe1,	@support_developer, 	@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL		),
    						(	@emp1,		'2022-09-06T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@philippines,			'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,	    @senior_support,	@other,	    			'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-11-05T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@non_active,			'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-12-15T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,	    @senior_support,	@philippines,			'2022-06-16T00:00:00',	NULL		),
							(	@emp1,		'2022-12-16T08:50:17.43',	'Location',			@chapter1,	@tribe1,	@support_developer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL		)
--#################################
--####### EmployeesSalaries #######
--#################################
DECLARE @before_oct_2022	TINYINT = 0
DECLARE @after_oct_2022		TINYINT = 1
DECLARE @not_applicable		TINYINT = 2
DECLARE @usd CHAR(3) = 'USD'
CREATE TABLE EmployeesSalaries (
	level_num			TINYINT,
	probable_level_num	TINYINT NULL,
	level_id			UNIQUEIDENTIFIER,
	location_id			UNIQUEIDENTIFIER,
	value				INT,
	currency			CHAR(3),
	period				TINYINT,
	level_value			FLOAT,
)
CREATE CLUSTERED INDEX idx ON EmployeesSalaries(level_id, location_id);
INSERT INTO EmployeesSalaries
VALUES	(6, 6,		@senior_support,		@armenia,		1800,	@usd, @before_oct_2022,	5.5),
        (6, 6,		@senior_support,		@armenia,		1800,	@usd, @after_oct_2022,	5.5),
        (6, 6,		@senior_support,		@philippines,	1900,	@usd, @not_applicable,	5.5),
		(6, 6,		@senior_support,		@other,			2000,	@usd, @after_oct_2022,	5.5)
--#########################################
--####### EmployeesOperatingExpenses ######
--#########################################
DECLARE @null_date	DATE = '1990-01-01'
CREATE TABLE EmployeesOperatingExpenses (
	location_id			UNIQUEIDENTIFIER,
	actual_since		DATE,
	value_usd			FLOAT
)
--#########################################
--######## EmployeesTaxCoefficients #######
--#########################################
CREATE TABLE EmployeesTaxCoefficients (
	location_id		UNIQUEIDENTIFIER,
	actual_since	DATE,
	salary			FLOAT,
	self_employed	TINYINT,
	value			FLOAT
)
CREATE CLUSTERED INDEX idx ON EmployeesTaxCoefficients(location_id, actual_since, self_employed, salary)
INSERT INTO EmployeesTaxCoefficients
VALUES	(@armenia, '2021-12-01', 0, 0, 1.31)
--#####################################
--####### EmployeesSelfEmployed #######
--#####################################
DROP TABLE IF EXISTS EmployeesSelfEmployed
CREATE TABLE EmployeesSelfEmployed (
	crmid	UNIQUEIDENTIFIER
)
GO
--#######################
--######## ITVFs ########
--#######################
CREATE OR ALTER FUNCTION round_to_nearest_month(@dt DATETIME) RETURNS DATE AS
    BEGIN
        RETURN IIF( DAY(@dt) > 15,
                DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@dt), MONTH(@dt), 1)),
                DATEFROMPARTS(YEAR(@dt), MONTH(@dt), 1))
    END
GO

CREATE OR ALTER FUNCTION parse_employees(@json VARCHAR(MAX)) RETURNS TABLE AS
	RETURN (
		SELECT  *
		FROM	Employees
	)
GO
CREATE OR ALTER FUNCTION parse_employees_audit(@json VARCHAR(MAX)) RETURNS TABLE AS
	RETURN (
		SELECT  *
		FROM EmployeesAudit	
    )
GO
CREATE OR ALTER FUNCTION parse_positions(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
    FROM   Positions
)
GO
CREATE OR ALTER FUNCTION parse_locations(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
    SELECT  *
    FROM    Locations
)
GO
CREATE OR ALTER FUNCTION parse_levels(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
    FROM   Levels
				
)
GO
