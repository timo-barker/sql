DROP PROCEDURE IF EXISTS #testprocedure1
GO

CREATE PROCEDURE #testprocedure1
@datasource VARCHAR(16) = NULL
AS
BEGIN
 
DROP TABLE IF EXISTS #t1; 

-- Option 1
IF (@datasource = 'Employee')
EXEC sp_executesql N'
SELECT TOP 10 *
INTO #t1
FROM AdventureWorks.HumanResources.Employee
EXEC #testprocedure2'

-- Option 2
ELSE IF (@datasource = 'Customer')
EXEC sp_executesql N'
SELECT TOP 10 *
INTO #t1
FROM AdventureWorks.Sales.Customer
EXEC #testprocedure2'
 
-- Option 3
ELSE IF (@datasource = 'SalesPerson')
EXEC sp_executesql N'
SELECT TOP 10 *
INTO #t1
FROM AdventureWorks.Sales.SalesPerson
EXEC #testprocedure2'

BEGIN TRY
EXEC #testprocedure2
END TRY
BEGIN CATCH
SELECT @@NESTLEVEL
END CATCH

END
GO

DROP PROCEDURE IF EXISTS #testprocedure2
GO

CREATE PROCEDURE #testprocedure2
AS
SELECT @@NESTLEVEL, * FROM #t1
GO

EXEC #testprocedure1 'Employee'
EXEC #testprocedure1 'Customer'
EXEC #testprocedure1 'SalesPerson'
GO
