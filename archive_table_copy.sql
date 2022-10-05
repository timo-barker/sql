SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
-- Make a backup of any table. Keeps 2 months of backups.
-- Must have [Archives] database and [bak] schema.
--------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[TableBackup]
  (
    @DatabaseName varchar(100) = NULL
   ,@SchemaName   varchar(100) = NULL
   ,@TableName    varchar(100)   
  )
AS
BEGIN

SET NOCOUNT ON;

SET @DatabaseName = ISNULL(@DatabaseName,db_name());
SET @SchemaName   = ISNULL(@SchemaName,'dbo');

DECLARE @SourceTable nvarchar(500) = CONCAT_WS(N'.',@DatabaseName,@SchemaName,@TableName);
DECLARE @NewBackup   nvarchar(500) = CONCAT_WS(N'_',@DatabaseName,@SchemaName,@TableName,format(getdate(),N'yyyyMMddTHHmmssfff'));
DECLARE @OldBackup   nvarchar(500) = CONCAT_WS(N'_',@DatabaseName,@SchemaName,@TableName);
DECLARE @DynamicSql  nvarchar(4000);

-- Create today backup if not exists
IF NOT EXISTS (
               SELECT *
               FROM Archives.sys.tables WITH (NOLOCK)
               WHERE OBJECT_SCHEMA_NAME(object_id,db_id('Archives')) = 'bak'
               AND name LIKE SUBSTRING(@NewBackup,1,LEN(@NewBackup)-10) + '%'
              )
    BEGIN
        SET @DynamicSql = N'SELECT * INTO Archives.bak.' + @NewBackup + N' FROM ' + @SourceTable + N' WITH (NOLOCK);';
        EXEC sp_sqlexec @DynamicSql;
    END;

-- Find backups older than 2 months
DROP TABLE IF EXISTS #Cursor;
CREATE TABLE #Cursor (RowId int identity, DropCommand nvarchar(4000));
SET @DynamicSql = N'INSERT INTO #Cursor (DropCommand) ' + NCHAR(13) + NCHAR(10)
                + N'SELECT ''DROP TABLE Archives.bak.'' + name ' + NCHAR(13) + NCHAR(10)
                + N'FROM Archives.sys.tables WITH (NOLOCK) ' + NCHAR(13) + NCHAR(10)
                + N'WHERE DATEDIFF(month,create_date,GETDATE()) > 1 ' + NCHAR(13) + NCHAR(10)
                + N'AND OBJECT_SCHEMA_NAME(object_id,db_id(''Archives'')) = ''bak'' ' + NCHAR(13) + NCHAR(10)
                + N'AND name LIKE ''' + @OldBackup + N'%''; ';
EXEC sp_sqlexec @DynamicSql;

-- Drop backups older than 2 months
WHILE EXISTS (
              SELECT *
              FROM #Cursor
             )
    BEGIN
        SELECT TOP 1 @DynamicSql = DropCommand FROM #Cursor;
        print @DynamicSql
        EXEC sp_sqlexec @DynamicSql;
        DELETE #Cursor WHERE DropCommand = @DynamicSql;
    END;

END;
GO
