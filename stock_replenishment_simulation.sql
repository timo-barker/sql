-- https://www.reddit.com/r/SQL/comments/sz1fsd/cursorloop_through_each_row_for_cumulative_total/
-- 
-- Cursor/loop through each row for cumulative total on inventory
-- 
-- Hello everyone,
-- I need help with the cumulative total on inventory from three tables below,
-- After Demands consume all the inventory and before Inventory falls below zero, the first next 
-- purchase order comes in to meet the next requirement until the RUNNING_Total is greater than zero.
-- I want the output to look like this:
-- 
-- |PART_ID  |TYPE     |REQUIRED_DATE|INV|D_QTY|S_QTY|RUNNING_TOTAL|
-- |!--      |!--      |!--          |--!|  --!|  --!|          --!|
-- |Product A|Inventory|1900-01-01   |500|     |     |          500|
-- |Product A|Demand   |2021-09-30   |   |  154|     |          346|
-- |Product A|Demand   |2021-10-18   |   |  110|     |          236|
-- |Product A|Demand   |2021-10-27   |   |   64|     |          172|
-- |Product A|Demand   |2021-11-10   |   |   65|     |          107|
-- |Product A|Supply   |2021-10-01   |   |     |   20|          127|
-- |Product A|Demand   |2021-12-28   |   |  120|     |            7|
-- |Product A|Supply   |2022-01-03   |   |     |   30|           37|
-- |Product A|Supply   |2022-02-01   |   |     |  200|          237|
-- |Product A|Demand   |2022-01-26   |   |  120|     |          117|
-- |Product A|Demand   |2022-02-26   |   |   50|     |           67|
-- |Product A|Supply   |2022-03-01   |   |     |  200|          267|
-- |Product A|Supply   |2022-04-01   |   |     |  200|          467|

DROP TABLE IF EXISTS INVT;
CREATE TABLE INVT (ID int, PART_ID varchar(10),TYPE varchar(15),AVA_QTY int,REQUIRED_DATE datetime)
INSERT INTO INVT (ID, PART_ID ,TYPE ,AVA_QTY ,REQUIRED_DATE)
VAlUES
( '1','Product A', 'Inventory', '500', NULL);

DROP TABLE IF EXISTS DEMANDT;
CREATE TABLE DEMANDT (ID int, PART_ID varchar(10),TYPE varchar(15),REQ_QTY int,REQUIRED_DATE datetime)
INSERT INTO DEMANDT (ID, PART_ID ,TYPE ,REQ_QTY ,REQUIRED_DATE)
VAlUES
( '1','Product A', 'Demand', '154', '9/30/2021'),
( '2','Product A', 'Demand', '110', '10/18/2021'),
( '3','Product A', 'Demand', '64', '10/27/2021'),
( '4','Product A', 'Demand', '65', '11/10/2021'),
( '5','Product A', 'Demand', '120', '12/28/2021'),
( '6','Product A', 'Demand', '120', '1/26/2022'),
( '7','Product A', 'Demand', '50', '2/26/2022');

DROP TABLE IF EXISTS SUPPLYT;
CREATE TABLE SUPPLYT (ID int, PART_ID varchar(10),TYPE varchar(15),PO_NUM varchar(15),PO_DATE datetime,ORDER_QTY int);
INSERT INTO SUPPLYT (ID, PART_ID ,TYPE,PO_NUM ,PO_DATE,ORDER_QTY)
VAlUES
( '1','Product A', 'Supply', 'PO1', '10/1/2021', '20'),
( '2','Product A', 'Supply', 'PO2', '1/3/2022', '30'),
( '3','Product A', 'Supply', 'PO3', '2/1/2022', '200'),
( '4','Product A', 'Supply', 'PO4', '3/1/2022', '200'),
( '5','Product A', 'Supply', 'PO5', '4/1/2022', '200');

-- METHOD 1: RECURSIVE CTE AND CROSS APPLY

WITH Total AS
(
    SELECT
        PART_ID,
        TYPE,
        REQUIRED_DATE,
        AVA_QTY AS INV,
        NULL AS D_QTY,
        NULL AS S_QTY,
        AVA_QTY AS RUNNING_TOTAL,
        1 AS OrderField,
        CAST(0 AS BIGINT) AS DemandRowNum,
        CAST(0 AS BIGINT) AS SupplyRowNum
    FROM INVT

    UNION ALL

    SELECT
        Total.PART_ID,
        COALESCE(t1.TYPE, t2.TYPE),
        COALESCE(t1.REQUIRED_DATE, t2.PO_DATE),
        NULL,
        t1.REQ_QTY,
        t2.ORDER_QTY,
        RUNNING_TOTAL + COALESCE(-(t1.REQ_QTY), t2.ORDER_QTY),
        OrderField + 1,
        COALESCE(t1.ID, Total.DemandRowNum),
        COALESCE(t2.ID, Total.SupplyRowNum)
    FROM Total
    OUTER APPLY 
    (
        SELECT *
        FROM DEMANDT
        WHERE Total.PART_ID = DEMANDT.PART_ID
        AND (DEMANDT.ID - 1) = Total.DemandRowNum
        AND RUNNING_TOTAL >= DEMANDT.REQ_QTY
    ) t1
    OUTER APPLY
    (
        SELECT *
        FROM SUPPLYT
        WHERE Total.PART_ID = SUPPLYT.PART_ID
        AND (SUPPLYT.ID - 1) = Total.SupplyRowNum
        AND t1.ID IS NULL
    ) t2
    WHERE t1.ID IS NOT NULL
    OR t2.ID IS NOT NULL
)
SELECT
    PART_ID,
    TYPE,
    TRY_CAST(COALESCE(CAST(REQUIRED_DATE AS DATE), '1900-01-01') as date) AS REQUIRED_DATE,
    CASE
        WHEN INV IS NOT NULL
        THEN CAST(INV AS VARCHAR(MAX))
        ELSE ''
    END AS INV,
    CASE
        WHEN D_QTY IS NOT NULL
        THEN CAST(D_QTY AS VARCHAR(MAX))
        ELSE ''
    END AS D_QTY,
    CASE
        WHEN S_QTY IS NOT NULL
        THEN CAST(S_QTY AS VARCHAR(MAX))
        ELSE ''
    END AS S_QTY,
    RUNNING_TOTAL
FROM Total
ORDER BY
    PART_ID,
    OrderField

-- METHOD 2: WHILE LOOP, IF EXPRESSION, AND VIEW OBJECT

DROP TABLE IF EXISTS INVENTORYT;
CREATE TABLE INVENTORYT (ID int identity, PART_ID varchar(10), 
TYPE varchar(15), REQUIRED_DATE date, INV int, D_QTY int, S_QTY int);

DROP VIEW IF EXISTS INVENTORYV;
GO
CREATE VIEW INVENTORYV WITH SCHEMABINDING AS 
 SELECT PART_ID, TYPE, REQUIRED_DATE, INV, D_QTY, S_QTY
 , SUM(ISNULL(INV,0)) OVER(PARTITION BY PART_ID ORDER BY ID) 
 - SUM(ISNULL(D_QTY,0)) OVER(PARTITION BY PART_ID ORDER BY ID) 
 + SUM(ISNULL(S_QTY,0)) OVER(PARTITION BY PART_ID ORDER BY ID) 
 AS RUNNING_TOTAL
 FROM dbo.INVENTORYT
 ORDER BY ID
 OFFSET 0 ROWS;
GO

INSERT INTO INVENTORYT (PART_ID, TYPE, REQUIRED_DATE, INV)
SELECT TOP 1 PART_ID, TYPE, '1/1/1900', AVA_QTY 
FROM INVT AS I
WHERE NOT EXISTS 
 (
  SELECT I.PART_ID, I.TYPE, CAST('1/1/1900' AS DATE)
  INTERSECT
  SELECT PART_ID, TYPE, REQUIRED_DATE FROM INVENTORYV
 )
ORDER BY ID;

WHILE (SELECT COUNT(*) FROM INVT)
    + (SELECT COUNT(*) FROM DEMANDT)
    + (SELECT COUNT(*) FROM SUPPLYT)
    - ISNULL((SELECT COUNT(*) FROM INVENTORYT),0)
    > 0
 BEGIN
  IF (
      SELECT RUNNING_TOTAL
      FROM INVENTORYV 
      ORDER BY (SELECT NULL)
      OFFSET (SELECT COUNT(*)-1 FROM INVENTORYV) ROWS 
      FETCH NEXT 1 ROWS ONLY
     ) >
     (
      SELECT TOP 1 REQ_QTY 
      FROM DEMANDT AS D
      WHERE NOT EXISTS 
        (
         SELECT D.PART_ID, D.TYPE, D.REQUIRED_DATE
         INTERSECT
         SELECT PART_ID, TYPE, REQUIRED_DATE FROM INVENTORYV
        )
      ORDER BY ID
     )
   BEGIN
    INSERT INTO INVENTORYT (PART_ID, TYPE, REQUIRED_DATE, D_QTY)
    SELECT TOP 1 PART_ID, TYPE, REQUIRED_DATE, REQ_QTY
    FROM DEMANDT AS D
    WHERE NOT EXISTS 
      (
       SELECT D.PART_ID, D.TYPE, D.REQUIRED_DATE
       INTERSECT
       SELECT PART_ID, TYPE, REQUIRED_DATE FROM INVENTORYV
      )
    ORDER BY ID
   END
  ELSE
   BEGIN
    INSERT INTO INVENTORYT (PART_ID, TYPE, REQUIRED_DATE, S_QTY)
    SELECT TOP 1 PART_ID, TYPE, PO_DATE, ORDER_QTY
    FROM SUPPLYT AS S
    WHERE NOT EXISTS 
      (
       SELECT S.PART_ID, S.TYPE, S.PO_DATE
       INTERSECT
       SELECT PART_ID, TYPE, REQUIRED_DATE FROM INVENTORYV
      )
    ORDER BY ID
   END
 END;

SELECT * FROM INVENTORYV;