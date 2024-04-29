SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

CREATE DATABASE DXStatisticsV2
GO

USE DXStatisticsV2
GO

DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

CREATE TABLE Vacations (
	crmid		UNIQUEIDENTIFIER,
	days		INT,
	day_half	TINYINT,
	is_paid		BIT,
	vac_start	DATETIME
)
INSERT INTO Vacations	(crmid,		days,	day_half,	is_paid,	vac_start	)
VALUES					(@emp1,		0,		2,			1,			'2022-10-07'),
						(@emp1,		0,		1,			1,			'2022-11-07'),
						(@emp1,		18,		0,			0,			'2022-12-13'),
						(@emp1,		0,		2,			0,			'2023-01-06'),
						(@emp1,		0,		1,			1,			'2023-02-09'),
						(@emp1,		20,		0,			0,			'2023-03-11')
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

CREATE OR ALTER FUNCTION dbo.parse_vacations(@json VARCHAR(MAX)) RETURNS TABLE AS
RETURN (
	SELECT  *
	FROM Vacations
)
GO
