--============================================================================--
-- Assigns the next alphabet letter for each payroll period. Assumes payroll 
-- periods are 26x a year, and uses all 26 letters. Uses the ISO standard for 
-- determining the week (week begins on Monday), and year may sometimes include 
-- 53 weeks. Week 53 overlap into next year. Week 1 may not begin on Jan 1.
--============================================================================--
WITH cte_dDate AS
  (
   SELECT DATEADD(YEAR,DATEDIFF(YEAR,0,CURRENT_TIMESTAMP)-1,0) AS dDay
   UNION ALL
   SELECT DATEADD(DAY,1,dDay) AS dDay
   FROM cte_dDate
   WHERE dDay < DATEADD(DAY,-1,DATEADD(YEAR,DATEDIFF(YEAR,0,CURRENT_TIMESTAMP)+2,0))
  )
SELECT
    CAST(dDay AS DATE) AS dDay
   ,SUBSTRING(DATENAME(WEEKDAY,dDay),1,3) AS DayDesc
   ,DATENAME(ISO_WEEK,dDay) AS ISOweek
   ,CHAR(65+((51+0.5+CAST(DATENAME(ISO_WEEK,dDay) AS INT)*0.5)%26)) AS WeekLetter
FROM cte_dDate
ORDER BY dDay
OPTION (MAXRECURSION 1096);