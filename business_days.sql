WITH cte_dDate AS
  (
   SELECT CAST(0 AS BIGINT) AS ID
   UNION ALL
   SELECT ID + 86400000
   FROM cte_dDate
   WHERE ID < 2147472000000
  )
,cte_Lookup AS
  (
   SELECT
       ID = ID / 1000
      ,FullDate = CAST(DATEADD(SECOND,ID/1000,'19700101') AS DATE)
      ,BusinessDayFlag = CAST(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                   THEN 0
                                   ELSE 1
                                   END AS BIT)
      ,DayDesc = DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101'))
      ,HolidayFlag = 0
   FROM cte_dDate
  )
SELECT FullDate       = FORMAT(dd.FullDate,'ddd yyy-MM-dd')
      ,PriorBusDay    = FORMAT((SELECT MAX(pbd.FullDate) AS PriorBusDay
                                FROM cte_Lookup AS pbd
                                WHERE pbd.FullDate < dd.FullDate
                                  AND DayDesc NOT IN ('Saturday','Sunday')
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
      ,PriorWorkDay   = FORMAT((SELECT MAX(pwd.FullDate) AS PriorWorkDay
                                FROM cte_Lookup AS pwd
                                WHERE pwd.FullDate < dd.FullDate
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
      ,CurrentBusDay  = FORMAT((SELECT MAX(cbd.FullDate) AS CurrentBusDay
                                FROM cte_Lookup AS cbd
                                WHERE cbd.FullDate <= dd.FullDate
                                  AND DayDesc NOT IN ('Saturday','Sunday')
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
      ,CurrentWorkDay = FORMAT((SELECT MAX(cwd.FullDate) AS CurrentWorkDay
                                FROM cte_Lookup AS cwd
                                WHERE cwd.FullDate <= dd.FullDate
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
      ,NextBusDay     = FORMAT((SELECT MIN(nbd.FullDate) AS NextBusDay
                                FROM cte_Lookup AS nbd
                                WHERE nbd.FullDate > dd.FullDate
                                  AND DayDesc NOT IN ('Saturday','Sunday')
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
      ,NextWorkDay = FORMAT((SELECT MIN(nwd.FullDate) AS NextWorkDay
                                FROM cte_Lookup AS nwd
                                WHERE nwd.FullDate > dd.FullDate
                                  AND BusinessDayFlag = 1
                                  AND HolidayFlag = 0),'ddd yyy-MM-dd')
FROM cte_Lookup AS dd
OPTION (MAXRECURSION 24856);
