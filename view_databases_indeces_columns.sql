DECLARE @cmd NVARCHAR(4000);
DECLARE @tbl NVARCHAR(128) = '';
SET @cmd = N'if ''?'' not in (''master'',''model'',''msdb'',''tempdb'')
             begin
             use ?
             select db_name() database_name,
                    s.name schema_name,
                    a.name table_name,
                    b.name index_name, 
                    b.type_desc index_type,
                    d.name column_name,
                    c.index_column_id
               from sys.schemas s,
                    sys.tables a,
                    sys.indexes b,
                    sys.index_columns c,
                    sys.columns d
             where s.schema_id = a.schema_id
               and a.object_id = b.object_id
               and b.object_id = c.object_id
               and b.index_id  = c.index_id
               and c.object_id = d.object_id
               and c.column_id = d.column_id
               and a.name like ''%' + @tbl + '%''
             order by a.name,
                      b.index_id,
                      c.index_column_id
             end';
EXEC sp_MSforeachdb @cmd;
