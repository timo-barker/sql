--sauce: https://mattboegner.com/improve-your-sql-skills-master-the-gaps-islands-problem/

DECLARE @daily_production TABLE
  (
    Date DATE
   ,Widget_Type CHAR(1)  
   ,Daily_Production INT
  );

INSERT INTO @daily_production (Date, Widget_Type, Daily_Production)
VALUES ('20191201','A',30)
      ,('20191202','A',30)
      ,('20191203','A',15)
      ,('20191204','A',11)
      ,('20191205','A',18)
      ,('20191206','A',30)
      ,('20191207','A',30)
      ,('20191208','A', 0)
      ,('20191209','A', 0)
      ,('20191210','A', 0)
      ,('20191211','A', 0)
      ,('20191212','A',30)
      ,('20191213','A',30)
      ,('20191214','A',10)
      ,('20191215','A',19)
      ,('20191216','A',30);

WITH cte_daily_production AS (
    SELECT
        widget_type
        , date
        , CASE
            WHEN daily_production >= 20 THEN 'Full Capacity'
            WHEN daily_production < 20 THEN 'Downtime'
            END AS status
    FROM @daily_production
),
rankings AS (
    SELECT
        widget_type
        , date
        , status
        , DENSE_RANK() OVER (PARTITION BY widget_type ORDER BY date) /* ranking by the key */
        - DENSE_RANK() OVER (PARTITION BY widget_type, status ORDER BY date) /* ranking by the key-value pair*/
            AS sequence_grouping
    FROM cte_daily_production
  --ORDER BY date ASC
)
SELECT
    widget_type
    , MIN(date) as start_date
    , MAX(date) as end_date
    , DATEDIFF(day,MIN(date), MAX(date)) + 1 as duration
FROM rankings
WHERE status = 'Downtime'
GROUP BY
    widget_type
    , sequence_grouping 

DECLARE @daily_goal TABLE
   (
    Date DATE
   ,Widget_Type CHAR(1)  
   ,Daily_Goal INT
  );

INSERT INTO @daily_goal (Date, Widget_Type, Daily_Goal)
VALUES ('20191208','A', 30)
      ,('20191208','B', 45)
      ,('20191208','C',100)
      ,('20191209','A', 30)
      ,('20191209','B',  0)
      ,('20191209','C',100)
      ,('20191210','A', 30)
      ,('20191210','B',  0)
      ,('20191210','C',150)
      ,('20191211','A', 30)
      ,('20191211','B', 45)
      ,('20191211','C',150)
      ,('20191212','A', 30)
      ,('20191212','B', 45)
      ,('20191213','C',150)
      ,('20191213','A', 30)
      ,('20191214','B', 45)
      ,('20191214','C',150);

WITH result AS (
    SELECT
        widget_type
        , daily_goal
        , MIN(date) AS valid_From
        , MAX(date) AS valid_to
    FROM (
        SELECT
           widget_type
            , date
            , daily_goal
            , DENSE_RANK() OVER (PARTITION BY widget_type ORDER BY date)
                - DENSE_RANK() OVER (partition by widget_type, daily_goal ORDER BY date) AS sequence_grouping
        FROM @daily_goal
        ) subquery
    GROUP BY widget_type,
        daily_goal,
        sequence_grouping
)
SELECT
    widget_type
    , daily_goal
    , CASE WHEN DENSE_RANK() OVER (PARTITION BY widget_type ORDER BY valid_from ASC) = 1 THEN '1900-01-01'
        ELSE valid_from END AS valid_from
    , CASE WHEN DENSE_RANK() OVER (PARTITION BY widget_type ORDER BY valid_to DESC) = 1 THEN '9999-12-31'
        ELSE valid_to END AS valid_to
    , CASE WHEN DENSE_RANK() OVER (PARTITION BY widget_type ORDER BY valid_to DESC) = 1 THEN 1
        ELSE 0 END AS is_current
FROM result
ORDER BY widget_type ASC, valid_from ASC   