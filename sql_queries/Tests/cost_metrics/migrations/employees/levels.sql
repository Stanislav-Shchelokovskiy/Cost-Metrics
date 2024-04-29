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
DROP TABLE IF EXISTS Tribes;
CREATE TABLE Tribes (
	Id		UNIQUEIDENTIFIER,
	Name	VARCHAR(20)
)
INSERT INTO Tribes
VALUES	('00000000-0000-0000-0000-000000000001',	'tribe1'),
		('00000000-0000-0000-0000-000000000002',	'tribe2')
--#######################
--######## TENTS ########
--#######################
DROP TABLE IF EXISTS Tents;
CREATE TABLE Tents (
	Id		UNIQUEIDENTIFIER,
	Name	VARCHAR(20)
)
INSERT INTO Tents
VALUES	('00000000-0000-0000-0000-000000000001',	'tent1'),
		('00000000-0000-0000-0000-000000000002',	'tent2'),
		('00000000-0000-0000-0000-000000000003',	'tent3')


USE CRMAudit
GO

CREATE SCHEMA dxcrm
GO

DECLARE @tent1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tent3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'

DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

--#### Tent_Employee ####
CREATE TABLE dxcrm.Tent_Employee (
	Employee_Id		UNIQUEIDENTIFIER,
	Tent_Id			UNIQUEIDENTIFIER,
	EntityModified	DATETIME,
	AuditAction		TINYINT
)
INSERT INTO dxcrm.Tent_Employee
VALUES	(@emp1, @tent1, '2023-05-04 11:54:44.340', 2),
		(@emp1, @tent2, '2023-05-05 11:54:44.340', 3),
		(@emp1, @tent2, '2023-05-06 11:53:44.340', 2),
		(@emp1, @tent3, '2023-05-06 11:54:44.340', 3),
		(@emp1, @tent3, '2023-05-13 11:54:44.340', 2)

--##### Tribes Audit ####
CREATE TABLE dxcrm.Tribes (
	EntityModified	DATETIME,
	EntityOid		UNIQUEIDENTIFIER,
	Name			VARCHAR(20)
)
INSERT INTO dxcrm.Tribes
VALUES	('2023-04-07 11:53:44.340', '00000000-0000-0000-0000-000000000003', 'tribe3')


USE DXStatisticsV2
GO
--#######################
--###### POSITIONS ######
--#######################
DECLARE @support_developer_ph	UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @chapter_leader			UNIQUEIDENTIFIER = '945FDE96-987B-4608-85F4-7393F00D341B'
DECLARE @tribe_leader			UNIQUEIDENTIFIER = '0CF0BDBA-7DE3-4A06-9493-8F90720526B7'
DECLARE @pm						UNIQUEIDENTIFIER = '835B63C4-D357-497A-A184-3F4FEAAA2AA7'
DECLARE @principal_pm			UNIQUEIDENTIFIER = 'E8D90D9A-4C9D-45A6-A828-02CD6FA14924'
DECLARE @developer				UNIQUEIDENTIFIER = '5739E91C-83AE-46CB-A9A0-32517CB1BAAA'
DECLARE @technical_writer		UNIQUEIDENTIFIER = '4D017739-BA85-4C71-AEFD-1B7098BE81A2'
DECLARE @squad_leader			UNIQUEIDENTIFIER = '520C9118-F21C-4B49-B937-A5ED2806B10C'

CREATE TABLE Positions (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Positions
VALUES	(@support_developer_ph,	'support_developer_ph'	),
		(@support_developer,	'support_developer'		),
		(@chapter_leader,		'chapter_leader'		),
		(@tribe_leader,			'tribe_leader'			),
		(@pm,					'pm'					),
		(@principal_pm,			'principal_pm'			),
		(@developer,			'developer'				),
		(@technical_writer,		'technical_writer'		),
		(@squad_leader,			'squad_leader'			)
--######################
--####### LEVELS #######
--######################
DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle_dev			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'

CREATE TABLE Levels (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Levels
VALUES	(@trainee_support,	'trainee_support'	),
		(@middle_support,	'middle_support'	),
		(@middle_dev,		'middle_dev'		),
		(@senior_support,	'senior_support'	)
--######################
--##### LOCATIONS ######
--######################
DECLARE @philippines	UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @other			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @non_active		UNIQUEIDENTIFIER = NULL

CREATE TABLE Locations (
	id			UNIQUEIDENTIFIER PRIMARY KEY,
	name		VARCHAR(30),
	is_active	BIT
)
INSERT INTO Locations
VALUES	(@philippines,	'philippines',	1),
		(@armenia,		'armenia',		1),
		(@other,		'other',		1)

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @tribe1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) = 'tribe1'
DECLARE @tribe2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tribe2Name VARCHAR(20) = 'tribe2'
DECLARE @tribe3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @tribe3Name VARCHAR(20) = 'tribe3'

DECLARE @chapter1					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @chapter2					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @support_developers_chapter UNIQUEIDENTIFIER = '29B6E93D-8644-4977-9010-983076353DC6'

DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

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
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe2,	@tribe2Name,	NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@middle_support,	1,								@armenia,		'2023-05-04',	CAST(NULL AS DATE),		0,			0				)
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
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,						Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,				RetiredAt					)
VALUES						(	@emp1,		'2022-09-05T08:50:17.43',	'Level',			@chapter1,						@tribe1,	@support_developer_ph,	@trainee_support,	@philippines,			'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Level',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-14T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@tribe_leader,			@middle_dev,		@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-11-05T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@support_developer,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-12-07T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@developer,				@middle_dev,		@armenia,				'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-12-27T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@technical_writer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL						)
--#################################
--####### EmployeesSalaries #######
--#################################
DECLARE @before_oct_2022	TINYINT = 0
DECLARE @after_oct_2022		TINYINT = 1
DECLARE @not_applicable		TINYINT = 2

DECLARE @php CHAR(3) = 'PHP'
DECLARE @usd CHAR(3) = 'USD'
DECLARE @eur CHAR(3) = 'EUR'

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
VALUES	(1, 1,		@trainee_support,		@armenia,		900,	@usd, @after_oct_2022,	3),
		(1, NULL,	@trainee_support,		@other,			1000,	@usd, @after_oct_2022,	3),
		(1, 1,		@trainee_support,		NULL,			1100,	@usd, @before_oct_2022,	3),

		(5, 5,		@middle_support,		@armenia,		1200,	@usd, @after_oct_2022,	5),
		(5, 5,		@middle_support,		@other,			1300,	@usd, @after_oct_2022,	5),
		(5, 5,		@middle_support,		NULL,			1400,	@usd, @before_oct_2022,	5),

		(5, 5,		@middle_dev,			@armenia,		1500,	@usd, @after_oct_2022,	5),
		(5, 5,		@middle_dev,			@other,			1600,	@usd, @after_oct_2022,	5),
		(5, 5,		@middle_dev,			NULL,			1700,	@usd, @before_oct_2022,	5),

		(6, 6,		@senior_support,		@armenia,		1800,	@usd, @after_oct_2022,	5.5),
		(6, 6,		@senior_support,		@other,			1900,	@usd, @after_oct_2022,	5.5),
		(6, 6,		@senior_support,		NULL,			2000,	@usd, @before_oct_2022,	5.5)
--#########################################
--####### EmployeesOperatingExpenses ######
--#########################################
DECLARE @null_date	DATE = '1990-01-01'

CREATE TABLE EmployeesOperatingExpenses (
	location_id			UNIQUEIDENTIFIER,
	actual_since		DATE,
	value_usd			FLOAT
)
CREATE CLUSTERED INDEX idx ON EmployeesOperatingExpenses(location_id, actual_since)
INSERT INTO EmployeesOperatingExpenses
VALUES	(@philippines,	@null_date,	2000),
		(@armenia,		@null_date,	2200),
		(@other,		@null_date,	2200)

--#########################################
--######## EmployeesTaxCoefficients #######
--#########################################
DECLARE @new_life_start		DATE = '2022-10-01'
DECLARE @relocation_date	DATE = '2022-03-01'

CREATE TABLE EmployeesTaxCoefficients (
	location_id		UNIQUEIDENTIFIER,
	actual_since	DATE,
	salary			FLOAT,
	self_employed	TINYINT,
	value			FLOAT
)
CREATE CLUSTERED INDEX idx ON EmployeesTaxCoefficients(location_id, actual_since, self_employed, salary)
INSERT INTO EmployeesTaxCoefficients
VALUES	(@other,		@null_date,			0,		0,	1.078	),
		(@philippines,	@null_date,			0,		0,	1.06	),
		(@armenia,		'2021-12-01',		0,		0,	1.31	)
--#####################################
--####### EmployeesSelfEmployed #######
--#####################################
DROP TABLE IF EXISTS EmployeesSelfEmployed
CREATE TABLE EmployeesSelfEmployed (
	crmid	UNIQUEIDENTIFIER
)
INSERT INTO EmployeesSelfEmployed
VALUES	('00000000-0000-0000-0000-000000000004')
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