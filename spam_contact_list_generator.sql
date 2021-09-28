DECLARE @Contact VARCHAR(128) = 'SPAM';
DECLARE @AreaCode BIGINT = 860;
DECLARE @PhoneList BIGINT = CASE WHEN @AreaCode > 200
                                  AND @AreaCode < 999
                                 THEN (@AreaCode * 10000000) + 2000000 - 1
                                 END;
DROP TABLE IF EXISTS #ContactList
CREATE TABLE #ContactList 
  (
    RowID INT IDENTITY
   ,CSV VARCHAR(358)
  )
INSERT INTO #ContactList (CSV)
VALUES ('Name,Given Name,Additional Name,Family Name,Yomi Name,Given Name Yomi,Additional Name Yomi,Family Name Yomi,Name Prefix,Name Suffix,Initials,Nickname,Short Name,Maiden Name,Birthday,Gender,Location,Billing Information,Directory Server,Mileage,Occupation,Hobby,Sensitivity,Priority,Subject,Notes,Language,Photo,Group Membership,Phone 1 - Type,Phone 1 - Value')
;
WITH 
     t10 AS (SELECT n FROM (VALUES(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) t(n))
    ,t1k AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS num 
             FROM t10 AS a 
             CROSS JOIN t10 AS b 
             CROSS JOIN t10 AS c
             CROSS JOIN t10 AS d
             CROSS JOIN t10 AS e
             CROSS JOIN t10 AS f
             CROSS JOIN t10 AS g)
INSERT INTO #ContactList (CSV)            
SELECT @Contact + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,' + @Contact + ',,' + CAST(@PhoneList + num AS varchar(10))
FROM t1k;

SELECT CSV
FROM #ContactList
WHERE RowID <= 8000001
ORDER BY RowID;
