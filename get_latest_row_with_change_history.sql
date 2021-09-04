declare @a table 
 (
   ID1 int
  ,ID2 int
  ,Limit int
  ,Changeddate date   
 )
insert into @a (ID1, ID2, Limit, Changeddate)
values
 (123,456,100,'20180101')
,(123,456,200,'20190101')
,(321,654,1000,'20170201')
,(321,654,4000,'20210201')
,(321,654,2000,'20200201');
with foo as
 (
  select ID1, ID2, Limit, Changeddate, first_value(Changeddate) 
  over(partition by ID1, ID2 order by Changeddate desc) LastChangeddate
  from @a A
 )
select ID1, ID2, Limit, Changeddate
from foo
where Changeddate = LastChangeddate;