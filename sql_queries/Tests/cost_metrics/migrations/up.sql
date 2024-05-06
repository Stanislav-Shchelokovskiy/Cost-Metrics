SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

CREATE DATABASE CRM
CREATE DATABASE DXStatisticsV2
CREATE DATABASE CRMAudit
GO

USE CRM
GO

--#######################
--####### TRIBES ########
--#######################
DROP TABLE IF EXISTS Tribes;
CREATE TABLE Tribes (
	Id		UNIQUEIDENTIFIER PRIMARY KEY,
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
	Id		UNIQUEIDENTIFIER PRIMARY KEY,
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
CREATE TABLE dxcrm.Tent_Employee (
	Employee_Id		UNIQUEIDENTIFIER,
	Tent_Id			UNIQUEIDENTIFIER,
	EntityModified	DATETIME,
	AuditAction		TINYINT
)
--#######################
--##### Tribes Audit ####
--#######################
CREATE TABLE dxcrm.Tribes (
	EntityModified	DATETIME,
	EntityOid		UNIQUEIDENTIFIER,
	Name			VARCHAR(20)
)
INSERT INTO dxcrm.Tribes
VALUES	('2022-11-07 11:53:44.340', '00000000-0000-0000-0000-000000000003', 'tribe3'),
        ('2022-11-08 11:53:44.340', '00000000-0000-0000-0000-000000000003', 'TO DELETE')
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
--######################
--##### LOCATIONS ######
--######################
CREATE TABLE Locations (
	id			UNIQUEIDENTIFIER PRIMARY KEY,
	name		VARCHAR(30),
	is_active	BIT
)
DECLARE @philippines	UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @estonia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @other			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @non_active		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
INSERT INTO Locations(	id,				name,			is_active	)
VALUES				 (	@philippines,	'philippines',	1			),
					 (	@armenia,		'armenia',		1			),
					 (	@estonia,		'estonia',		1			),
					 (	@other,			'other',		1			),
        			 (	@non_active,   	'non_active',   0			)
--#######################
--###### POSITIONS ######
--#######################
CREATE TABLE Positions (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
DECLARE @support_developer_ph	UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @chapter_leader			UNIQUEIDENTIFIER = '945FDE96-987B-4608-85F4-7393F00D341B'
DECLARE @tribe_leader			UNIQUEIDENTIFIER = '0CF0BDBA-7DE3-4A06-9493-8F90720526B7'
DECLARE @pm						UNIQUEIDENTIFIER = '835B63C4-D357-497A-A184-3F4FEAAA2AA7'
DECLARE @principal_pm			UNIQUEIDENTIFIER = 'E8D90D9A-4C9D-45A6-A828-02CD6FA14924'
DECLARE @developer				UNIQUEIDENTIFIER = '5739E91C-83AE-46CB-A9A0-32517CB1BAAA'
DECLARE @technical_writer		UNIQUEIDENTIFIER = '4D017739-BA85-4C71-AEFD-1B7098BE81A2'
DECLARE @squad_leader			UNIQUEIDENTIFIER = '520C9118-F21C-4B49-B937-A5ED2806B10C'

INSERT INTO Positions(id, name)
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
CREATE TABLE Levels (
	id		UNIQUEIDENTIFIER PRIMARY KEY,
	name	VARCHAR(30)
)
DECLARE @junior1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000011'
DECLARE @junior2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000022'
DECLARE @junior3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000033'
DECLARE @junior4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000044'
DECLARE @middle1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000055'
DECLARE @middle2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000066'

DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @junior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000007'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle_dev			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'
INSERT INTO Levels(id, name)
VALUES	(@trainee_support,	'trainee_support'	),
		(@junior_support,	'junior_support'	),
		(@middle_support,	'middle_support'	),
		(@middle_dev,		'middle_dev'		),
		(@senior_support,	'senior_support'	)
--#######################
--###### ITERATIONS #####
--#######################
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
--#####################################
--####### EmployeesSelfEmployed #######
--#####################################
DROP TABLE IF EXISTS EmployeesSelfEmployed
CREATE TABLE EmployeesSelfEmployed (
	crmid	UNIQUEIDENTIFIER
)
INSERT INTO EmployeesSelfEmployed
VALUES	('00000000-0000-0000-0000-000000000004')
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
INSERT INTO EmployeesSalaries
VALUES		(1, 1, @junior1, @philippines, 30500, @php, @not_applicable, 3),
            (2, 2, @junior2, @philippines, 36000, @php, @not_applicable, 3),
            (3, 3, @junior3, @philippines, 42500, @php, @not_applicable, 4),
            (4, 4, @junior4, @philippines, 48000, @php, @not_applicable, 4),
            (5, 5, @middle1, @philippines, 58000, @php, @not_applicable, 5),
            (6, 6, @middle2, @philippines, 65000, @php, @not_applicable, 6),

            (1, 1,   	@trainee_support, 	@estonia, 	850,  @eur, @after_oct_2022,  	3),
            (1, 1,   	@trainee_support, 	@armenia, 	900,  @usd, @after_oct_2022,  	3),
            (1, NULL,	@trainee_support, 	@other,   	1000, @usd, @after_oct_2022,  	3),
            (1, 1,   	@trainee_support, 	NULL,     	1100, @usd, @before_oct_2022, 	3),

			(2,	2,		@junior_support,	@estonia,  	925,  @eur, @after_oct_2022,  	4),
			(2,	2,		@junior_support,	@armenia,  	975,  @usd, @after_oct_2022,  	4),
			(2,	NULL,	@junior_support,	@other,	  	1025, @usd, @after_oct_2022,  	4),
			(2,	2,		@junior_support,	NULL,	  	1075, @usd, @before_oct_2022, 	4),

            (3, 3,    	@middle_support,  	@estonia, 	1150, @eur, @after_oct_2022,  	5),
            (3, 3,    	@middle_support,  	@armenia, 	1200, @usd, @after_oct_2022,  	5),
            (3, 3,    	@middle_support,  	@other,   	1300, @usd, @after_oct_2022,  	5),
            (3, 3,    	@middle_support,  	NULL,     	1400, @usd, @before_oct_2022, 	5),

            (4, 4,    	@middle_dev,      	@estonia, 	1450, @eur, @after_oct_2022,  	5),
            (4, 4,    	@middle_dev,      	@armenia, 	1500, @usd, @after_oct_2022,  	5),
            (4, 4,    	@middle_dev,      	@other,   	1600, @usd, @after_oct_2022,  	5),
            (4, 4,    	@middle_dev,      	NULL,     	1700, @usd, @before_oct_2022, 	5),

            (5, 5,	 	@senior_support,  	@estonia, 	1750, @eur, @after_oct_2022, 	5.5),
            (5, 5,   	@senior_support,  	@armenia, 	1800, @usd, @after_oct_2022,  	5.5),
            (5, 5,   	@senior_support,  	@other,   	1900, @usd, @after_oct_2022,  	5.5),
            (5, 5,   	@senior_support,  	NULL,     	2000, @usd, @before_oct_2022, 	5.5)

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
DECLARE @null_date	DATE = '1990-01-01'
INSERT INTO EmployeesOperatingExpenses
VALUES	(@philippines,	@null_date,	2000),
		(@armenia,		@null_date,	2200),
		(@other,		@null_date,	2200)

CREATE CLUSTERED INDEX idx ON EmployeesOperatingExpenses(location_id, actual_since)
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
DECLARE @new_life_start		DATE = '2022-10-01'
DECLARE @relocation_date	DATE = '2022-03-01'
INSERT INTO EmployeesTaxCoefficients(location_id,   actual_since,   salary, self_employed, value    )
VALUES	                            (@other,		@null_date,		0,		0,	            1.078	),
		                            (@philippines,	@null_date,		0,		0,	            1.06	),
		                            (@armenia,		'2021-12-01',	0,		0,	            1.31	)

CREATE CLUSTERED INDEX idx ON EmployeesTaxCoefficients(location_id, actual_since, self_employed, salary)
--#######################
--##### SCWorkHours #####
--#######################
CREATE TABLE EmployeesSCWorkHours (
	scid		UNIQUEIDENTIFIER,
	date		DATE,
	work_hours	FLOAT
)
CREATE CLUSTERED INDEX idx ON EmployeesSCWorkHours(scid, date)
--#######################
--#### WF WORK HOURS ####
--#######################
CREATE Table EmployeesWFWorkHours (
    crmid           UNIQUEIDENTIFIER,
    date	        DATE,
    is_holiday      TINYINT,  
    work_hours      FLOAT,
    proactive_hours FLOAT
)
CREATE CLUSTERED INDEX idx ON EmployeesWFWorkHours(crmid, date)
--#######################
--##### EMPLOYEES #######
--#######################
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
--#######################
--###### VACATIONS ######
--#######################
CREATE TABLE Vacations (
	crmid		UNIQUEIDENTIFIER,
	days		INT,
	day_half	TINYINT,
	is_paid		BIT,
	vac_start	DATETIME
)
--###################################
--###### ExternalAssignActions ######
--###################################
CREATE TABLE ExternalAssignActions(
	ExternalTicketId	INT,
	Id					INT,
	Action				VARCHAR(20),
	Date				DATETIME,
	AssigneeId			UNIQUEIDENTIFIER
)
--###################################
--####### EmployeesDevSupport #######
--###################################
CREATE TABLE EmployeesDevSupport(
	crmid UNIQUEIDENTIFIER PRIMARY KEY,
	perc_of_worktime_spent_on_support FLOAT
	CONSTRAINT perc_of_worktime_spent_on_support_chk CHECK (perc_of_worktime_spent_on_support < 1)
);
DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
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
