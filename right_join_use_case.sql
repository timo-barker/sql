declare @table_a table (id int, b_fk char, col_1 char(10))
declare @table_b table (id int, c_fk char, col_1 char(10))
declare @table_c table (id int, id2 char , col_1 char(10))

insert into @table_a values (1,'1','one') ,(2,'2','two'),(3,'3','three')
insert into @table_b values (1,'1','one') ,(2,'2','two'),(4,'4','four')
insert into @table_c values (0,'0','zero'),(2,'2','two'),(4,'4','four')

select a.col_1, b.col_1, c.col_1
from @table_a a
left join @table_b b on a.b_fk = b.id
inner join @table_c c on b.c_fk = c.id

select a.col_1, b.col_1, c.col_1
from @table_c c
inner join @table_b b on b.c_fk = c.id
right join @table_a a on a.b_fk = b.id

select a.col_1, b.col_1, c.col_1
from @table_a a
left join @table_b b 
inner join @table_c c 
on b.c_fk = c.id
on a.b_fk = b.id

select a.col_1, b.col_1, c.col_1
from @table_a a
left join (@table_b b 
inner join @table_c c 
on b.c_fk = c.id)
on a.b_fk = b.id

