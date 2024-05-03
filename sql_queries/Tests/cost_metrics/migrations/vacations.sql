SET NOCOUNT ON
:setvar SQLCMDERRORLEVEL 1
GO

USE DXStatisticsV2
GO

DECLARE @emp1 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000001'

INSERT INTO Vacations	(crmid,		days,	day_half,	is_paid,	vac_start	)
VALUES					(@emp1,		0,		2,			1,			'2022-10-07'),
						(@emp1,		0,		1,			1,			'2022-11-07'),
						(@emp1,		18,		0,			0,			'2022-12-13'),
						(@emp1,		0,		2,			0,			'2023-01-06'),
						(@emp1,		0,		1,			1,			'2023-02-09'),
						(@emp1,		20,		0,			0,			'2023-03-11')
GO
