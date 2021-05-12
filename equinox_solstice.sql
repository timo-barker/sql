-- sauce: https://stellafane.org/misc/equinox.html
DECLARE @year FLOAT
DECLARE @y FLOAT, @i TINYINT, @k TINYINT
       ,@jde0 FLOAT, @t FLOAT, @w FLOAT
       ,@dl FLOAT, @s FLOAT, @jde FLOAT
DECLARE @periodic24 TABLE ( i INT IDENTITY(0,1)
                           , a SMALLINT, b REAL, c REAL
                           , t FLOAT
                           , s AS a*COS(b + (c*t) )
                          )
INSERT INTO @periodic24 (a,b,c)
VALUES (485,324.96,1934.136  )
      ,(203,337.23,32964.467 )
      ,(199,342.08,20.186    )
      ,(182,27.85 ,445267.112)
      ,(156,73.14 ,45036.886 )
      ,(136,171.52,22518.443 )
      ,(77 ,222.54,65928.934 )
      ,(74 ,296.72,3034.906  )
      ,(70 ,243.58,9037.513  )
      ,(58 ,119.81,33718.147 )
      ,(52 ,297.17,150.678   )
      ,(50 ,21.02 ,2281.226  )
      ,(45 ,247.54,29929.562 )
      ,(44 ,325.15,31555.956 )
      ,(29 ,60.93 ,4443.417  )
      ,(18 ,155.12,67555.328 )
      ,(17 ,288.79,4562.452  )
      ,(16 ,198.04,62894.029 )
      ,(14 ,199.76,31436.921 )
      ,(12 ,95.39 ,14577.848 )
      ,(12 ,287.11,31931.756 )
      ,(12 ,320.81,34777.259 )
      ,(9  ,227.73,1222.114  )
      ,(8  ,15.45 ,16859.074 )
DECLARE @a INT, @alpha TINYINT, @z INT
       ,@f FLOAT, @b INT, @c SMALLINT
       ,@d INT, @e TINYINT, @dt FLOAT
       ,@mon TINYINT, @yr SMALLINT, @day TINYINT
       ,@h FLOAT, @hr TINYINT, @m FLOAT
       ,@min TINYINT, @ss float, @sec TINYINT
       ,@ms SMALLINT
       ,@utc DATETIME
DECLARE @dSeasons TABLE (ID BIGINT, FullDate DATETIME, HolidayDesc VARCHAR(50))

SELECT @year = 1970
WHILE @year < 2038
BEGIN
    SELECT @i = 1
    WHILE @i <= 4
    BEGIN
        SELECT @y = (@year-2000)/1000
        SELECT @k = @i-1
        SELECT @jde0 = CASE @k
                       WHEN 0
                       THEN 2451623.80984 + 365242.37404*@y + 0.05169*SQUARE(@y) - 0.00411*POWER(@y,3) - 0.00057*POWER(@y,4)
                       WHEN 1
                       THEN 2451716.56767 + 365241.62603*@y + 0.00325*SQUARE(@y) + 0.00888*POWER(@y,3) - 0.00030*POWER(@y,4)
                       WHEN 2
                       THEN 2451810.21715 + 365242.01767*@y - 0.11575*SQUARE(@y) + 0.00337*POWER(@y,3) + 0.00078*POWER(@y,4)
                       WHEN 3
                       THEN 2451900.05952 + 365242.74049*@y - 0.06223*SQUARE(@y) - 0.00823*POWER(@y,3) + 0.00032*POWER(@y,4)
                       END
        SELECT @t = (@jde0 - 2451545.0) / 36525
        SELECT @w = 35999.373*@t - 2.47
        SELECT @dl = 1 + 0.0334*COS(@w) + 0.0007*COS(2*@w)
        UPDATE @periodic24 SET t = @t
        SELECT @s = (SELECT DISTINCT SUM(s) OVER() FROM @periodic24)
        SELECT @jde = @jde0 + ( (0.00001*@s) / @dl )
        SELECT @z = FLOOR(@jde + 0.5)
        SELECT @f = (@jde + 0.5) - @z
        IF @z < 2299161
            BEGIN
                SELECT @a = @z
            END
        ELSE
            BEGIN
                SELECT @alpha = FLOOR( (@z-1867216.25) / 36524.25 )
                SELECT @a = @z + 1 + @alpha - FLOOR( @alpha / 4 )
            END
        SELECT @b = @a + 1524
        SELECT @c = FLOOR( (@b-122.1) / 365.25 )
        SELECT @d = FLOOR( 365.25*@c )
        SELECT @e = FLOOR( ( @b-@d )/30.6001 )
        SELECT @dt = @b - @d - FLOOR(30.6001*@e) + @f
        SELECT @mon = @e - (CASE WHEN @e < 13.5 THEN 1 ELSE 13 END)
        SELECT @yr = @c - (CASE WHEN @mon > 2.5 THEN 4716 ELSE 4715 END)
        SELECT @day = FLOOR(@dt)
        SELECT @h = 24*(@dt - @day)
        SELECT @hr = FLOOR(@h)
        SELECT @m = 60*(@h - @hr)
        SELECT @min = FLOOR(@m)
        SELECT @ss = 60*(@m-@min)
        SELECT @sec = FLOOR(@ss)
        SELECT @ms = 1000*(@ss-@sec)
        SELECT @utc = DATETIMEFROMPARTS(@yr,@mon,@day,@hr,@min,@sec,@ms)
        INSERT INTO @dSeasons (ID, FullDate, HolidayDesc)
        SELECT datediff(second,'19700101',@utc)
                ,@utc, CASE @i
                     WHEN 1
                     THEN 'March Equinox'
                     WHEN 2
                     THEN 'June Solstice'
                     WHEN 3
                     THEN 'September Equinox'
                     WHEN 4
                     THEN 'December Solstice'
                     END
        SELECT @i += 1
        IF @i > 4
            BREAK
        ELSE
            CONTINUE
    END
    SELECT @year += 1
    IF @year > 2038
        BREAK
    ELSE
        CONTINUE
END

SELECT * FROM @dSeasons
