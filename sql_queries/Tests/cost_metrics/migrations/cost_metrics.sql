SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE CRMAudit
GO

--#######################
--#### Tent_Employee ####
--#######################
DECLARE @tent1	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @tent2	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @tent3	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @emp1 	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
INSERT INTO dxcrm.Tent_Employee(Employee_Id, Tent_Id, EntityModified, AuditAction)
VALUES	(@emp1, @tent1, '2023-06-04 11:54:44.340', 0),
        (@emp1, @tent1, '2023-07-04 11:54:44.340', 2),
		(@emp1, @tent2, '2023-07-05 11:54:44.340', 0),
		(@emp1, @tent2, '2023-07-06 11:53:44.340', 2),
		(@emp1, @tent3, '2023-08-06 11:54:44.340', 3)

USE DXStatisticsV2
GO
--#######################
--##### SCWorkHours #####
--#######################
DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
INSERT INTO dbo.EmployeesSCWorkHours(scid, date, work_hours)
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
INSERT INTO dbo.EmployeesWFWorkHours(crmid, date, is_holiday, work_hours, proactive_hours)
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
DECLARE @support_developer_ph	UNIQUEIDENTIFIER = '10D4EC1A-8EEA-4930-A88B-76D0CAC11E89'
DECLARE @chapter_leader			UNIQUEIDENTIFIER = '945FDE96-987B-4608-85F4-7393F00D341B'
DECLARE @tribe_leader			UNIQUEIDENTIFIER = '0CF0BDBA-7DE3-4A06-9493-8F90720526B7'
DECLARE @support_developer		UNIQUEIDENTIFIER = '7A8E1B05-385E-4C91-B61E-81446B0C404A'
DECLARE @developer				UNIQUEIDENTIFIER = '5739E91C-83AE-46CB-A9A0-32517CB1BAAA'
DECLARE @technical_writer		UNIQUEIDENTIFIER = '4D017739-BA85-4C71-AEFD-1B7098BE81A2'

DECLARE @trainee_support	UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'
DECLARE @middle_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000004'
DECLARE @middle_dev			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000005'
DECLARE @senior_support		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000006'

DECLARE @philippines	UNIQUEIDENTIFIER = '69D186BB-CF91-4A5B-BF75-D3F1036C33E3'
DECLARE @armenia		UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @other			UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000003'

DECLARE @chapter1					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'
DECLARE @chapter2					UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000002'
DECLARE @support_developers_chapter UNIQUEIDENTIFIER = '29B6E93D-8644-4977-9010-983076353DC6'

INSERT INTO Employees	(	crmid,	scid,	name,	tribe_id,	tribe_name,		tent_id,	tent_name,	position_id,		position_name,			chapter_id,	level_id,			has_support_processing_role,	location_id,	hired_at,		retired_at,				retired,	is_service_user	)
VALUES					(	@emp1,	@emp1,	'emp1',	@tribe2,	@tribe2Name,	NULL,		NULL,		@support_developer,	'support_developer',	@chapter1,	@middle_support,	1,								@armenia,		'2023-05-04',	CAST(NULL AS DATE),		0,			0				)
--#######################
--### EMPLOYEES AUDIT ###
--#######################
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
INSERT INTO ExternalAssignActions(ExternalTicketId, Id, Action, Date, AssigneeId)
VALUES	(1, 1, 'Reply',		'2023-07-03 07:54:44.340', @emp1),
		(1, 2, 'Reply',		'2023-07-04 07:54:44.340', @emp1),
		(2, 1, 'Ignore',	'2023-07-05 07:54:44.340', @emp1)

PRINT 'test db: up'
