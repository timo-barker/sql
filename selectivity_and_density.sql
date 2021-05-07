--set ansi_warnings, arithabort on
--;
use AdventureWorks
;
declare @table varchar(128) = 'Production.Product'
;
if object_id ('tempdb.dbo.#output','U') is not null
    drop table #output
;
create table #output  
  ( 
    RowID         smallint identity(1,1)
   ,[schema]      varchar(128)
   ,[table]       varchar(128)
   ,[column]      varchar(128)
   ,[distinct]    bigint
   ,[count]       bigint
   ,[selectivity] as cast([distinct] as decimal) / [count]
   ,[density]     as case when cast([distinct] as decimal) = 0 
                          then NULL 
                          else 1 / cast([distinct] as decimal) 
                          end
   ,TS            datetime2 default sysdatetime()
  )
;
declare @i smallint = 1
;
declare @sql nvarchar(4000)
;
set @table = replace(replace(@table,'[',''),']','')
;
insert into #output ([schema], [table], [column])
select s.name as [schema], t.name as [table], c.name as [column]
from sys.schemas as s with (nolock)
    inner join sys.tables as t with (nolock)
        on s.schema_id = t.schema_id
    inner join sys.columns as c with (nolock)
        on t.object_id = c.object_id
where s.name = case when patindex('%.%',@table) > 0
                    then substring(@table,1,patindex('%.%',@table)-1)
                    else 'dbo'
                    end
  and t.name = case when patindex('%.%',@table) > 0
                    then substring(@table,patindex('%.%',@table)+1,128)
                    else @table
                    end
order by c.column_id asc
;
while @i <= (select max(RowID) from #output)
begin
    set @sql = (select N'update #output set [distinct] = (select count(distinct ' + QUOTENAME([column]) + ') 
                                                          from ' + QUOTENAME([schema]) + '.' + QUOTENAME([table]) + ' with (nolock)) 
                                                          where RowID = ' + cast(@i as varchar) + ';' 
                from #output where @i = RowID) + char(13) + char(10)
    --print @sql
    exec(@sql);
    set @i += 1;
    if @i > (select max(RowID) from #output)
        break;
    else
        continue;
end
;
set @sql = (select N'update #output set [count] = (select count(*) 
                                                   from ' + QUOTENAME([schema]) + '.' + QUOTENAME([table]) + ' with (nolock));' 
            from #output where RowID = 1) + char(13) + char(10)
--print @sql
exec(@sql);
select db_name() as [database]
      ,[schema]
      ,[table]
      ,[column]
      ,RowID as ColumnID
      ,format([distinct],'#,##0') as [distinct]
      ,format(selectivity,'#,##0.0000%') as selectivity
      ,format(density,'#,##0.0000%')as density
      ,format([count],'#,##0') as [count]
from #output
order by try_cast(selectivity as float) desc
        ,try_cast(density as float) asc
        ,RowID asc
;
-- good candidate columns for indexing should have  high selectivity (i.e. > 0.995) and low density (i.e. < 0.005).
-- 1. Avoid indexing highly used table/columns – The more indexes on a table the bigger the effect will be on a performance of Insert, Update, Delete, and Merge statements because all indexes must be modified appropriately. This means that SQL Server will have to do page splitting, move data around, and it will have to do that for all affected indexes by those DML statements
-- 2. Use narrow index keys whenever possible – Keep indexes narrow, that is, with as few columns as possible. Exact numeric keys are the most efficient SQL index keys (e.g. integers). These keys require less disk space and maintenance overhead
-- 3. Use clustered indexes on unique columns – Consider columns that are unique or contain many distinct values and avoid them for columns that undergo frequent changes
-- 4. Nonclustered indexes on columns that are frequently searched and/or joined on – Ensure that nonclustered indexes are put on foreign keys and columns frequently used in search conditions, such as Where clause that returns exact matches
-- 5. Cover SQL indexes for big performance gains – Improvements are attained when the index holds all columns in the query
--set ansi_warnings, arithabort off
--;

