with t10 as (select n from (values(0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) t(n))
,t1k as (select row_number() over (order by (select 0))-1 num from t10 a, t10 b, t10 c, t10 d)
select cast(dateadd(month,num,0) as date) bom, cast(eomonth(dateadd(month,num,0)) as date) eom
from t1k where isdate(try_cast(eomonth(dateadd(month,num,0)) as smalldatetime)) = 1
