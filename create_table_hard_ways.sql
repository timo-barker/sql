-- different ways to create keys and relationships
-- with object name specified or with default
-- disable and rebuild indexes (be careful with clustered!)
-- capture output clause and scope_identity

USE MyDatabase;

IF OBJECT_ID('ConstraintsAndKeys','U') IS NOT NULL
    ALTER TABLE ConstraintsAndKeys 
    SET (SYSTEM_VERSIONING=OFF);

DROP TABLE IF EXISTS ConstraintsAndKeys;

DROP TABLE IF EXISTS ConstraintsAndChurrin;

DROP TABLE IF EXISTS KidsAndKeys;

CREATE TABLE ConstraintsAndChurrin
  (
      Id_0 int identity
     ,Id_2 char(36) primary key
  )
WITH (DATA_COMPRESSION=ROW);

CREATE TABLE KidsAndKeys
  (
      Id_0 int identity
     ,Id_3 float primary key
  )
WITH (DATA_COMPRESSION=PAGE);

CREATE TABLE ConstraintsAndKeys
  (
      Id_1 int identity --not null
     ,Id_2 char(36)
     ,Id_3 float FOREIGN KEY REFERENCES KidsAndKeys (Id_3)
     ,userId varchar(50) --not null --default original_login()
     ,userDateTime datetime --not null
   --,PRIMARY KEY CLUSTERED /*NONCLUSTERED*/ (Id_1)
   --     WITH (PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF, IGNORE_DUP_KEY=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON) 
   --     ON [PRIMARY]
     ,ValidFrom datetime2 GENERATED ALWAYS AS ROW START NOT NULL
     ,ValidTo datetime2 GENERATED ALWAYS AS ROW END NOT NULL
     ,PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
     ,CONSTRAINT PX_dbo_ConstraintsAndKeys_Id_1 PRIMARY KEY /*CLUSTERED*/ NONCLUSTERED (Id_1)
     ,UNIQUE NONCLUSTERED (Id_2)
     ,UNIQUE (Id_1, Id_2)
     ,CONSTRAINT UQ_dbo_ConstraintsAndKeys_Id_2 UNIQUE NONCLUSTERED (Id_2)
     ,INDEX IX_dbo_ConstraintsAndKeys_userDateTime NONCLUSTERED (userDateTime)
  )
WITH (SYSTEM_VERSIONING=ON);

ALTER TABLE ConstraintsAndKeys 
ADD DEFAULT original_login() FOR userId;

ALTER TABLE ConstraintsAndKeys 
ADD CONSTRAINT CF_dbo_ConstraintsAndKeys_userDateTime DEFAULT getdate() FOR userDateTime;

ALTER TABLE ConstraintsAndKeys WITH CHECK
ADD CONSTRAINT FK_dbo_ConstraintsAndKeys_Id_2 FOREIGN KEY (Id_2)
REFERENCES ConstraintsAndChurrin (Id_2)
ON DELETE CASCADE;

CREATE INDEX IX_dbo_ConstraintsAndKeys_userId
ON ConstraintsAndKeys (userId)
INCLUDE (userDateTime);

--TRUNCATE TABLE ConstraintsAndKeys;

ALTER INDEX ALL ON ConstraintsAndKeys
DISABLE;

ALTER TABLE ConstraintsAndKeys
NOCHECK CONSTRAINT ALL;

    insert into ConstraintsAndChurrin (Id_2)
    select newid();
    
    insert into ConstraintsAndKeys WITH (TABLOCK) (Id_2, Id_3)
    output inserted.Id_3
    into KidsAndKeys (Id_3)
    select Id_2, rand() Id_3
    from ConstraintsAndChurrin
    where Id_0 = scope_identity();

ALTER INDEX ALL ON ConstraintsAndKeys
REBUILD;

ALTER TABLE ConstraintsAndKeys
CHECK CONSTRAINT ALL;

--disable compression
ALTER TABLE ConstraintsAndKeys
REBUILD WITH (DATA_COMPRESSION=NONE);

declare @now datetime2 = sysdatetime();
select * from ConstraintsAndChurrin;
select * from KidsAndKeys;
select * from ConstraintsAndKeys FOR SYSTEM_TIME AS OF @now;
