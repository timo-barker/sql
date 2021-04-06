-- mean = 0.5
-- standard deviation = 0.1 ... same as 1/POWER(PI(),2)

DECLARE @z_score TABLE
  (
    Z FLOAT
   ,P AS ABS(CAST(Z AS DECIMAL(1,0))-0.5*POWER(EXP(1),-1*(POWER((Z-0.5)-(1/2),2)/POWER(2*(1/POWER(PI(),2)),2))))
  );
INSERT INTO @z_score (Z)
VALUES (.0),(.1),(.2),(.3),(.4),(.5),(.6),(.7),(.8),(.9),(1);

SELECT Z, CAST(P AS DECIMAL(5,4)) AS P
FROM @z_score
ORDER BY Z;
