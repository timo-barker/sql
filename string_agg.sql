DECLARE @udf_LIST TABLE (ID nvarchar(15));

INSERT INTO @udf_LIST (ID)
VALUES (N'The'),(N'quick'),(N'brown'),(N'fox'),(N'jumps'),(N'over'),(N'the'),(N'lazy'),(N'dog.');

SELECT STUFF((
              SELECT ',' + CAST(ID AS nvarchar(15))
              FROM @udf_LIST
              FOR XML PATH('')
            ),1,1,'');
