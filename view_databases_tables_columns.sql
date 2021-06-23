DECLARE @cmd NVARCHAR(4000);
DECLARE @col NVARCHAR(128) = '';
SET @cmd = N'if ''?'' not in (''master'',''model'',''msdb'',''tempdb'')
             begin
             use ?
             select
                 TABLE_CATALOG
                ,TABLE_SCHEMA
                ,TABLE_NAME
                ,COLUMN_NAME
                ,ORDINAL_POSITION
                ,IS_NULLABLE
                ,DATA_TYPE
                ,CHARACTER_MAXIMUM_LENGTH
                ,CHARACTER_OCTET_LENGTH
                ,NUMERIC_PRECISION
                ,NUMERIC_PRECISION_RADIX
                ,DATETIME_PRECISION
                ,CHARACTER_SET_NAME
                ,COLLATION_NAME
             from INFORMATION_SCHEMA.COLUMNS
             where COLUMN_NAME like ''%' + @col + '%''
             order by
                 TABLE_CATALOG
                ,TABLE_SCHEMA
                ,TABLE_NAME
                ,ORDINAL_POSITION
             end';
EXEC sp_MSforeachdb @cmd;
