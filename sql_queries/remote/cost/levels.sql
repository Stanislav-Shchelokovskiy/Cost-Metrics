DECLARE @json VARCHAR(MAX) = N'{levels_json}'

DROP TABLE IF EXISTS #EmployeeLevels;

SELECT  *
INTO    #EmployeeLevels
FROM    OPENJSON(@json, '$.page') WITH (
            id		UNIQUEIDENTIFIER    'strict $.id',
            name	NVARCHAR(250)       'strict $.name'
        ) AS ds;

CREATE CLUSTERED INDEX idx ON #EmployeeLevels(id);
