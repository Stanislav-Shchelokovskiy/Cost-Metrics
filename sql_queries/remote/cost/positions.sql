DECLARE @json VARCHAR(MAX) = N'{positions_json}'

DROP TABLE IF EXISTS #EmployeePositions;

SELECT  *
INTO    #EmployeePositions
FROM    OPENJSON(@json, '$.page') WITH (
            id		UNIQUEIDENTIFIER    'strict $.id',
            name	NVARCHAR(250)       'strict $.name'
        ) AS ds;

CREATE CLUSTERED INDEX idx ON #EmployeePositions(id);
