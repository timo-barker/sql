create or alter function dbo.fn_encrypt
(@input int, @password nvarchar(4000))
returns varchar(50)
as
begin

declare @digit bigint
declare @reminder bigint
declare @modelstring varchar(50)

declare @VarNum varchar(50)
set @VarNum= ''
set @digit = 0
declare @codelen bigint

--removes duplicate alphanumeric characters from password
--so the reverse hash can point to a specific alpha
;with password_1 as (
  select stuff(@password,1,1,'') txt, left(@password,1) Col1, 1 pos
  union all
  select stuff(txt,1,1,'') txt, left(txt,1) Col1, pos + 1 
  from password_1
  where len(txt) > 0)
,password_2 as (
  select Col1, row_number() over(order by pos) as RowID from password_1)
,password_3 as (
select t1.Col1, RowID
from password_2 t1
    inner join (select Col1, min(RowID) as MinOfRowId
                from password_2
                group by Col1) t2
        on t1.Col1 = t2.Col1 and t1.RowID = t2.MinOfRowID)
select @modelstring = string_agg(password_3.Col1,'') from password_3

-- set the hash to utilize the full range of alphas in the password
set @codelen = (select len(@modelstring))

while (@input > 0)
begin
set @digit = @digit + @input - @input / 10 * 10 + 48
set @input = @input / 10
set @digit = @digit * 256
end

set @digit = @digit / 256

while (@digit > 0)
begin
set @reminder = @digit - @digit / @codelen * @codelen
set @digit = @digit / @codelen
set @VarNum = @VarNum + SUBSTRING(@modelstring, @reminder + 1, 1)
end

return reverse(@VarNum)
end
go

create or alter function dbo.fn_decrypt
(@input varchar(50), @password nvarchar(4000))
returns bigint
as
begin

declare @digit bigint = 0
declare @reminder bigint
declare @modelstring varchar(50)
declare @VarNum varchar(50)

set @digit = 0
declare @codelen int

;with password_1 as (
  select stuff(@password,1,1,'') txt, left(@password,1) Col1, 1 pos
  union all
  select stuff(txt,1,1,'') txt, left(txt,1) Col1, pos + 1 
  from password_1
  where len(txt) > 0)
,password_2 as (
  select Col1, row_number() over(order by pos) as RowID from password_1)
,password_3 as (
select t1.Col1, RowID
from password_2 t1
    inner join (select Col1, min(RowID) as MinOfRowId
                from password_2
                group by Col1) t2
        on t1.Col1 = t2.Col1 and t1.RowID = t2.MinOfRowID)
select @modelstring = string_agg(password_3.Col1,'') from password_3

set @codelen = (select len(@modelstring))
set @VarNum = reverse(@input)

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
declare @multiplier bigint = 0

declare @hash table 
  (
      position bigint identity
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

declare @output bigint
select @output = try_cast(string_agg(guess,'') as int)
from @hash

return @output
end
go

select dbo.fn_encrypt(51648,'KIM6RE5V1ER65545T1W43T') as output
select dbo.fn_decrypt('I443KIV14T6','KIM6RE5V1ER65545T1W43T') as input

select dbo.fn_encrypt(51648,'jq9whmCpgrf8v6VMcW7XJ5R4H3QGxP2F') as output
select dbo.fn_decrypt('RG8X6C3PR','jq9whmCpgrf8v6VMcW7XJ5R4H3QGxP2F') as input

-- this errors out. function can only handle ints to about 3 million or so.
select dbo.fn_encrypt(106122112,'KIM6RE5V1ER65545T1W43T') as output
select dbo.fn_decrypt('MMR11R5','KIM6RE5V1ER65545T1W43T') as input

