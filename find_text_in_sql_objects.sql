-- Look for a text string inside a SQL object
DECLARE @dbList AS TABLE
    (
      ID         INT NOT NULL IDENTITY(1,1) PRIMARY KEY
     ,[DataBase] VARCHAR(128)
    )
;
INSERT INTO @dbList
    (
      [DataBase]
    )
SELECT name
FROM master.sys.databases

;
DECLARE @txtString AS VARCHAR(MAX) = 'ErrorLog'
;
DECLARE @sqlString AS NVARCHAR(MAX)
;
DECLARE @idCount AS INT = (SELECT MIN(ID) FROM @dbList)
;
WHILE @idCount <= (SELECT MAX(ID) FROM @dbList)
BEGIN
    SET @sqlString =  CHAR(13) + CHAR(10) + N'USE ' + (SELECT QUOTENAME([DataBase]) FROM @dbList WHERE ID = @idCount) + CHAR(13) + CHAR(10) + ';' + CHAR(13) + CHAR(10) 
    ;
    SET @sqlString += N'SELECT DB_NAME() AS [Database], o.[type_desc] AS [Type], s.[name] AS [Schema], OBJECT_NAME(o.[object_id]) AS [Object], c.[Text], o.create_date AS Created, o.modify_date AS Modified' + CHAR(13) + CHAR(10)
    ;
    SET @sqlString += N'FROM [sys].[schemas] AS s' + CHAR(13) + CHAR(10) + CHAR(9) + 'INNER JOIN [sys].[objects] AS o' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + 'ON s.[schema_id] = o.[schema_id]' + CHAR(13) + CHAR(10) + CHAR(9) + 'INNER JOIN [sys].[syscomments] AS c' + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + 'ON o.[object_id] = c.id' + CHAR(13) + CHAR(10)
    ;
    SET @sqlString += N'WHERE c.[Text] LIKE ''%' + @txtString + '%''' + CHAR(13) + CHAR(10) + ';'
    ;
    PRINT @sqlString
    ;
    EXECUTE sp_executesql @sqlString
    ;
    SET @idCount += 1
    ;
    IF  @idCount > (SELECT MAX(ID) FROM @dbList)
        BREAK
        ;
    ELSE
        CONTINUE
        ;
END
;