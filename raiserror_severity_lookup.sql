declare @raiserror table
  (
    Level       smallint
   ,Color          varchar(10)  
   ,SwitchesTabs   bit
   ,StopsExecution bit
   ,KillsExecution bit
   ,FailsJobStep   bit
   ,OutPutFormat   varchar(100)
   ,[WITH]         varchar(5)
  )
;
insert into @raiserror
  (
    Level          
   ,Color            
   ,SwitchesTabs   
   ,StopsExecution 
   ,KillsExecution 
   ,FailsJobStep   
   ,OutPutFormat   
   ,[WITH]         
  )
values (0 ,'Black',0,0,0,0,NULL                                                     ,'[Any]')
      ,(1 ,'Black',0,0,0,0,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(2 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(3 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(4 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(5 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(6 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(7 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(8 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(9 ,'Black',0,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>'         ,'[Any]')
      ,(10,'Black',0,0,0,0,NULL                                                     ,'[Any]')
      ,(11,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(12,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(13,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(14,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(15,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(16,'Red'  ,1,0,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(17,'Red'  ,1,1,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(18,'Red'  ,1,1,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','[Any]')
      ,(19,'Red'  ,1,1,0,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(20,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(21,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(22,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(23,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(24,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
      ,(25,'Red'  ,1,1,1,1,'Msg 50000, Level <<severity>>, State <<state>>, Line ##','LOG'  )
;
declare @severity varchar(3)
;
declare #c cursor for
    select Level
    from @raiserror
    order by Level
;
open #c
;
fetch next from #c into @severity
;
while @@fetch_status = 0
begin
    select * from @raiserror where Level = @severity
    ;
    raiserror('level: %s',@severity,0,@severity) with nowait
    ;
    fetch next from #c into @severity
    ;
end
;
close #c
;
deallocate #c
;
