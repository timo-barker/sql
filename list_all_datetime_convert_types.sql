set nocount on;

declare @t datetime2 = SYSDATETIME();
declare @i int = 0;

declare @temp table
	(
	 it int
	 ,dt varchar(max)
	 ,ln varchar(max)
	 );

while @i < 1000
begin
	begin try
	insert into @temp
	select @i, convert(varchar(max), @t, @i), len(convert(varchar(max),@t,@i));
	end try
	begin catch
	end catch
	set @i = @i+1;
end;

select dt as example,
'=convert(char(' + cast(ln as varchar) + '),sysdatetime(),' + cast(it as varchar) + ')' as code
from @temp
order by cast(ln as int) desc;
