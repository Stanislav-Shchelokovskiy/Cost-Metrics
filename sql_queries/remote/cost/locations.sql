DECLARE @json VARCHAR(MAX) = N'{locations_json}'

DROP TABLE IF EXISTS #EmployeeLocations;

SELECT  *
FROM    OPENJSON(@json, '$.page') WITH (
            id			UNIQUEIDENTIFIER	'strict $.id',
            name		NVARCHAR(250)		'strict $.name',
            is_active	BIT					'strict $.isActive'
        ) AS ds

CREATE CLUSTERED INDEX idx ON #EmployeeLocations(id);
