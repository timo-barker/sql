--============================================================================--
-- Assigns the next alphabet letter for each payroll period. Assumes payroll 
-- periods are 26x a year, and uses all 26 letters. Uses the ISO standard for 
-- determining the week (week begins on Monday), and year may sometimes include 
-- 53 weeks. Week 53 overlap into next year. Week 1 may not begin on Jan 1.
-- Bonus: also assigns a weekly suit and rank from a standard 52-deck card set.
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
   ,CONCAT(CASE ((DATENAME(ISO_WEEK,dDay)-1)%13)+1
                WHEN 1  THEN 'A' -- Ace
                WHEN 10 THEN 'T' -- Ten
                WHEN 11 THEN 'J' -- Jack
                WHEN 12 THEN 'Q' -- Queen
                WHEN 13 THEN 'K' -- King
                ELSE CAST(((DATENAME(ISO_WEEK,dDay)-1)%13)+1 AS CHAR(1))
                END
           ,CASE ((DATENAME(ISO_WEEK,dDay)-1)%4)+1
                WHEN 1 THEN 'C' -- Club
                WHEN 2 THEN 'D' -- Diamond
                WHEN 3 THEN 'H' -- Heart
                WHEN 4 THEN 'S' -- Spade
                END
          ) AS WeeklyCard
FROM cte_dDate
ORDER BY dDay
OPTION (MAXRECURSION 1096);
