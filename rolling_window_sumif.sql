--============================================================================--
-- sauce: https://www.reddit.com/r/SQL/comments/ih9rrr/tsql_window_partition_based_on_values/
-- T-SQL Window partition based on values
-- Sum the value column in each partition when:
--  1: for a rolling window of only the latest three ids
--  2: beginning from a minimum floor above id 3.
--============================================================================--

DECLARE @temptable TABLE
  (
    id        INT
   ,value     INT
   ,partition INT
   ,window    AS CAST(id as VARCHAR) + ' to ' + CAST(id-3 as VARCHAR)
  );

INSERT INTO @temptable
VALUES (1,1,1),(2,0,1),(4,1,1),(5,0,1),(6,1,1),(3,1,2),(4,0,2),(5,1,2),(8,0,2),(9,1,2);

SELECT t1.partition, t1.id, t1.value, t1.window
    , RequiredValue = ISNULL((SELECT SUM(t2.value)
                              FROM @temptable t2
                              WHERE t2.partition = t1.partition
                                AND t2.id BETWEEN t1.id - 3 AND t1.id
                              HAVING MAX(t2.id) > 3
                             ), 0) 
FROM @temptable t1
ORDER BY t1.partition, t1.id