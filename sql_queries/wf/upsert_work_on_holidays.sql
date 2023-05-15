MERGE INTO EmployeesWorkOnHolidays AS target
USING (
	SELECT	*
	FROM (VALUES
		{values} 
    ) AS ds ({crmid}, {date}, {hours})
) AS source
ON	target.{crmid} = source.{crmid} AND
	target.{date} = source.{date}
WHEN MATCHED THEN UPDATE SET {hours} = source.{hours}
WHEN NOT MATCHED BY TARGET THEN INSERT VALUES (source.{crmid}, source.{date}, source.{hours});