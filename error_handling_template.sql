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

DECLARE @e INT;
BEGIN TRAN x1;
    SELECT 1/ROUND(RAND(),0);
        SET @e = @@ERROR;
        IF @e <> 0
            GOTO ErrorHandler;
COMMIT TRAN x1;
RAISERROR(N'👍',0,0);

ErrorHandler:
IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRAN x1;
        PRINT N'oh 💩! try again.';
    END;
