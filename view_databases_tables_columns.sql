declare @cmd nvarchar(4000) 
set @cmd = N'IF ''?'' not in (''master'',''model'',''msdb'',''tempdb'')
             BEGIN
             USE ?
             SELECT 
                 db_name() AS database_name
                ,schema_name(s.schema_id) AS schema_name
                ,t.name AS table_name
                ,c.name AS column_name
                ,c.column_id
                ,y.name AS column_type
                ,c.max_length AS column_length
             FROM sys.schemas AS s
                 INNER JOIN sys.tables AS t
                     ON s.schema_id = t.schema_id
                 INNER JOIN sys.columns AS c
                     ON t.object_id = c.object_id
                 LEFT JOIN sys.types AS y
                     ON c.user_type_id = y.user_type_id
             /*WHERE c.name LIKE ''%MyCustomColumn%''*/
             WHERE y.name not in (''varchar'',''nvarchar'',''char'',''nchar''
                ,''datetime'',''datetime2'',''date'',''int'',''tinyint''
                ,''smallint'',''bigint'',''money'',''smallmoney'',''time''
                ,''uniqueidentifier'',''varbinary'',''bit'')
             ORDER BY 
                 schema_name(s.schema_id)
                ,t.name
                ,c.column_id
             END' 
exec sp_MSforeachdb @cmd
