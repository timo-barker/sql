-- Sim 1: run in two sessions without hints.
-- Should produce key violation errors.
-- Sim 2: run in two sessions with UPDLOCK hint only.
-- Produces key violation errors, but no deadlocks.
-- Allows read from others, but only this process can write.
-- Sim 3: run in two sessions with SERIALIZABLE hint only.
-- No key violations but produces deadlock in one session.
-- Holds the M lock for the duration of the transaction.
-- Sim 4: run in two sessions with UPDLOCK and SERIALIZABLE hints.
-- No key violations, no deadlocks.

if OBJECT_ID('[dbo].[DropMe]') is null
	create table [dbo].[DropMe] (
		Id int identity primary key, 
		timer varchar(50) not null unique
	);
go

create or alter proc [dbo].[p_DropMe] as
	insert [dbo].[DropMe]
	select convert(varchar, getdate(), 114)
	except
	select timer from [dbo].[DropMe] WITH (UPDLOCK, SERIALIZABLE);
go

set nocount on;

while 1 = 1 begin
	exec [dbo].[p_DropMe];
end
