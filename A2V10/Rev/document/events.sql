------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Even' and TABLE_SCHEMA = N'revstat')
begin
	create table revstat.Even (
		Id bigint identity(1, 1) ,
		Memberr nvarchar(255),
		[MemberName] nvarchar(255), --null constraint FK_Even_MemberName_Members foreign key references revstat.Members(Name),
		[Event] nvarchar(255),
		[EventDate] datetime,
		[IsAttended] nvarchar(15)

	)
end
go
------------------------------------------------


create or alter procedure revstat.[Ev.Load]
@Id bigint = null,
@UserId bigint
as
begin
	set nocount on;

	select [Event!TEvent!Object] = null, [Id!!Id] = Id,[Event], EventDate, IsAttended,
	[MemberName!TMember!RefId] = MemberName, Memberr
	from revstat.Even
	where Id = @Id;

	select [!TMember!Map] = null, [Id!!Id] = Id,[Name]
	from revstat.Members where [Name] in (select MemberName from revstat.Even where Id = @Id);
end
go
--------------------------------------------------


create or alter procedure revstat.[Ev.Index]
@Id bigint = null,
@UserId bigint,
@Pagesize int = 20,
@Memberr nvarchar(255) = null,
@Event nvarchar(255) = null,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Offset int = 0
as
begin
	set nocount on;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; 
	set @Desc = N'desc';
	set @Dir = isnull(@Dir,@Asc);

	select [Events!TEvent!Array] = null, [Id!!Id] = Id, [Event], EventDate, IsAttended,MemberName, Memberr,
	[!!RowNumber] = row_number() over(
	order by
		case when @Order = N'Name' and @Dir = @Asc then Memberr end asc,
		case when @Order = N'Name' and @Dir = @Desc then Memberr end desc,
		case when @Order = N'Event' and @Dir = @Asc then [Event] end asc,
		case when @Order = N'Event' and @Dir = @Desc then [Event] end desc,
		case when @Order = N'Attendance' and @Dir = @Asc then IsAttended end asc,
		case when @Order = N'Attendance' and @Dir = @Desc then IsAttended end desc
	),
	[!!RowCount] = count(*) over()
	from revstat.Even
	where isnull(@Memberr,N'') = N'' and isnull(@Event,N'') = N'' or
	upper(Memberr) like N'%' + upper(@Memberr) + N'%' or upper([Event]) like N'%' + upper(@Event) + N'%'
	order by [!!RowNumber] offset (@Offset) rows fetch next (@PageSize) rows only;

	select [!$System!] = null,
		[!Events!PageSize] = @PageSize,
		[!Events!SortOrder] = @Order,
		[!Events!SortDir] = @Dir,
		[!Events!Offset] = @Offset,
		[!Events.Memberr!Filter] = @Memberr,
		[!Events.Event!Filter] = @Event;

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'revstat' and ROUTINE_NAME=N'Ev.Update')
	drop procedure revstat.[Ev.Update]
go
------------------------------------------------
--------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'revstat' and ROUTINE_NAME=N'Ev.Metadata')
	drop procedure revstat.[Ev.Metadata]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'revstat' and DOMAIN_NAME=N'Ev.TableType' and DATA_TYPE=N'table type')
	drop type revstat.[Ev.TableType];
go

create type revstat.[Ev.TableType]
as table(
	Id bigint null,
	[MemberName] nvarchar(255),
	[Event] nvarchar(255),
	[EventDate] datetime,
	[IsAttended] nvarchar(15)
)
go
------------------------------------------------
create or alter procedure revstat.[Ev.Metadata]
as
begin
	set nocount on;
	declare @Event revstat.[Ev.TableType];
	select [Event!Event!Metadata] = null, * from @Event
end
go
--------------------------------------------------
--insert into revstat.Ev ([Name]) values ('Lol')

--create or alter procedure revstat.[ModelLoad]
--@UserId bigint,
--@Id bigint = null
--as
--begin
--	set nocount on;

--	exec revstat.[Members.Load] @UserId, @Id;
--end
--go
--------------------------------------------------
create or alter procedure revstat.[Ev.Update]
@UserId bigint,
@Event revstat.[Ev.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge revstat.Even as target
	using @Event as source
	on (target.Id = source.Id)
	when matched then
		update set
			target.[MemberName] = source.[MemberName],
			target.[Event] = source.[Event],
			target.[EventDate] = source.[EventDate],
			target.[IsAttended] = source.[IsAttended]
	when not matched by target then
		insert ([MemberName],[Event], [EventDate], [IsAttended])
		values ([MemberName],[Event], [EventDate], [IsAttended])
	output
		$action op,
		inserted.Id id
	into @output(op,id);

	update revstat.Even 
	set Memberr = [Name]
	from revstat.Members m, revstat.Even e 
	where e.MemberName = m.Id;

	exec revstat.[Ev.Load] @UserId, @RetId;
end
go
------------------------------------------------
create or alter procedure revstat.[Ev.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	--throw 60000, N'UI:Не можна видаляти. Вам цього неможна', 0;
	delete from revstat.Even where Id=@Id;
end
go



--@Id bigint = null,
--@UserId bigint
----@Pagesize int = 20
----@Memberr nvarchar(255) = null,
----@Event nvarchar(255) = null,
----@Order nvarchar(255) = N'Id',
----@Dir nvarchar(20) = N'desc',
----@Offset int = 0
--as
--begin
--	set nocount on;

--	--declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
--	--set @Asc = N'asc'; 
--	--set @Desc = N'desc';
--	--set @Dir = isnull(@Dir,@Asc);

--	select [Events!TEvent!Array] = null, [Id!!Id] = Id, [Event], EventDate, IsAttended,MemberName, Memberr
--	--[!!RowNumber] = row_number() over(
--	--order by
--	--	case when @Order = N'Name' and @Dir = @Asc then Memberr end asc,
--	--	case when @Order = N'Name' and @Dir = @Desc then Memberr end desc,
--	--	case when @Order = N'Event' and @Dir = @Asc then [Event] end asc,
--	--	case when @Order = N'Event' and @Dir = @Desc then [Event] end desc,
--	--	case when @Order = N'Attendance' and @Dir = @Asc then IsAttended end asc,
--	--	case when @Order = N'Attendance' and @Dir = @Desc then IsAttended end desc
--	--),
--	--[!!RowCount] = count(*) over()
--	from revstat.Even
--	--where isnull(@Memberr,N'') = N'' and isnull(@Event,N'') = N'' or
--	--upper(Memberr) like N'%' + upper(@Memberr) + N'%' or upper([Event]) like N'%' + upper(@Event) + N'%'
--	--order by [!!RowNumber] offset (@Offset) rows fetch next (@PageSize) rows only;

--	--select [!$System!] = null,
--	--	[!Events!PageSize] = @PageSize,
--	--	[!Events!SortOrder] = @Order,
--	--	[!Events!SortDir] = @Dir,
--	--	[!Events!Offset] = @Offset,
--	--	[!Events.Memberr!Filter] = @Memberr,
--	--	[!Events.Event!Filter] = @Event;

--end
--go
