-- Gaussian (or Normally) Distributed Random Number generator

DECLARE @mean  FLOAT = 0
       ,@stdev FLOAT = 1./3
       ,@urn1  FLOAT
       ,@urn2  FLOAT;
DECLARE @test TABLE 
  (
    urn1 FLOAT
   ,urn2 FLOAT
   ,nurn FLOAT
  );
DECLARE @i INT = 1;

WHILE @i <= 10000
BEGIN
    SET @urn1 = RAND(); --2.9834919491E-06;
    SET @urn2 = RAND(); --0.999997016508051;
    INSERT INTO @test (urn1, urn2, nurn)
    SELECT @urn1 AS urn1, @urn2 AS urn2, (@stdev * SQRT(-2 * LOG(@urn1))*COS(2*ACOS(-1.)*@urn2)) + @mean AS nurn;
    SET @i += 1;
END;

SELECT 
    CAST(MIN(nurn) AS DECIMAL(5,4)) AS MIN
   ,CAST(MAX(nurn) AS DECIMAL(5,4)) AS MAX
   ,CAST(AVG(nurn) AS DECIMAL(5,4)) AS MEAN
   ,CAST(STDEV(nurn) AS DECIMAL(5,4)) AS SD
   ,FORMAT(COUNT(nurn),'##0') AS COUNT
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -1*@stdev AND +1*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [1σ]
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -2*@stdev AND +2*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [2σ]
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -3*@stdev AND +3*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [3σ]
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -4*@stdev AND +4*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [4σ]
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -5*@stdev AND +5*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [5σ]
   ,FORMAT(SUM(CASE WHEN nurn BETWEEN -6*@stdev AND +6*@stdev THEN 1 ELSE 0 END) * 1. / COUNT(nurn),'##0.00%') AS [6σ]
FROM @test;
