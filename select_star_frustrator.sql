drop view if exists dbo.TheView

drop table if exists dbo.NoSelectStar

create table dbo.NoSelectStar (ColA int identity, ColB varchar(100), ColC datetime);
go
create view dbo.TheView as (
    select *, 1/0 as NoSelect
    from dbo.NoSelectStar
)
go
with cte as (
select 1 as ColA
union all
select ColA+1 from cte
where ColA < 100
)
insert into dbo.NoSelectStar (ColB, ColC)
select ColA, getdate()
from Cte
--option (maxrecursion 1000)

select * from dbo.TheView
go
select ColA, ColB, ColC from dbo.TheView
go

drop view if exists dbo.TheView

drop table if exists dbo.NoSelectStar
