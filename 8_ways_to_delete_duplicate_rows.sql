DROP TABLE IF EXISTS #TableA;

CREATE TABLE #TableA
  (
    ID    INT IDENTITY PRIMARY KEY
   ,Value INT
  );

INSERT INTO #TableA (Value)
OUTPUT inserted.*
VALUES (1),(2),(3),(4),(5),(5),(3),(5);


-- METHOD 1

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);


WITH b (ID, Value) AS
  (
   SELECT ID, (
               SELECT MAX(Value)
               FROM #TableA i
               WHERE o.Value = i.Value
               GROUP BY i.Value
               HAVING o.ID = MAX(i.ID)
              )
   FROM #TableA o
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a, b
WHERE a.ID = b.ID
AND b.Value IS NULL;


-- METHOD 2

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b (ID, Value) AS
  (
   SELECT MAX(ID), Value
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
            GROUP BY b.Value
            HAVING COUNT(*) > 1
           );


-- METHOD 4

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b (ID, Rnk) AS
  (
   SELECT ID, RANK() OVER(PARTITION BY Value
                          ORDER BY ID DESC)
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

WITH b (ID, Value) AS
  (
   SELECT ID, (
               SELECT MAX(Value)
               FROM #TableA i
               WHERE o.Value = i.Value
               GROUP BY i.Value
               HAVING o.ID < MAX(i.ID)
              )
   FROM #TableA o
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a, b
WHERE a.ID = b.ID
AND b.Value IS NOT NULL;


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

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b (Value, row) AS
  (
   SELECT Value, ROW_NUMBER() OVER(PARTITION BY Value
                                   ORDER BY (SELECT NULL))
   FROM #TableA
  )
DELETE
FROM b
OUTPUT deleted.*
WHERE b.row > 1;


-- METHOD 8

TRUNCATE TABLE #TableA;

INSERT INTO #TableA (Value)
VALUES (1),(2),(3),(4),(5),(5),(3),(5);

WITH b (Value, row) AS
  (
   SELECT Value, MAX(%%lockres%%)
   FROM #TableA
   GROUP BY Value
  )
DELETE a
OUTPUT deleted.*
FROM #TableA a
INNER JOIN b
ON a.Value = b.Value
WHERE a.%%lockres%% <> b.row;
