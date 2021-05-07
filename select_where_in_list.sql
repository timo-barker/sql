--============================================================================--
-- from https://www.youtube.com/watch?v=6R_cZqKYCKQ&t=190s
--============================================================================--

SET STATISTICS IO, TIME ON;

DROP TABLE IF EXISTS #test;

CREATE TABLE #test
  (
    ID        INT IDENTITY
   ,FirstName NVARCHAR(100)
   ,LastName  NVARCHAR(100)
   ,PRIMARY KEY (ID)
  );
GO

INSERT INTO #test
  (
    FirstName
   ,LastName
  )
VALUES
  ('Mark'   ,'Male'  )
 ,('John'   ,'Male'  )
 ,('Sara'   ,'Female')
 ,('Valarie','Female')
 ,('David'  ,'Male'  )
 ,('Ellie'  ,'Female')
 ,('Todd'   ,'Male'  );

DECLARE @FirstNames NVARCHAR(100) = 'Mark,John,Sara';

SELECT *
FROM #test
WHERE FirstName IN ('Mark','John','Sara');
--Estimated Subtree Cost: 0.0032831

SELECT *
FROM string_split(@FirstNames,',');
--Estimated Subtree Cost: 0.0000502

SELECT *
FROM #test
WHERE FirstName IN (
                    SELECT value
                    FROM string_split(@FirstNames,',')
                   );
--Estimated Subtree Cost: 0.0033924

SELECT #test.*
FROM #test
    INNER JOIN string_split(@FirstNames,',') split
        ON #test.FirstName = split.value;
--Estimated Subtree Cost: 0.0040148

SET STATISTICS IO, TIME OFF;