-- sauce1: https://medium.com/swlh/linear-regression-in-sql-is-it-possible-b9cc787d622f
-- sauce2: https://ayadshammout.com/2013/11/30/t-sql-linear-regression-function/
--
declare @sample table
  (
    x float
   ,y float
  )
;
insert into @sample (x,y)
values (10,4)
      ,(11,96)
      ,(12,450)
      ,(13,1155)
      ,(14,2092)
      ,(15,3842)
      ,(16,6248)
      ,(17,8607)
      ,(18,10843)
      ,(19,13645)
      ,(20,17025)
;
insert into @sample (x,y)  
values (7,75)
      ,(10,68)
      ,(12,65)
      ,(18,60)
      ,(20,57)
      ,(25,50)
;
--
-- y = mx + b
--
--     Σ(xᵢ - x̄)(yᵢ - ȳ)
-- m = -----------------
--        Σ(xᵢ - x̄)²
--
-- b = ȳ - mx̄
--
declare @slope float
;
declare @intercept float
;
select @slope = slope, 
    @intercept = y_bar_max - x_bar_max * slope
from
    (
    select
        max(x_bar) as x_bar_max,
        max(y_bar) as y_bar_max,
        sum((x - x_bar) * (y - y_bar)) 
      / sum((x - x_bar) * (x - x_bar)) as slope
    from 
        (
        select
            x, avg(x) over() as x_bar,
            y, avg(y) over() as y_bar
        from @sample    
        ) as bar
    ) as slope
;
select x, y, 
    (@slope * x) + @intercept as y_trend
from @sample
order by x, y
;
--          Σ(yᵢ - ŷ)²
-- R² = 1 - ----------
--          Σ(yᵢ - ȳ)²
--
select @slope as slope, @intercept as intercept,  
    (((@intercept * sum(y)) + (@slope * sum(x * y))) - ((sum(y) * sum(y)) / count(*))) 
  / (sum(y * y) - ((sum(y) * sum(y)) / count(*))) as R2
from @sample
;
