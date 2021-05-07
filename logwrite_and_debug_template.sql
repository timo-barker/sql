DROP TABLE IF EXISTS ##LogStats
GO

CREATE TABLE ##LogStats
  (
    StepID      INT IDENTITY(1,1)
   ,ProcName    VARCHAR(128)
   ,Description VARCHAR(100)
   ,TS          DATETIME DEFAULT GETDATE()
   ,PRIMARY KEY (StepID)
  )
GO

DROP TABLE IF EXISTS ##LogStatsDetailed
GO

CREATE TABLE ##LogStatsDetailed
  (
    StepDetailID INT IDENTITY(1,1)
   ,ProcName     VARCHAR(128)
   ,ProcBegin    DATETIME
   ,ProcTime     AS CAST(BlockEnd-ProcBegin AS TIME)
   ,BlockName    VARCHAR(100)
   ,BlockBegin   DATETIME
   ,BlockEnd     DATETIME
   ,BlockTime    AS CAST(BlockEnd-BlockBegin AS TIME)
   ,RowCnt       INT
   ,Err_Num      INT
   ,Err_Severity INT
   ,Err_Line     INT
   ,Err_Msg      VARCHAR(8000)
   ,UserMsg1     VARCHAR(8000)
   ,UserMsg2     VARCHAR(8000)
   ,UserMsg3     VARCHAR(8000)
   ,TS           DATETIME DEFAULT GETDATE()
   ,PRIMARY KEY (StepDetailID)
  )
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
--
-- Author:      Anno Domini
-- Create date: 1970-01-01
--
-- Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
--              eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
--              enim ad minim veniam, quis nostrud exercitation ullamco laboris
--              nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor
--              in reprehenderit in voluptate velit esse cillum dolore eu fugiat
--              nulla pariatur. Excepteur sint occaecat cupidatat non proident,
--              sunt in culpa qui officia deserunt mollit anim id est laborum.
--
-- Outputs:     dbo.TableB
--
-- Inputs:      dbo.TableA
--
-- Functions:   dbo.fn_RubeGoldBerg()
--
-- Updates:
-- Date        Author                Description
-- ----------  --------------------  -------------------------------------------
--
--------------------------------------------------------------------------------
CREATE PROCEDURE #MyStoredProc
  (
    @BeginDate DATETIME = NULL
   ,@EndDate   DATETIME = NULL
  )
AS

SET XACT_ABORT, NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY

--DECLARE @BeginDate  DATETIME;
--DECLARE @Enddate    DATETIME;
  DECLARE @ProcName   VARCHAR(128) = OBJECT_NAME(@@PROCID);
  DECLARE @ProcBegin  DATETIME     = GETDATE();
  DECLARE @ProcEnd    DATETIME;
  DECLARE @BlockName  VARCHAR(100);
  DECLARE @BlockBegin DATETIME;
  DECLARE @BlockEnd   DATETIME;
  DECLARE @RowCount   INT;
  DECLARE @Message    VARCHAR(100);
  DECLARE @LogWrite   BIT          = 1;
  DECLARE @DeBug      BIT          = 1;

IF @BeginDate IS NULL
    SET @BeginDate = DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE())-1,0);

IF @EndDate IS NULL
    SET @EndDate = CAST(GETDATE() AS DATE);

IF @ProcName IS NULL
    SET @ProcName = '#MyStoredProc';

-------------- Initialize the LogStats table for the current run ---------------
IF @LogWrite = 1
    INSERT INTO ##LogStats (ProcName, Description) VALUES (@ProcName, 'Start');
IF @DeBug = 1
    BEGIN
        PRINT CHAR(13) + CHAR(10) + 'Begin  ' + @ProcName;
        PRINT 'start: ' + CONVERT(CHAR(23),@ProcBegin,121);
    END;
--------------------------------------------------------------------------------

------------------ This goes at start of each block of logic -------------------
SET @BlockName = '1     - Primo';
SET @BlockBegin = GETDATE();
IF @LogWrite = 1
    INSERT INTO ##LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin
                                    ,UserMsg1 ,UserMsg2 ,UserMsg3)
    VALUES (@ProcName, @ProcBegin, @BlockName, @BlockBegin
            ,@BeginDate ,@EndDate, SUSER_NAME());
IF @DeBug = 1
    BEGIN
        PRINT CHAR(13) + CHAR(10) + @BlockName;
        SET @Message = CONVERT(CHAR(23),@BlockBegin,121);
        RAISERROR('start: %s', 0, 0, @Message) WITH NOWAIT;
    END;
--------------------------------------------------------------------------------

select 1/1
where 1=0

------------------- This goes at end of each block of logic --------------------
SET @RowCount = @@ROWCOUNT;
SET @BlockEnd = GETDATE();
IF @LogWrite = 1
    UPDATE ##LogStatsDetailed
    SET    BlockEnd = @BlockEnd
          ,RowCnt = @RowCount
    WHERE  ProcName = @ProcName
      AND  BlockName = @BlockName
      AND  BlockBegin = @BlockBegin;
IF @DeBug = 1
    BEGIN
        PRINT 'ended: ' + CONVERT(CHAR(23),@BlockEnd,121);
        PRINT 'timed: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@BlockEnd-@BlockBegin AS TIME));
        PRINT 'elaps: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@BlockEnd-@ProcBegin AS TIME));
        PRINT 'row/s: ' + FORMAT(@RowCount,'#,##0');
    END;
--------------------------------------------------------------------------------

------------------ This goes at start of each block of logic -------------------
SET @BlockName = '2     - Secundus';
SET @BlockBegin = GETDATE();
IF @LogWrite = 1
    INSERT INTO ##LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin
                                    ,UserMsg1 ,UserMsg2 ,UserMsg3)
    VALUES (@ProcName, @ProcBegin, @BlockName, @BlockBegin
            ,@BeginDate ,@EndDate, SUSER_NAME());
IF @DeBug = 1
    BEGIN
        PRINT CHAR(13) + CHAR(10) + @BlockName;
        SET @Message = CONVERT(CHAR(23),@BlockBegin,121);
        RAISERROR('start: %s', 0, 0, @Message) WITH NOWAIT;
    END;
--------------------------------------------------------------------------------

select 1/0

------------------- This goes at end of each block of logic --------------------
SET @RowCount = @@ROWCOUNT;
SET @BlockEnd = GETDATE();
IF @LogWrite = 1
    UPDATE ##LogStatsDetailed
    SET    BlockEnd = @BlockEnd
          ,RowCnt = @RowCount
    WHERE  ProcName = @ProcName
      AND  BlockName = @BlockName
      AND  BlockBegin = @BlockBegin;
IF @DeBug = 1
    BEGIN
        PRINT 'ended: ' + CONVERT(CHAR(23),@BlockEnd,121);
        PRINT 'timed: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@BlockEnd-@BlockBegin AS TIME));
        PRINT 'elaps: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@BlockEnd-@ProcBegin AS TIME));
        PRINT 'row/s: ' + FORMAT(@RowCount,'#,##0');
    END;
--------------------------------------------------------------------------------

--------------- Finalize the LogStats table for the current run ----------------
SET @ProcEnd = GETDATE();
IF @LogWrite = 1
    INSERT INTO ##LogStats (ProcName, Description) VALUES (@ProcName, 'Complete');
IF @DeBug = 1
    BEGIN
        PRINT CHAR(13) + CHAR(10) + 'Finish ' + @ProcName;
        PRINT 'ended: ' + CONVERT(CHAR(23),@ProcEnd,121);
        PRINT 'timed: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@ProcEnd-@ProcBegin AS TIME));
    END;
--------------------------------------------------------------------------------

END TRY

BEGIN CATCH

----------- If an error occurs the code in this CATCH block will run -----------
IF XACT_STATE() <> 0
    ROLLBACK TRANSACTION;
SET @ProcEnd = GETDATE();
IF @LogWrite = 1
    UPDATE ##LogStatsDetailed
    SET    BlockEnd = @ProcEnd
          ,Err_Num = ERROR_NUMBER()
          ,Err_Severity = ERROR_SEVERITY()
          ,Err_Line = ERROR_LINE()
          ,Err_Msg = ERROR_MESSAGE()
    WHERE  ProcName = @ProcName
      AND  BlockName = @BlockName
      AND  BlockBegin = @BlockBegin;
IF @DeBug = 1
    BEGIN
        PRINT CHAR(13) + CHAR(10) + 'Error ' + @ProcName;
        PRINT 'ended: ' + CONVERT(CHAR(23),@ProcEnd,121);
        PRINT 'timed: ' + REPLICATE(' ',11) + CONVERT(CHAR(12),CAST(@ProcEnd-@ProcBegin AS TIME));
    END;
THROW;
--------------------------------------------------------------------------------

END CATCH;
GO

EXEC #MyStoredProc
GO

SELECT *
FROM ##LogStats
GO

SELECT *
FROM ##LogStatsDetailed
GO

DROP PROCEDURE IF EXISTS #MyStoredProc
GO
