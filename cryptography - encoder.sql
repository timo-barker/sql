--create function [dbo].[testnumber](@ID int)
--returns varchar(50)
--as
--begin
declare @ID int = 51648
    print '@ID = ' + cast(@ID as varchar(20))

declare @digit bigint
declare @reminder bigint
declare @modelstring varchar(50)
set @modelstring = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
--set @modelstring = 'KIM6RE5V1ER65545T1W43T'


;WITH CTE AS 
(
    SELECT STUFF(@modelstring,1,1,'') TXT, LEFT(@modelstring,1) Col1, 1 as pos

    UNION ALL

    SELECT STUFF(TXT,1,1,'') TXT, LEFT(TXT,1) Col1 , pos + 1 FROM CTE
    WHERE LEN(TXT) > 0
)
,cte2 AS
(
select Col1, row_number() over(order by pos) as RowID from CTE
)
,cte3 as
(
select t1.Col1, RowID
from cte2 t1
inner join (select Col1, min(RowID) as MinOfRowId
            from cte2
            group by Col1) t2
    on t1.Col1 = t2.Col1 and t1.RowID = t2.MinOfRowID
)
select @modelstring = string_agg(cte3.Col1,'') from cte3 

declare @codelen int = (select len(@modelstring))



    print '@modelstring = ' + @modelstring
declare @VarNum varchar(50)
set @VarNum= ''
    print '@VarNum = ' + @VarNum
set @digit = 0
    print '@digit = ' + cast(@digit as varchar(20))

while (@ID > 0)
begin
set @digit = @digit + @ID - @ID / 10 * 10 + 48
--  @digit = 0 + 51648 - 51648 / 10 * 10 + 48
--  @digit = 0 + 51648 - 5164 * 10 + 48
--  @digit = 0 + 51648 - 51640 + 48
--  @digit = 51648 - 51640 + 4
--  @digit = 8 + 48
--  @digit = 56
   print '@digit = ' + cast(@digit as varchar(20))
set @ID = @ID / 10
--  @ID = 51648 / 10
--  @ID = 5164
    print '@ID = ' + cast(@ID as varchar(20))
set @digit = @digit * 256
--  @digit = 56 * 256
--  @digit = 14336
    print '@digit = ' + cast(@digit as varchar(20))
    print '--------'
end

set @digit = @digit / 256
--  @digit = 61796898649344 / 256
--  @digit = 241394135349
    print '@digit = ' + cast(@digit as varchar(20))

while (@digit > 0)
begin
set @reminder = @digit - @digit / @codelen * @codelen
--  @reminder = 241394135349 - 241394135349 / @codelen * @codelen
--  @reminder = 241394135349 - 8940523531 * @codelen
--  @reminder = 241394135349 - 241394135337
--  @reminder = 12
    print '@reminder = ' + cast(@reminder as varchar(20))
set @digit = @digit / @codelen
--  @digit = 241394135349 / @codelen
--  @digit = 8940523531
    print '@digit = ' + cast(@digit as varchar(20))
set @VarNum = @VarNum + SUBSTRING(@modelstring, @reminder + 1, 1)
--  @VarNum = '' + SUBSTRING('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 12 + 1, 1)
--  @VarNum = '' + SUBSTRING('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 13, 1)
--  @VarNum = '' + SUBSTRING('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 13, 1)
--  @VarNum = '' + 'C'
--  @VarNum = 'C'
    print '@VarNum = ' + @VarNum
end

select reverse(@VarNum)

--end

--SELECT [dbo].[testnumber](51648)