DROP TABLE IF EXISTS CustomerCreditLimits;
GO

CREATE TABLE CustomerCreditLimits (
  Id int Identity(1,1) not null,
  CustomerId int,
  CreditLimit int,
  UpdatedDateTime datetime2 default sysdatetime() not null,
  UpdatedBy varchar(100) default original_login() not null
)
GO

DROP TABLE IF EXISTS CustomerCreditLimitsHistory
GO

CREATE TABLE CustomerCreditLimitsHistory (
  HistoryId int Identity(1,1),
  ReferenceId int,
  CustomerId int,
  CreditLimit int,
  ValidFrom datetime2,
  ValidTo datetime2,
  UserId varchar(100)
)
GO

CREATE TRIGGER dbo.LogCustomerCreditLimitInsert
    ON dbo.CustomerCreditLimits
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON
SET ROWCOUNT 0
SET XACT_ABORT ON
BEGIN TRY
    INSERT INTO dbo.CustomerCreditLimits (CustomerId, CreditLimit)
    SELECT CustomerId, CreditLimit FROM inserted
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH
END
GO

CREATE TRIGGER dbo.LogCustomerCreditLimitUpdate
    ON dbo.CustomerCreditLimits
INSTEAD OF UPDATE
AS
BEGIN
SET NOCOUNT ON
SET ROWCOUNT 0
SET XACT_ABORT ON
BEGIN TRY
    UPDATE dbo.CustomerCreditLimits
    SET CustomerId = i.CustomerId, 
        CreditLimit = i.CreditLimit,
        UpdatedDateTime = sysdatetime(),
        UpdatedBy = original_login()
    FROM dbo.CustomerCreditLimits inner join inserted i on CustomerCreditLimits.CustomerId = i.CustomerId
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH
END
GO

CREATE TRIGGER dbo.LogCustomerCreditLimitHistory
    ON dbo.CustomerCreditLimits
AFTER UPDATE, DELETE
AS
BEGIN
SET NOCOUNT ON
SET ROWCOUNT 0
SET XACT_ABORT ON
BEGIN TRY
IF EXISTS (
  SELECT * FROM Inserted
)
  INSERT INTO CustomerCreditLimitsHistory (
    ReferenceId,
    CustomerId,
    CreditLimit,
    ValidFrom,
    ValidTo,
    UserId
  )
  SELECT
    d.Id,
    d.CustomerId,
    d.CreditLimit,
    d.UpdatedDateTime,
   i.UpdatedDateTime AS ValidTo,
    original_login() as UserID
  FROM Deleted d
  INNER JOIN Inserted i ON i.Id = d.Id
ELSE
  INSERT INTO CustomerCreditLimitsHistory (
    ReferenceId,
    CustomerId,
    CreditLimit,
    ValidFrom,
    ValidTo,
    UserId
  )
  SELECT
    d.Id,
    d.CustomerId,
    d.CreditLimit,
    d.UpdatedDateTime,
    isnull(i.UpdatedDateTime,sysdatetime()) as ValidTo,
    original_login()
  FROM Deleted d left join Inserted i on d.CustomerId = i.CustomerId
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH
END
GO

INSERT INTO CustomerCreditLimits (
  CustomerId, CreditLimit, UpdatedDateTime, UpdatedBy
) VALUES (
  100, 20000, '20100101', 3
), (
  200, 30000, '20200101', 3
)
GO

WAITFOR DELAY '00:00:01'
GO

INSERT INTO CustomerCreditLimits (
  CustomerId, CreditLimit, UpdatedDateTime, UpdatedBy
) VALUES (
  300, 40000, '20150101', 3
)
GO

SELECT * FROM CustomerCreditLimits
SELECT * FROM CustomerCreditLimitsHistory
GO

waitfor delay '00:00:01'
GO

UPDATE CustomerCreditLimits
SET 
  CreditLimit = 50000
WHERE CustomerId >= 200
GO

SELECT * FROM CustomerCreditLimits
SELECT * FROM CustomerCreditLimitsHistory
GO

waitfor delay '00:00:01'
GO

DELETE CustomerCreditLimits WHERE CustomerId in (100,300)
GO

waitfor delay '00:00:01'
GO

DELETE CustomerCreditLimits 
GO

SELECT * FROM CustomerCreditLimits
SELECT * FROM CustomerCreditLimitsHistory
GO

DROP TABLE IF EXISTS CustomerCreditLimits;
GO

DROP TABLE IF EXISTS CustomerCreditLimitsHistory
GO
