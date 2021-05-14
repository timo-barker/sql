-- Mass update texts in SQL objects

use AdventureWorks

IF OBJECT_ID('tempdb.dbo.#StoredProcMassUpdater','P') IS NOT NULL
    DROP PROC #StoredProcMassUpdater;
GO

CREATE PROCEDURE #StoredProcMassUpdater
    @ProcName VARCHAR(MAX)
AS
BEGIN
    DECLARE @PositionTicketNumber INT
    DECLARE @Command NVARCHAR(MAX)

    SELECT @Command = OBJECT_DEFINITION(OBJECT_ID(@ProcName));
    SET @PositionTicketNumber = CHARINDEX('Ticket 12345', @Command)

    IF NOT @PositionTicketNumber = 0 
        BEGIN
            SET @Command = STUFF(@Command, CHARINDEX('ProductionServer.dbo.dDate', @Command), LEN('ProductionServer.dbo.dDate'), 'DevelopmentServer.dbo.dbo.dDate');
            SET @Command = REPLACE(@Command, 'CREATE PROC', 'ALTER PROC');
            EXECUTE sp_executesql @Command
            PRINT 'changed'
        END
    ELSE
        PRINT 'not found'
END
GO

SET XACT_ABORT, NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY

BEGIN TRAN

DECLARE @ProcList TABLE (ProcName VARCHAR(128))
INSERT INTO @ProcList (ProcName) 
select concat(quotename(db_name()),'.',quotename(s.name),'.',quotename(o.name))
from sys.schemas s
    inner join sys.objects o
        on s.schema_id = o.schema_id
where o.type = 'P'

DECLARE @ProcSelected AS VARCHAR(128)

DECLARE #C CURSOR FOR
    SELECT ProcName
    FROM @ProcList
    ORDER BY ProcName;

OPEN #C;

FETCH NEXT FROM #C INTO @ProcSelected;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC #StoredProcMassUpdater @ProcName = @ProcSelected;
    FETCH NEXT FROM #C INTO @ProcSelected;
END;

CLOSE #C;

DEALLOCATE #C;

ROLLBACK TRAN

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;
    THROW;

END CATCH
GO
