SET XACT_ABORT, NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY
    DECLARE @i INT = 1;
    BEGIN TRAN
        SET @i /= 0;
    COMMIT TRAN;
    SELECT @i;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;
    --THROW;
    RAISERROR('Oh 💩 try again.',11,1);
END CATCH;

SELECT @i;

-----------------------------

DECLARE @Error INT;

BEGIN TRAN
    SET @i = 10000000000;
    SET @Error = @@ERROR;
    IF @Error <> 0
        GOTO ErrorHandler;
COMMIT TRAN;

ErrorHandler:
IF @Error <> 0
    ROLLBACK TRAN;
