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
VALUES	('00000000-0000-0000-0000-000000000001',	'tribe1')
--#######################
--######## TENTS ########
--#######################
DROP TABLE IF EXISTS Tents;
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
DECLARE @support_developer_ph UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
CREATE TABLE Positions (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Positions
VALUES	(@support_developer_ph, 'support_developer_ph')
--######################
--####### LEVELS #######
--######################
DECLARE @junior1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @junior2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @junior3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @junior4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @middle2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
CREATE TABLE Levels (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
INSERT INTO Levels
VALUES	(@junior1, 'junior1' ),
		(@junior2, 'junior2' ),
		(@junior3, 'junior3' ),
		(@junior4, 'junior4' ),
		(@middle1, 'middle1' ),
		(@middle2, 'middle2' )
--######################
--##### LOCATIONS ######
--######################
DECLARE @philippines UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
CREATE TABLE Locations (
	id			UNIQUEIDENTIFIER PRIMARY KEY,
	name		VARCHAR(30),
	is_active	BIT
)
INSERT INTO Locations
VALUES	(@philippines, 'philippines', 1)

--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @now 		DATE = GETUTCDATE()
DECLARE @hired_at 	DATETIME = DATEADD(MONTH, -12,  @now)

DECLARE @tribe1		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) 	 = 'tribe1'
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
INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,			position_name,			chapter_id,	level_id, has_support_processing_role,	location_id,	hired_at,	retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe1,	@tribe1Name,	NULL,		NULL,		@support_developer_ph,	'support_developer_ph',	@chapter1,	@middle2, 1,							@philippines,	@hired_at,	CAST(NULL AS DATE),		0,			0				)
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
INSERT INTO	EmployeesAudit	(	EntityOid,	EntityModified,				ChangedProperties,	Chapter_Id,	Tribe_Id,	EmployeePosition_Id,	EmployeeLevel_Id,	EmployeeLocation_id,	HiredAt,	RetiredAt	)
VALUES						(	@emp1,		DATEADD(MONTH, -3, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@junior4,			@philippines,			@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -2, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@middle1,			@philippines,			@hired_at,	NULL		),
							(	@emp1,		DATEADD(MONTH, -1, @now),	'Level',			@chapter1,	@tribe1,	@support_developer_ph,	@middle2,			@philippines,			@hired_at,	NULL		)
--#################################
--####### EmployeesSalaries #######
--#################################
DECLARE @not_applicable	TINYINT = 2
DECLARE @php 			CHAR(3) = 'PHP'

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
INSERT INTO EmployeesSalaries
VALUES	(1,	1, @junior1, @philippines, 30500, @php, @not_applicable, 3	),
		(2,	2, @junior2, @philippines, 36000, @php, @not_applicable, 3	),
		(3,	3, @junior3, @philippines, 42500, @php, @not_applicable, 4	),
		(4,	4, @junior4, @philippines, 48000, @php, @not_applicable, 4	),
		(5,	5, @middle1, @philippines, 58000, @php, @not_applicable, 5	),
		(6,	6, @middle2, @philippines, 65000, @php, @not_applicable, 6	)

CREATE CLUSTERED INDEX idx ON EmployeesSalaries(level_id, location_id)
CREATE NONCLUSTERED INDEX idx_missing_level ON EmployeesSalaries(period, probable_level_num) INCLUDE(level_id) WHERE EmployeesSalaries.probable_level_num IS NOT NULL
CREATE NONCLUSTERED INDEX idx_probable_level_num ON EmployeesSalaries(probable_level_num) WHERE EmployeesSalaries.probable_level_num IS NOT NULL
--#########################################
--####### EmployeesOperatingExpenses ######
--#########################################
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
