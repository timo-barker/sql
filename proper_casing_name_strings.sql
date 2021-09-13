
with cte_UserList as
  (
   select UserName1
   from (values
           ('O''Brian, Patrick')
          ,('Mohamed, Fatima')
          ,('Wang-Li, Nushi')
          ,('García, Maria')
          ,('da Silva, Jose')
          ,('Müller, Lucas')
          ,('McCarthy, Jane')
          ,('Summer, April-May-June')
          ,('D''Angelo, Mario')
          ,('Van Ness-O''Niel, Mary-Jane')
          ,('FitzGerald, Orren')
        ) src (UserName1) 
  )
,cte_upper as
  (
   select 
       UserName1
      ,upper(UserName1) as UserName2
   from cte_UserList
  )
,cte_proper as
  (
   select
       UserName1
      ,UserName2
      ,stuff((
              select ' ' + (upper(left(value,1)) + lower(substring(value,2,8000)))
              from (
                    select value
                    from string_split(UserName2,' ')
                   ) as spa
              for xml path ('')
            ),1,1,'') as UserName3
   from cte_upper
  )
,cte_compound as
  (
   select
       UserName1
      ,UserName2
      ,UserName3
      ,case when patindex('%-[a-z]%',UserName3 collate Latin1_General_BIN) > 0
            then stuff(
                        UserName3
                       ,patindex('%-[a-z]%',UserName3) + 1
                       ,1
                       ,upper(
                              substring(
                                         UserName3
                                        ,patindex('%-[a-z]%',UserName3) + 1
                                        ,1
                                       )
                             )
                      )
            when patindex('[DO]''[a-z]%',UserName3 collate Latin1_General_BIN) > 0
            then stuff(
                        UserName3
                       ,patindex('[DO]''[a-z]%',UserName3) + 2
                       ,1
                       ,upper(
                              substring(
                                         UserName3
                                        ,patindex('[DO]''[a-z]%',UserName3) + 2
                                        ,1
                                       )
                             )
                      )
            when patindex('Mc[a-z]%',UserName3 collate Latin1_General_BIN) > 0
            then stuff(
                        UserName3
                       ,patindex('Mc[a-z]%',UserName3) + 2
                       ,1
                       ,upper(
                              substring(
                                         UserName3
                                        ,patindex('Mc[a-z]%',UserName3) + 2
                                        ,1
                                       )
                             )
                      )
       else UserName3
       end as UserName4
   from cte_proper   
  )
select *
from cte_compound
where UserName1 <> UserName4 collate SQL_Latin1_General_CP1_CS_AS
union
select *
from cte_compound
where UserName1 = UserName4 collate SQL_Latin1_General_CP1_CS_AS
order by UserName1

