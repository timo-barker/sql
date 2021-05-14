DECLARE @MinMax AS TABLE
  (
    a FLOAT
   ,b FLOAT
   ,min AS a - ( ABS(a-b) + (a-b) ) / 2 
   ,max AS a + ( ABS(b-a) + (b-a) ) / 2 
  );

DECLARE @c INT = 0
WHILE @c < 100
BEGIN
    SET @c += 1
    INSERT INTO @MinMax (a,b)
    VALUES (ROUND(RAND()*18,0)-9,ROUND(RAND()*18,0)-9)
END

SELECT * FROM @MinMax