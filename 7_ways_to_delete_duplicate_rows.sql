DROP TABLE IF EXISTS #TableA;
DROP TABLE IF EXISTS #TableB;

CREATE TABLE #TableA
  (
    ID    INT IDENTITY PRIMARY KEY
   ,Value INT
  );

CREATE TABLE #TableB
  (
    ID    INT
   ,Value INT
  );

INSERT INTO #TableA (Value)
OUTPUT inserted.*
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

INSERT INTO #TableB (ID,Value)
OUTPUT inserted.*
VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(5,5),(3,3),(5,5);


-- METHOD 1

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);


WITH b AS
  (
   SELECT ID, (
               SELECT MAX(Value)
               FROM #TableA i
               WHERE o.Value = i.Value
               GROUP BY Value
               HAVING o.ID = MAX(i.ID)
              ) AS MaxValue
   FROM #TableA o
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a, b
WHERE a.ID = b.ID
AND b.MaxValue IS NULL;


-- METHOD 2

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b AS
  (
   SELECT MAX(ID) AS ID, Value
   FROM #TableA
   GROUP BY Value
   HAVING COUNT(Value) > 1
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a
INNER JOIN b
ON a.ID < b.ID
AND a.Value = b.Value;


-- METHOD 3

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

DELETE a
OUTPUT deleted.*
FROM #TableA a
WHERE ID < (
            SELECT MAX(ID)
            FROM #TableA b
            WHERE a.Value = b.Value
            GROUP BY Value
            HAVING COUNT(*) > 1
           );


-- METHOD 4

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b AS
  (
   SELECT ID, RANK() OVER(PARTITION BY Value
                          ORDER BY ID DESC) AS rnk
   FROM #TableA
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a
INNER JOIN b
ON a.ID = b.ID
WHERE b.rnk > 1;


-- METHOD 5

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b AS
  (
   SELECT ID, (
               SELECT MAX(Value)
               FROM #TableA i
               WHERE o.Value = i.Value
               GROUP BY Value
               HAVING o.ID < MAX(i.ID)
              ) AS MaxValue
   FROM #TableA o
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a, b
WHERE a.ID = b.ID
AND b.MaxValue IS NOT NULL;


-- METHOD 6

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

DELETE
FROM #TableA
OUTPUT deleted.*
WHERE ID NOT IN (
                 SELECT MAX(ID)
                 FROM #TableA
                 GROUP BY Value
                );


-- METHOD 7

TRUNCATE TABLE #TableB;

INSERT INTO #TableB (ID,Value)
VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(5,5),(3,3),(5,5);

WITH b (ID, Value, row) AS
  (
   SELECT ID, Value, ROW_NUMBER() OVER(PARTITION BY ID, Value
                                       ORDER BY ID, Value)
   FROM #TableB
  )
DELETE
FROM b
OUTPUT deleted.ID, deleted.Value
WHERE b.row > 1;
