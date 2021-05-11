WITH cte_dDate AS
  (
   SELECT CAST(0 AS BIGINT) AS ID
   UNION ALL
   SELECT ID + 86400000
   FROM cte_dDate
   WHERE ID < 2147472000000
  )
SELECT
    ID = ID / 1000
   ,DateKey = CAST(CONCAT(DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                  ,RIGHT(CONCAT('0',DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101'))),2)
                  ,RIGHT(CONCAT('0',DATEPART(DAY,DATEADD(SECOND,ID/1000,'19700101'))),2)) AS INT)
   ,MonthKey = CAST(CONCAT(DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                   ,RIGHT(CONCAT('0',DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101'))),2)) AS INT)
   ,FullDate = CAST(DATEADD(SECOND,ID/1000,'19700101') AS DATE)
   ,BusinessDayFlag = CAST(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                THEN 0
                                ELSE 1
                                END AS BIT)
   ,WeekendDayFlag = CAST(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Saturday','Sunday')
                               THEN 1
                               ELSE 0
                               END AS BIT)
   ,WeekNum = DATEPART(ISO_WEEK,DATEADD(SECOND,ID/1000,'19700101'))
   ,DayDesc = DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101'))
   ,WeekstartDate = CAST(DATEADD(DAY,0-DATEDIFF(DAY,0,DATEADD(SECOND,ID/1000,'19700101')) % 7
                        ,DATEADD(SECOND,ID/1000,'19700101')) AS DATE)
   ,BusDays_YTD = SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                THEN 0
                                ELSE 1
                                END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                                          ORDER BY ID ASC)
   ,BusDays_MTD = SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                THEN 0
                                ELSE 1
                                END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                                                      ,DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101'))
                                          ORDER BY ID ASC)
   ,BusDays_YTDRemain = SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                 THEN 0
                                 ELSE 1
                                 END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101')))
                      - SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                 THEN 0
                                 ELSE 1
                                 END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                                           ORDER BY ID ASC)
   ,BusDays_MTDRemain = SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                 THEN 0
                                 ELSE 1
                                 END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                                                       ,DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101')))
                      - SUM(CASE WHEN DATENAME(WEEKDAY,DATEADD(SECOND,ID/1000,'19700101')) IN ('Sunday')
                                 THEN 0
                                 ELSE 1
                                 END) OVER(PARTITION BY DATEPART(YEAR,DATEADD(SECOND,ID/1000,'19700101'))
                                                       ,DATEPART(MONTH,DATEADD(SECOND,ID/1000,'19700101'))
                                           ORDER BY ID ASC)
FROM cte_dDate
OPTION (MAXRECURSION 24856);
