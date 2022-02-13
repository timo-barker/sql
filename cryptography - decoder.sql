declare @VarNum varchar(50)
set @VarNum = '32W7U2WL'--'I443KIV14T6'--'N224HH4C'
--set @VarNum = 'MMR11R5'
set @VarNum = reverse(@VarNum)
declare @digit bigint = 0
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
select @modelstring
declare @ID bigint = 0
while (len(@VarNum) > 0)
begin
set @reminder = CHARINDEX(SUBSTRING(@VarNum, len(@VarNum), 1),@modelstring) - 1
set @digit = (@digit * @codelen) + (CHARINDEX(SUBSTRING(@VarNum, len(@VarNum), 1),@modelstring) - 1)
set @VarNum = SUBSTRING(@VarNum , 1, len(@VarNum) - 1)
end

set @digit = @digit * 256
declare @digit2 bigint = @digit
declare @len int = 0

while (@digit > 0)
    begin
        set @digit = @digit2 / power(cast(256 as bigint),@len+1)
        if @digit > 0
            set @len += 1
    end

set @digit = @digit2
declare @val bigint = 0
declare @multiplier int = 0

declare @hash table 
  (
      position tinyint identity
     ,hash1 bigint
     ,hash2 bigint
     ,guess as (hash1 - 48) - ( hash2 / 256 * 256)
  )

while @digit > 0
    begin
    set @digit = @digit / 256
    if @digit > 0
        insert into @hash (hash1)
        select @digit
    end

;with cte as (
select position, hash2 = (max(hash1) over() / power(cast(256 as bigint),position-1))-(0+48)
from @hash 
)
update t1
set t1.hash2 = t2.hash2
from cte t2
join @hash t1
on t2.position = t1.position

select try_cast(string_agg(guess,'') as bigint) as ID
from @hash