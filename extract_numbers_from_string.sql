declare @Phone varchar(50) = '+1 (234) 567-8900,w,987654321#';
with n as
 (
  select 1 Number
  union all
  select Number + 1
  from n
  where Number < len(@Phone)
 )
select cast(
 (
  select
   case
    when ascii(substring(@Phone,Number,1))
     between 48 and 57
    then substring(@Phone,Number,1)
    end 
   from n
   for xml path('')
 ) as varchar(50)) as NumbersOnly;