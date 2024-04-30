SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

CREATE DATABASE CRM
GO

CREATE DATABASE DXStatisticsV2
GO

CREATE DATABASE CRMAudit
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

--#######################
--#### Tent_Employee ####
--#######################
DECLARE @tent1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tent3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'

DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DROP TABLE IF EXISTS dxcrm.Tent_Employee;
CREATE TABLE dxcrm.Tent_Employee (
	Employee_Id		UNIQUEIDENTIFIER,
	Tent_Id			UNIQUEIDENTIFIER,
	EntityModified	DATETIME,
	AuditAction		TINYINT
)
INSERT INTO dxcrm.Tent_Employee
VALUES	(@emp1, @tent1, '2023-06-04 11:54:44.340', 0),
        (@emp1, @tent1, '2023-07-04 11:54:44.340', 2),
		(@emp1, @tent2, '2023-07-05 11:54:44.340', 0),
		(@emp1, @tent2, '2023-07-06 11:53:44.340', 2),
		(@emp1, @tent3, '2023-08-06 11:54:44.340', 3)

--#######################
--##### Tribes Audit ####
--#######################
DROP TABLE IF EXISTS dxcrm.Tribes
CREATE TABLE dxcrm.Tribes (
	EntityModified	DATETIME,
	EntityOid		UNIQUEIDENTIFIER,
	Name			VARCHAR(20)
)
INSERT INTO dxcrm.Tribes
VALUES	('2023-04-07 11:53:44.340', '00000000-0000-0000-0000-000000000003', 'tribe3')

--#######################
--#######################
USE DXStatisticsV2
GO
--#######################
--#######################
--####### HELPERS #######
--#######################
CREATE SEQUENCE PostCounter AS INT START WITH 1  INCREMENT BY 1; 
GO
CREATE OR ALTER FUNCTION round_to_nearest_month(@dt DATETIME) RETURNS DATE AS
BEGIN
    RETURN IIF( DAY(@dt) > 15,
                DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@dt), MONTH(@dt), 1)),
                DATEFROMPARTS(YEAR(@dt), MONTH(@dt), 1))
END
GO
CREATE OR ALTER PROCEDURE update_employees_sc_work_hours(@start DATE, @end DATE, @employees_json VARCHAR(MAX), @employees_audit_json VARCHAR(MAX)) AS 
BEGIN
	PRINT 'update_employees_sc_work_hours'
END
GO
CREATE OR ALTER FUNCTION dbo.get_working_days(@start_date DATE, @end_date DATE) RETURNS INT AS
BEGIN
        DECLARE @saturday       TINYINT = 7
        DECLARE @sunday         TINYINT= 1

        DECLARE @diff_days      INT = DATEDIFF(DAY, @start_date, @end_date)
        DECLARE @start_day      INT = DATEPART(WEEKDAY, @start_date)
        DECLARE @end_day        INT = DATEPART(WEEKDAY, @end_date)

        IF @start_day IN (@saturday, @sunday) AND @end_day IN (@saturday, @sunday)
                RETURN 0

        DECLARE @increment TINYINT = 0

        IF      (@diff_days = 2 AND @end_day = @sunday)
                OR (@diff_days > 7 AND @end_day IN (@saturday, @sunday))
                SET @increment = 1

        RETURN (SELECT  (@diff_days + @increment + IIF(@start_day = @saturday, 1, 0))
                                        -(DATEDIFF(WEEK, @start_date, @end_date) * 2)
                                        -(CASE WHEN @start_day = @sunday   THEN 1 ELSE 0 END)
                                        -(CASE WHEN @start_day = @saturday THEN 1 ELSE 0 END))
END
GO
--#####################################
--####### EmployeesSelfEmployed #######
--#####################################
DROP TABLE IF EXISTS EmployeesSelfEmployed
CREATE TABLE EmployeesSelfEmployed (
	crmid	UNIQUEIDENTIFIER
)
INSERT INTO EmployeesSelfEmployed
VALUES	('00000000-0000-0000-0000-000000000004')
--######################
--####### LEVELS #######
--######################
DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle_dev			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'

DROP TABLE IF EXISTS Levels
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

DROP TABLE IF EXISTS Locations
CREATE TABLE Locations (
	id			UNIQUEIDENTIFIER PRIMARY KEY,
	name		VARCHAR(30),
	is_active	BIT
)
INSERT INTO Locations
VALUES	(@philippines,	'philippines',	1),
		(@armenia,		'armenia',		1),
		(@other,		'other',		1)
--#################################
--####### EmployeesSalaries #######
--#################################
DECLARE @before_oct_2022	TINYINT = 0
DECLARE @after_oct_2022		TINYINT = 1
DECLARE @not_applicable		TINYINT = 2

DECLARE @php CHAR(3) = 'PHP'
DECLARE @usd CHAR(3) = 'USD'
DECLARE @eur CHAR(3) = 'EUR'

DROP TABLE IF EXISTS EmployeesSalaries
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

DROP TABLE IF EXISTS EmployeesOperatingExpenses
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

DROP TABLE IF EXISTS EmployeesTaxCoefficients
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

--#######################
--##### SCWorkHours #####
--#######################
DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

DROP TABLE IF EXISTS dbo.EmployeesSCWorkHours
CREATE TABLE dbo.EmployeesSCWorkHours (
	scid		UNIQUEIDENTIFIER,
	date		DATE,
	work_hours	FLOAT
)
INSERT INTO dbo.EmployeesSCWorkHours
VALUES	(@emp1, '2022-09-01', 8),
		(@emp1, '2022-09-02', 3.4),
		(@emp1, '2022-09-05', 6.5),
		(@emp1, '2022-09-06', 0),
		(@emp1, '2022-09-07', 5),

		(@emp1, '2022-10-03', 8),
		(@emp1, '2022-10-04', 3.4),
		(@emp1, '2022-10-05', 6.5),
		(@emp1, '2022-10-06', 10),
		(@emp1, '2022-10-07', 5),

		(@emp1, '2022-11-03', 8),
		(@emp1, '2022-11-04', 10),
		(@emp1, '2022-11-07', 11),
		(@emp1, '2022-11-08', 10),
		(@emp1, '2022-11-09', 5),

		(@emp1, '2022-12-01', 8),
		(@emp1, '2022-12-02', 10),
		(@emp1, '2022-12-05', 11),
		(@emp1, '2022-12-06', 10),
		(@emp1, '2022-12-07', 5),

		(@emp1, '2023-01-02', 8),
		(@emp1, '2023-01-03', 10),
		(@emp1, '2023-01-04', 11),
		(@emp1, '2023-01-05', 10),
		(@emp1, '2023-01-06', 5),

		(@emp1, '2023-02-03', 8),
		(@emp1, '2023-02-06', 10),
		(@emp1, '2023-02-07', 11),

		(@emp1, '2023-05-03', 8),
		(@emp1, '2023-05-04', 10),
		(@emp1, '2023-05-05', 11),
		(@emp1, '2023-05-08', 10),
		(@emp1, '2023-05-09', 5),

		(@emp1, '2023-06-03', 9),
		(@emp1, '2023-06-04', 10),
		(@emp1, '2023-06-05', 11),
		(@emp1, '2023-06-08', 12),
		(@emp1, '2023-06-09', 5),

		(@emp1, '2023-07-03', 8),
		(@emp1, '2023-07-04', 10),
		(@emp1, '2023-07-05', 11),
		(@emp1, '2023-07-06', 10),
		(@emp1, '2023-07-07', 5),
		(@emp1, '2023-07-10', 8),
		(@emp1, '2023-07-11', 11),
		(@emp1, '2023-07-12', 8),
		(@emp1, '2023-07-13', 9),
		(@emp1, '2023-07-14', 9),
		(@emp1, '2023-07-17', 9),
		(@emp1, '2023-07-18', 11),
		(@emp1, '2023-07-19', 9),
		(@emp1, '2023-07-20', 11),
		(@emp1, '2023-07-21', 9),
		(@emp1, '2023-07-24', 11),
		(@emp1, '2023-07-25', 11),
		(@emp1, '2023-07-26', 9),
		(@emp1, '2023-07-27', 11),
		(@emp1, '2023-07-28', 9),
		(@emp1, '2023-07-31', 9)
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
DROP TABLE IF EXISTS Positions
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
--#######################
--###### ITERATIONS #####
--#######################
DECLARE @tribe1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tribe1Name VARCHAR(20) = 'tribe1'
DECLARE @tribe2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tribe2Name VARCHAR(20) = 'tribe2'
DECLARE @tribe3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @tribe3Name VARCHAR(20) = 'tribe3'

DECLARE @tent1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent1Name VARCHAR(20) = 'tent1'
DECLARE @tent2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tent2Name VARCHAR(20) = 'tent2'
DECLARE @tent3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @tent3Name VARCHAR(20) = 'tent3'

DROP TABLE IF EXISTS Iterations
CREATE TABLE Iterations(
	emp_scid		UNIQUEIDENTIFIER,
	ticket_scid		INT,
	tribe_id		UNIQUEIDENTIFIER,
	post_id			INT DEFAULT (NEXT VALUE FOR PostCounter),
	tribe_name		VARCHAR(20),
	tent_id			UNIQUEIDENTIFIER,
	tent_name		VARCHAR(20),
	post_created	DATETIME,
	iteration_start	DATETIME,
	iteration_end	DATETIME
)
INSERT INTO Iterations	(emp_scid,	ticket_scid,	tribe_id,	tribe_name,		tent_id,	tent_name,	post_created,				iteration_start,			iteration_end				)
VALUES					(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-09-01 07:54:44.340', '2022-09-02 06:53:44.340',	'2022-09-02 07:54:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-09-02 08:49:44.340', '2022-09-02 07:49:57.957',	'2022-09-02 08:49:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-09-05 11:19:44.340', '2022-09-02 08:49:57.957',	'2022-09-02 11:19:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-09-06 12:17:44.340', '2022-09-02 09:49:57.957',	'2022-09-02 12:17:44.340'	),
						(@emp1,		3,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-09-07 13:23:44.340', '2022-09-02 10:49:57.957',	'2022-09-02 13:23:44.340'	),

						(@emp1,		1,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-10-03 07:54:44.340', '2022-10-03 06:53:44.340',	'2022-10-03 07:54:44.340'	),
						(@emp1,		2,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-10-04 08:49:44.340', '2022-10-04 07:49:57.957',	'2022-10-04 08:49:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-10-05 11:19:44.340', '2022-10-05 08:49:57.957',	'2022-10-05 11:19:44.340'	),
						(@emp1,		4,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-10-06 12:17:44.340', '2022-10-06 09:49:57.957',	'2022-10-06 12:17:44.340'	),
						(@emp1,		4,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-10-07 13:23:44.340', '2022-10-07 10:49:57.957',	'2022-10-07 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-11-03 07:54:44.340', '2022-11-03 06:53:44.340',	'2022-11-03 07:54:44.340'	),
						(@emp1,		2,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-11-04 08:49:44.340', '2022-11-04 07:49:57.957',	'2022-11-04 08:49:44.340'	),
						(@emp1,		3,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-11-07 11:19:44.340', '2022-11-07 08:49:57.957',	'2022-11-07 11:19:44.340'	),
						(@emp1,		4,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-11-08 12:17:44.340', '2022-11-08 09:49:57.957',	'2022-11-08 12:17:44.340'	),
						(@emp1,		5,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2022-11-09 13:23:44.340', '2022-11-09 10:49:57.957',	'2022-11-09 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-12-01 07:54:44.340', '2022-12-01 06:53:44.340',	'2022-12-01 07:54:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2022-12-02 08:49:44.340', '2022-12-02 07:49:57.957',	'2022-12-02 08:49:44.340'	),
						(@emp1,		3,				@tribe3,	@tribe3Name,	@tent1,		@tent1Name,	'2022-12-05 11:19:44.340', '2022-12-03 08:49:57.957',	'2022-12-05 11:19:44.340'	),
						(@emp1,		4,				@tribe3,	@tribe3Name,	@tent1,		@tent1Name,	'2022-12-06 12:17:44.340', '2022-12-04 09:49:57.957',	'2022-12-06 12:17:44.340'	),
						(@emp1,		5,				@tribe3,	@tribe3Name,	@tent1,		@tent1Name,	'2022-12-07 13:23:44.340', '2022-12-05 10:49:57.957',	'2022-12-07 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-01-02 07:54:44.340', '2023-01-01 06:53:44.340',	'2023-01-02 07:54:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-01-03 08:49:44.340', '2023-01-02 07:49:57.957',	'2023-01-03 08:49:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-01-04 11:19:44.340', '2023-01-03 08:49:57.957',	'2023-01-04 11:19:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-01-05 12:17:44.340', '2023-01-04 09:49:57.957',	'2023-01-05 12:17:44.340'	),
						(@emp1,		4,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2023-01-06 13:23:44.340', '2023-01-05 10:49:57.957',	'2023-01-06 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-02-03 07:54:44.340', '2023-02-01 06:53:44.340',	'2023-02-03 07:54:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-02-06 08:49:44.340', '2023-02-02 07:49:57.957',	'2023-02-06 08:49:44.340'	),
						(@emp1,		3,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2023-02-07 11:19:44.340', '2023-02-03 08:49:57.957',	'2023-02-07 11:19:44.340'	),
						(@emp1,		4,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2023-02-08 12:17:44.340', '2023-02-04 09:49:57.957',	'2023-02-08 12:17:44.340'	),
						(@emp1,		4,				@tribe2,	@tribe2Name,	@tent1,		@tent1Name,	'2023-02-09 13:23:44.340', '2023-02-05 10:49:57.957',	'2023-02-09 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-05-03 07:54:44.340', '2023-05-01 06:53:44.340',	'2023-05-03 07:54:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-05-04 08:49:44.340', '2023-05-02 07:49:57.957',	'2023-05-04 08:49:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent3,		@tent3Name,	'2023-05-05 11:19:44.340', '2023-05-03 08:49:57.957',	'2023-05-05 11:19:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent3,		@tent3Name,	'2023-05-08 12:17:44.340', '2023-05-04 09:49:57.957',	'2023-05-08 12:17:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent3,		@tent3Name,	'2023-05-09 13:23:44.340', '2023-05-05 10:49:57.957',	'2023-05-09 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-06-03 07:54:44.340', '2023-06-01 06:53:44.340',	'2023-06-03 07:54:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-06-04 08:49:44.340', '2023-06-02 07:49:57.957',	'2023-06-04 08:49:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent2,		@tent2Name,	'2023-06-05 11:19:44.340', '2023-06-03 08:49:57.957',	'2023-06-05 11:19:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent2,		@tent2Name,	'2023-06-08 12:17:44.340', '2023-06-04 09:49:57.957',	'2023-06-08 12:17:44.340'	),
						(@emp1,		3,				@tribe1,	@tribe1Name,	@tent2,		@tent2Name,	'2023-06-09 13:23:44.340', '2023-06-05 10:49:57.957',	'2023-06-09 13:23:44.340'	),

						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-03 07:54:44.340', '2023-07-01 06:53:44.340',	'2023-07-03 07:54:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-04 08:49:44.340', '2023-07-02 07:49:57.957',	'2023-07-04 08:49:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-05 11:19:44.340', '2023-07-03 08:49:57.957',	'2023-07-05 11:19:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-06 12:17:44.340', '2023-07-04 09:49:57.957',	'2023-07-06 12:17:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-07 13:23:44.340', '2023-07-05 10:49:57.957',	'2023-07-07 13:23:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-10 07:54:44.340', '2023-07-10 06:53:44.340',	'2023-07-10 07:54:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-11 08:49:44.340', '2023-07-11 07:49:57.957',	'2023-07-11 08:49:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-12 11:19:44.340', '2023-07-12 08:49:57.957',	'2023-07-12 11:19:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-13 12:17:44.340', '2023-07-13 09:49:57.957',	'2023-07-13 12:17:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-14 13:23:44.340', '2023-07-14 10:49:57.957',	'2023-07-14 13:23:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-17 07:54:44.340', '2023-07-17 06:53:44.340',	'2023-07-17 07:54:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-18 08:49:44.340', '2023-07-18 07:49:57.957',	'2023-07-18 08:49:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-19 11:19:44.340', '2023-07-19 08:49:57.957',	'2023-07-19 11:19:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-20 12:17:44.340', '2023-07-20 09:49:57.957',	'2023-07-20 12:17:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-21 13:23:44.340', '2023-07-21 10:49:57.957',	'2023-07-21 13:23:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-24 07:54:44.340', '2023-07-24 06:53:44.340',	'2023-07-24 07:54:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-25 08:49:44.340', '2023-07-25 07:49:57.957',	'2023-07-25 08:49:44.340'	),
						(@emp1,		1,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-26 11:19:44.340', '2023-07-26 08:49:57.957',	'2023-07-26 11:19:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-27 12:17:44.340', '2023-07-27 09:49:57.957',	'2023-07-27 12:17:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-28 13:23:44.340', '2023-07-28 10:49:57.957',	'2023-07-28 13:23:44.340'	),
						(@emp1,		2,				@tribe1,	@tribe1Name,	@tent1,		@tent1Name,	'2023-07-31 13:23:44.340', '2023-07-31 10:49:57.957',	'2023-07-31 13:23:44.340'	)

--#######################
--#### WF WORK HOURS ####
--#######################
DROP TABLE IF EXISTS EmployeesWFWorkHours;
CREATE Table EmployeesWFWorkHours (
    crmid           UNIQUEIDENTIFIER,
    date	        DATE,
    is_holiday      TINYINT,  
    work_hours      FLOAT,
    proactive_hours FLOAT
);
CREATE UNIQUE CLUSTERED INDEX idx ON EmployeesWFWorkHours(crmid, date);
INSERT INTO dbo.EmployeesWFWorkHours
VALUES	(@emp1, '2022-09-01', 0, 8,		0	),
		(@emp1, '2022-09-02', 0, 3.4,	4.6	),
		(@emp1, '2022-09-05', 0, 6.5,	2.5	),
		(@emp1, '2022-09-06', 0, 0,		8	),
		(@emp1, '2022-09-07', 0, 5,		3	),
		(@emp1, '2022-09-08', 1, 3.5,	0	),

		(@emp1, '2022-10-03', 0, 0,		8	),
		(@emp1, '2022-10-04', 0, 3.4,	4.6	),
		(@emp1, '2022-10-05', 0, 6.5,	1.5	),
		(@emp1, '2022-10-06', 0, 8,		0	),
		(@emp1, '2022-10-07', 0, 5,		3	),
		(@emp1, '2022-10-10', 1, 3.3,	0	),

		(@emp1, '2022-11-03', 0, 8,		0	),
		(@emp1, '2022-11-04', 0, 8,		0	),
		(@emp1, '2022-11-07', 0, 8,		0	),

		(@emp1, '2022-12-01', 0, 8,		0	),
		(@emp1, '2022-12-02', 0, 8,		0	),
		(@emp1, '2022-12-05', 0, 8,		0	),
		(@emp1, '2022-12-06', 0, 8,		0	),
		(@emp1, '2022-12-07', 0, 5,		3	),
		(@emp1, '2022-12-08', 1, 3.3,	0	),

		(@emp1, '2023-01-02', 0, 8,		0	),
		(@emp1, '2023-01-03', 0, 8,		0	),
		(@emp1, '2023-01-04', 0, 8,		0	),
		(@emp1, '2023-01-05', 0, 8,		0	),
		(@emp1, '2023-01-06', 0, 5,		3	),
		(@emp1, '2023-01-09', 1, 5.7,	0	),

		(@emp1, '2023-02-03', 0, 8,		0	),
		(@emp1, '2023-02-06', 0, 8,		0	),
		(@emp1, '2023-02-07', 0, 8,		0	),

		(@emp1, '2023-05-03', 0, 8,		0	),
		(@emp1, '2023-05-04', 0, 8,		0	),
		(@emp1, '2023-05-05', 0, 8,		0	),
		(@emp1, '2023-05-08', 0, 8,		0	),
		(@emp1, '2023-05-09', 0, 5,		3	),
		(@emp1, '2023-05-10', 1, 5.5,	0	),

		(@emp1, '2023-06-03', 0, 8,		0	),
		(@emp1, '2023-06-04', 0, 8,		0	),
		(@emp1, '2023-06-05', 0, 8,		0	),
		(@emp1, '2023-06-06', 0, 8,		0	),
		(@emp1, '2023-06-07', 0, 5,		3	),

		(@emp1, '2023-07-03', 0, 8,		0	),
		(@emp1, '2023-07-04', 0, 8,		0	),
		(@emp1, '2023-07-05', 0, 8,		0	),
		(@emp1, '2023-07-06', 0, 8,		0	),
		(@emp1, '2023-07-07', 0, 5,		3	)


--#######################
--##### EMPLOYEES #######
--#######################
DECLARE @chapter1					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @chapter2					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @support_developers_chapter UNIQUEIDENTIFIER = '29B6E93D-8644-4977-9010-983076353DC6'

DROP TABLE IF EXISTS Employees;
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
DROP TABLE IF EXISTS EmployeesAudit;
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
							(	@emp1,		'2022-09-05T08:50:17.43',	'Tribe',			@chapter1,						@tribe1,	@support_developer_ph,	@trainee_support,	@philippines,			'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-09-05T08:50:17.43',	'Position',			@chapter1,						@tribe1,	@support_developer_ph,	@trainee_support,	@philippines,			'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-09-05T08:50:17.43',	'Location',			@chapter1,						@tribe1,	@support_developer_ph,	@trainee_support,	@philippines,			'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-09-05T08:50:17.43',	'Chapter',			@chapter1,						@tribe1,	@support_developer_ph,	@trainee_support,	@philippines,			'2022-06-16T00:00:00',	NULL						),

							(	@emp1,		'2022-10-05T08:50:17.43',	'Level',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Tribe',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Position',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Location',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-10-05T08:50:17.43',	'Chapter',			@support_developers_chapter,	@tribe2,	@chapter_leader,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							
							(	@emp1,		'2022-11-04T08:50:17.43',	'Chapter',			@chapter2,						@tribe2,	@tribe_leader,			@middle_dev,		@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-11-04T08:50:17.43',	'Position',			@chapter2,						@tribe2,	@tribe_leader,			@middle_dev,		@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-11-04T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@tribe_leader,			@middle_dev,		@other,					'2022-06-16T00:00:00',	NULL						),

							(	@emp1,		'2022-12-04T08:50:17.43',	'Position',			@chapter2,						@tribe2,	@support_developer,		@middle_dev,		@other,					'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2022-12-05T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@support_developer,		@middle_support,	@other,					'2022-06-16T00:00:00',	NULL						),
							
							(	@emp1,		'2023-01-05T08:50:17.43',	'Location',			@chapter2,						@tribe2,	@support_developer,		@middle_support,	@armenia,				'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2023-01-06T08:50:17.43',	'Position',			@chapter2,						@tribe2,	@developer,				@middle_support,	@armenia,				'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2023-01-07T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@developer,				@middle_dev,		@armenia,				'2022-06-16T00:00:00',	NULL						),

							(	@emp1,		'2023-02-05T08:50:17.43',	'Position',			@chapter2,						@tribe2,	@technical_writer,		@middle_dev,		@armenia,				'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2023-02-06T08:50:17.43',	'Level',			@chapter2,						@tribe2,	@technical_writer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	NULL						),
							(	@emp1,		'2023-02-07T08:50:17.43',	'RetiredAt',		@chapter2,						@tribe2,	@technical_writer,		@senior_support,	@armenia,				'2022-06-16T00:00:00',	'2023-02-07T09:50:17.43'	),
							
							(	@emp1,		'2023-05-04T08:50:17.43',	'HiredAt',			@chapter2,						@tribe3,	@support_developer,		@senior_support,	@armenia,				'2023-05-04T08:50:17',	NULL						),
							(	@emp1,		'2023-05-04T08:50:17.43',	'Position',			@chapter2,						@tribe3,	@support_developer,		@senior_support,	@armenia,				'2023-05-04T08:50:17',	NULL						),
							(	@emp1,		'2023-05-04T08:50:17.43',	'Level',			@chapter2,						@tribe3,	@support_developer,		@senior_support,	@armenia,				'2023-05-04T08:50:17',	NULL						),
							(	@emp1,		'2023-05-04T08:50:17.43',	'Tribe',			@chapter2,						@tribe3,	@support_developer,		@senior_support,	@armenia,				'2023-05-04T08:50:17',	NULL						)

--#######################
--###### VACATIONS ######
--#######################
DROP TABLE IF EXISTS Vacations;
CREATE TABLE Vacations (
	crmid		UNIQUEIDENTIFIER,
	days		INT,
	day_half	TINYINT,
	is_paid		BIT,
	vac_start	DATETIME
)
INSERT INTO Vacations	(crmid,		days,	day_half,	is_paid,	vac_start	)
VALUES					(@emp1,		0,		2,			1,			'2022-09-07'),
						(@emp1,		21,		0,			1,			'2022-09-09'),
						(@emp1,		0,		1,			1,			'2022-10-07'),
						(@emp1,		21,		0,			0,			'2022-10-10'),
						(@emp1,		22,		1,			0,			'2022-11-08'),
						(@emp1,		0,		1,			1,			'2022-12-07'),
						(@emp1,		18,		0,			0,			'2022-12-13'),
						(@emp1,		0,		2,			0,			'2023-01-06'),
						(@emp1,		0,		1,			1,			'2023-05-09'),
						(@emp1,		20,		0,			0,			'2023-05-11')
--###################################
--###### ExternalAssignActions ######
--###################################
DROP TABLE IF EXISTS ExternalAssignActions;
CREATE TABLE ExternalAssignActions(
	ExternalTicketId	INT,
	Id					INT,
	Action				VARCHAR(20),
	Date				DATETIME,
	AssigneeId			UNIQUEIDENTIFIER
)
INSERT INTO ExternalAssignActions
VALUES	(1, 1, 'Reply',		'2023-07-03 07:54:44.340', @emp1),
		(1, 2, 'Reply',		'2023-07-04 07:54:44.340', @emp1),
		(2, 1, 'Ignore',	'2023-07-05 07:54:44.340', @emp1)
--###################################
--####### EmployeesDevSupport #######
--###################################
DROP TABLE IF EXISTS EmployeesDevSupport
CREATE TABLE EmployeesDevSupport(
	crmid UNIQUEIDENTIFIER PRIMARY KEY,
	perc_of_worktime_spent_on_support FLOAT
	CONSTRAINT perc_of_worktime_spent_on_support_chk CHECK (perc_of_worktime_spent_on_support < 1)
);
INSERT INTO EmployeesDevSupport
VALUES	(@emp1, 0.5)
GO
--#######################
--######## ITVFs ########
--#######################
CREATE OR ALTER FUNCTION dbo.parse_employees(@json VARCHAR(MAX)) RETURNS TABLE AS
	RETURN (
		SELECT  *
		FROM	Employees
	)
GO
CREATE OR ALTER FUNCTION dbo.parse_employees_audit(@json VARCHAR(MAX)) RETURNS TABLE AS
	RETURN (
		SELECT  *
		FROM EmployeesAudit	
    )
GO
CREATE OR ALTER FUNCTION dbo.parse_vacations(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
	FROM Vacations
)
GO
CREATE OR ALTER FUNCTION dbo.parse_positions(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
    FROM   Positions
)
GO
CREATE OR ALTER FUNCTION dbo.parse_locations(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
    SELECT  *
    FROM    Locations
)
GO
CREATE OR ALTER FUNCTION dbo.parse_levels(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
    FROM   Levels
				
)
GO
CREATE OR ALTER FUNCTION dbo.get_iterations(@start DATE, @end DATE, @employees VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
		SELECT  *
		FROM Iterations
    )
GO

PRINT 'test db: up'
