use master
go

declare @database_list table
  (
    id         int identity
   ,[database] nvarchar(128)
  );

insert into @database_list ([database])
select name
from master.sys.databases
where database_id > 4
order by name;

if object_id('tempdb..#permission_list','u') is not null
    drop table #permission_list;

create table #permission_list
  (
    [database]  nvarchar(128)
   ,permissions varchar(128)
  );

declare @database_selected nvarchar(128);
declare @sql nvarchar(4000);

declare #c cursor for
    select [database]
    from @database_list
    order by [database];

open #c;
fetch next from #c into @database_selected;
while @@fetch_status = 0
begin
    set @sql = N'insert into #permissions_list ([database],permissions) select ''';
    set @sql += @database_selected;
    set @sql += ''', permission_name from ';
    set @sql += @database_selected;
    set @sql += '.sys.fn_mypermissions(NULL,''DATABASE'');';
    execute sp_executesql @sql;
    fetch next from #c into @database_selected;
end;
close #c;
deallocate #c;

--no showplan
select distinct
    t1.[database]
   ,stuff((select (','+permissions)
           from #permissions_list t3
           where t1.[database] = t3.[database]
           group by permissions
           order by permissions asc
           for xml path('')),1,1,'') permissions
from #permissions_list t1
    left join (
               select distinct [database]
               from #permissions_list
               where permissions = 'SHOWPLAN'
              ) t2
        on t1.[database] = t2.[database]
where t2.[database] is null
order by t1.[database];

--with showplan
select distinct [database] 
from #permissions_list 
where permissions = 'SHOWPLAN'
order by [database];
