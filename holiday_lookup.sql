DECLARE @dHoliday AS TABLE
  (
    ID              INT
   ,DateKey         INT
   ,FullDate        DATE
   ,BusinessDayFlag BIT
   ,HolidayFlag     BIT
   ,HolidayDesc     VARCHAR(50)
   ,YY              AS YEAR(FullDate)
   ,MM              AS MONTH(FullDate)
   ,DD              AS DAY(FullDate)
   ,DW              AS DATEDIFF(DAY,0,FullDate)%7+1
   ,WM              TINYINT
  );

WITH cte_dDate AS
  (
   SELECT CAST(0 AS BIGINT) AS ID
   UNION ALL
   SELECT ID + 86400000
   FROM cte_dDate
   WHERE ID < 2147472000000
  )
INSERT INTO @dHoliday
  (
    ID
   ,DateKey
   ,FullDate
  )
SELECT
    ID = ID / 1000
   ,DateKey = CAST(CONCAT(DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                  ,RIGHT(CONCAT('0',DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101'))),2)
                  ,RIGHT(CONCAT('0',DATEPART(DAY,DATEADD(SECOND,ID/1000,'19700101'))),2)) AS INT)
   ,FullDate = CAST(DATEADD(SECOND,ID/1000,'19700101') AS DATE)
FROM cte_dDate
OPTION (MAXRECURSION 24856);

UPDATE tgt
SET WM = WM2
FROM (
      SELECT WM, WM2 = ROW_NUMBER() OVER(PARTITION BY YY,MM,DW
                                                   ORDER BY FullDate)
      FROM @dHoliday
     ) tgt;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'New Year''s Day'
WHERE MM = 1
  AND DD = 1;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Martin Luther King Jr. Day'
WHERE YY >= 1986
  AND MM = 1
  AND DW = 1
  AND WM = 3;

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Valentine''s Day'
WHERE MM = 2
  AND DD = 14;

UPDATE @dHoliday
SET BusinessDayFlag = 1
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Presidents'' Day'
WHERE MM = 2
  AND DW = 1
  AND WM = 3;

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'St. Patrick''s Day'
WHERE MM = 3
  AND DD = 17;

DECLARE @a TINYINT ,@b TINYINT ,@c TINYINT
       ,@d TINYINT ,@e TINYINT ,@f TINYINT
       ,@g TINYINT ,@h TINYINT ,@i TINYINT
       ,@j TINYINT ,@k TINYINT ,@l TINYINT
       ,@m TINYINT ,@x DATE;
DECLARE @y INT = YEAR('19700101');
DECLARE @Easter AS TABLE (EasterDT DATE);

WHILE @y <= 2079
BEGIN
    SELECT @a = @y%19, @b = FLOOR(1.0*@y/100), @c = @y%100;
    SELECT @d = FLOOR(1.0*@b/4), @e = @b%4, @f = FLOOR((8.0+@b)/25);
    SELECT @g = FLOOR((1.0+@b-@f)/3);
    SELECT @h = (19*@a+@b-@d-@g+15)%30, @i = FLOOR(1.0*@c/4), @j = @c%4;
    SELECT @k = (32.0+2*@e+2*@i-@h-@j)%7;
    SELECT @l = FLOOR((1.0*@a+11*@h+22*@k)/451);
    SELECT @m = (@h+@k-7*@l+114)
    SELECT @x = DATEFROMPARTS(@y,@m/31,(@m%31)+1)
    INSERT INTO @Easter (EasterDT) SELECT @x;
    SELECT @y = @y+1;
END;

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Easter'
WHERE FullDate IN (
                   SELECT EasterDT
                   FROM @Easter
                  );

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Cinco de Mayo'
WHERE MM = 5
  AND DD = 5;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Mother''s Day'
WHERE MM = 5
  AND DW = 7
  AND WM = 2;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Memorial Day'
WHERE FullDate IN (
                   SELECT DATEADD(WEEK,-1,FullDate)
                   FROM @dHoliday
                   WHERE MM = 6
                     AND DW = 1
                     AND WM = 1
                  );

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Father''s Day'
WHERE MM = 6
  AND DW = 7
  AND WM = 3;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Independence Day'
WHERE MM = 7
  AND DD = 4;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Labor Day'
WHERE MM = 9
  AND DW = 1
  AND WM = 1;

UPDATE @dHoliday
SET BusinessDayFlag = 1
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Columbus Day'
WHERE YY >= 1971
  AND MM = 10
  AND DW = 1
  AND WM = 2;

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Halloween'
WHERE MM = 10
  AND DD = 31;

UPDATE @dHoliday
SET BusinessDayFlag = 1
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Election Day'
WHERE FullDate IN (
                   SELECT DATEADD(DAY,1,FullDate)
                   FROM @dHoliday
                   WHERE MM = 11
                     AND DW = 1
                     AND WM = 1
                  );

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Veterans Day'
WHERE MM = 11
  AND DD = 11;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Thanksgiving Day'
WHERE MM = 11
  AND DW = 4
  AND WM = 4;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Black Friday'
WHERE FullDate IN (
                   SELECT DATEADD(DAY,1,FullDate)
                   FROM @dHoliday
                   WHERE MM = 11
                     AND DW = 4
                     AND WM = 4
                  );

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'Christmas Eve'
WHERE MM = 12
  AND DD = 24;

UPDATE @dHoliday
SET BusinessDayFlag = 0
   ,HolidayFlag     = 1
   ,HolidayDesc     = 'Christmas Day'
WHERE MM = 12
  AND DD = 25;

UPDATE @dHoliday
SET BusinessDayFlag = CASE WHEN DW IN (6,7) THEN 0 ELSE 1 END
   ,HolidayFlag     = 0
   ,HolidayDesc     = 'New Year''s Eve'
WHERE MM = 12
  AND DD = 31;

DELETE FROM @dHoliday
WHERE HolidayDesc IS NULL;

SELECT
    ID
   ,DateKey
   ,FullDate
   ,BusinessDayFlag
   ,HolidayFlag
   ,HolidayDesc
FROM @dHoliday
ORDER BY ID;
