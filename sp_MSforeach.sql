DECLARE @cmd NVARCHAR(4000);
SET @cmd = N'if ''^'' not in (''master'',''model'',''msdb'',''tempdb'')
             begin
             use ^;
             exec sp_MSforeachtable @command1 = "select ''^'' as db_foreach, ''?'' as tb_foreach;";
             end;
            ';
EXEC sp_MSforeachdb @command1 = @cmd, @replacechar = '^';
