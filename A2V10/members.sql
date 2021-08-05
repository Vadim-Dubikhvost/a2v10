------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Attachments' and TABLE_SCHEMA = N'revstat')
begin
-- таблица вложений
create table revstat.Attachments (
	Id bigint identity(1, 1)  not null constraint PK_Attachments primary key,
	[Name] nvarchar(255) ,
	Mime nvarchar(255),
	Stream varbinary(max),
	AccessKey uniqueidentifier constraint DF_Attachments_AccessKey default (newid())
)

end
go
------------------------------------------------
--if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'AttachmentLinks' and TABLE_SCHEMA = N'revstat')
--begin

-- таблица связей
--create table revstat.AttachmentLinks (
--	AgentId bigint null constraint FK_AttachmentLinks_AgentId_Members foreign key references revstat.Members(Id),
--	ImageId bigint null constraint FK_AttachmentLinks_ImageId_Attachments foreign key references revstat.Attachments(Id)
--)

--end
--go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Members' and TABLE_SCHEMA = N'revstat')
begin
	create table revstat.Members (
		Id bigint identity(1, 1) constraint PK_Members primary key,
		[Name] nvarchar(255) ,
		Class nvarchar(9),
		BM bigint,
		Def bigint,
		Res bigint,
		Res_crit float,
		Res_rage float,
		Res_pen float,
		Crit_chance float,
		Crit_strike float,
		Pen float,
		Rage float,
		[Image] bigint null constraint FK_Members_Image_Attachments foreign key references revstat.Attachments(Id)
		--[Image] nvarchar(9) null constraint FK_Members_Image_Images foreign key references revstat.Images([Name])
	)
end
go
------------------------------------------------
--exec revstat.[Members.Index] @UserId = 99;
create or alter procedure revstat.[Members.Index]
@UserId bigint,
@Id bigint = null,
@Name nvarchar(255) = null,
@Class nvarchar(9) = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc'
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; 
	set @Desc = N'desc';
	set @Dir = isnull(@Dir,@Asc);

	select [Members!TMember!Array] = null, [Id!!Id] = m.Id, m.[Name], Class, [ImageId]=[Image],
	[Image.Id!TImage!Id]=[Image],[Image.Token!TImage!Token]=A.AccessKey,
	BM, Def, Res, Res_crit, Res_rage, Res_pen, Crit_chance, Crit_strike, Pen, Rage,
	[!!RowNumber] = row_number() over(
	order by
		case when @Order = N'Id' and @Dir = @Asc then m.Id end asc,
		case when @Order = N'Id' and @Dir = @Desc then m.Id end desc,
		case when @Order = N'Class' and @Dir = @Asc then m.Class end asc,
		case when @Order = N'Class' and @Dir = @Desc then m.Class end desc,
		case when @Order = N'Name' and @Dir = @Asc then m.[Name] end asc,
		case when @Order = N'Name' and @Dir = @Desc then m.[Name] end desc,
		case when @Order = N'BM' and @Dir = @Asc then m.BM end asc,
		case when @Order = N'BM' and @Dir = @Desc then m.BM end desc,
		case when @Order = N'Def' and @Dir = @Asc then m.Def end asc,
		case when @Order = N'Def' and @Dir = @Desc then m.Def end desc,
		case when @Order = N'Res' and @Dir = @Asc then m.Res end asc,
		case when @Order = N'Res' and @Dir = @Desc then m.Res end desc,
		case when @Order = N'Res_crit' and @Dir = @Asc then m.Res_crit end asc,
		case when @Order = N'Res_crit' and @Dir = @Desc then m.Res_crit end desc,
		case when @Order = N'Res_rage' and @Dir = @Asc then m.Res_rage end asc,
		case when @Order = N'Res_rage' and @Dir = @Desc then m.Res_rage end desc,
		case when @Order = N'Res_pen' and @Dir = @Asc then m.Res_pen end asc,
		case when @Order = N'Res_pen' and @Dir = @Desc then m.Res_pen end desc,
		case when @Order = N'Crit_chance' and @Dir = @Asc then m.Crit_chance end asc,
		case when @Order = N'Crit_chance' and @Dir = @Desc then m.Crit_chance end desc,
		case when @Order = N'Crit_strike' and @Dir = @Asc then m.Crit_strike end asc,
		case when @Order = N'Crit_strike' and @Dir = @Desc then m.Crit_strike end desc,
		case when @Order = N'Pen' and @Dir = @Asc then m.Pen end asc,
		case when @Order = N'Pen' and @Dir = @Desc then m.Pen end desc,
		case when @Order = N'Rage' and @Dir = @Asc then m.Rage end asc,
		case when @Order = N'Rage' and @Dir = @Desc then m.Rage end desc
	),
	[!!RowCount] = count(*) over()--[Image] = Class
	from revstat.Members m
	left join revstat.Attachments A on m.[Image]=A.Id
	where isnull(@Name,N'') = N'' and isnull(@Class,N'') = N'' or
	upper(m.[Name]) like N'%' + upper(@Name) + N'%' or upper(m.Class) like N'%' + upper(@Class) + N'%'
order by [!!RowNumber] offset (@Offset) rows fetch next (@PageSize) rows only;

	select [!$System!] = null,
		[!Members!PageSize] = @PageSize,
		[!Members!SortOrder] = @Order,
		[!Members!SortDir] = @Dir,
		[!Members!Offset] = @Offset,
		[!Members.Name!Filter] = @Name,
		[!Members.Class!Filter] = @Class;
end
go
------------------------------------------------
create or alter procedure revstat.[Members.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;

	select [Member!TMember!Object] = null,  [Id!!Id] = m.Id, m.[Name], Class, BM, Def, Res, Res_crit, Res_rage, Res_pen, Crit_chance, Crit_strike, Pen, Rage, [Image]
	from revstat.Members m
	where m.Id = @Id;

	select [Params!TParam!Object] = null, [Text] = @Text, [Id!!Id] = 1;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'revstat' and ROUTINE_NAME=N'Members.Metadata')
	drop procedure revstat.[Members.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'revstat' and ROUTINE_NAME=N'Members.Update')
	drop procedure revstat.[Members.Update]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'revstat' and ROUTINE_NAME=N'wrImageId')
	drop procedure revstat.[wrImageId]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'revstat' and DOMAIN_NAME=N'Members.TableType' and DATA_TYPE=N'table type')
	drop type revstat.[Members.TableType];
go
------------------------------------------------
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'revstat' and TABLE_NAME=N'Members' and COLUMN_NAME=N'Image'))
begin
	alter table revstat.Members add [Image] bigint null constraint FK_Members_Image_Attachments foreign key references revstat.Attachments(Id);
end
go
------------------------------------------------
create type revstat.[Members.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Class nvarchar(9),
	BM bigint,
	Def bigint,
	Res bigint,
	Res_crit float,
	Res_rage float,
	Res_pen float,
	Crit_chance float,
	Crit_strike float,
	Pen float,
	Rage float,
	[ImageId] bigint
)
go
------------------------------------------------
create or alter procedure revstat.[Members.Metadata]
as
begin
	set nocount on;
	declare @Member revstat.[Members.TableType];
	select [Member!Member!Metadata] = null, * from @Member
end
go
------------------------------------------------
create or alter procedure revstat.[Members.Update]
@UserId bigint,
@Member revstat.[Members.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge revstat.Members as target
	using @Member as source
	on (target.Id = source.Id)
	when matched then
		update set
			target.[Name] = source.[Name],
			target.[BM] = source.[BM],
			target.[Class] = source.[Class],
			target.[Def] = source.[Def],
			target.[Res] = source.[Res],
			target.[Res_crit] = source.[Res_crit],
			target.[Res_rage] = source.[Res_rage],
			target.[Res_pen] = source.[Res_pen],
			target.[Crit_chance] = source.[Crit_chance],
			target.[Crit_strike] = source.[Crit_strike],
			target.[Pen] = source.[Pen],
			target.[Rage] = source.[Rage],
			target.[Image] = source.[ImageId]
	when not matched by target then
		insert ([Name],BM, Class, Def, Res, Res_crit, Res_rage, Res_pen, Crit_chance, Crit_strike, Pen, Rage,[Image])
		values ([Name],BM, Class, Def, Res, Res_crit, Res_rage, Res_pen, Crit_chance, Crit_strike, Pen, Rage,[ImageId])
	output
		$action op,
		inserted.Id id
	into @output(op,id);

	exec revstat.[Members.Load] @UserId, @RetId;
end
go
------------------------------------------------
create or alter procedure revstat.[Members.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	--throw 60000, N'UI:Не можна видаляти. Вам цього неможна', 0;
	delete from revstat.Members where Id=@Id;
end
go
------------------------------------------------
create or alter procedure revstat.[Members.Images.Load]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	select i.[Name], i.Stream from revstat.Images i, revstat.Members m where i.[Name] = m.[Class];
end
go
------------------------------------------------

--insert into revstat.Members ([Image])
--select BulkColumn
---from Openrowset( Bulk 'D:\A2V10\Tutorial\A2V10_prct\A2V10_prct\Rev\classes\Друид.png',Single_Blob) as image;
------------------------------------------------
create or alter procedure revstat.[Members.List.Load]
@UserId bigint,
@Id bigint = 0
as
begin
	set nocount on;

	select [Members!TMember!Array] = null, [Id!!Id] = Id, [Name], Class, BM, Def, Res, Res_crit, Res_rage,Res_pen, Crit_chance, Crit_strike, Pen, Rage
	from revstat.Members 
	order by Id asc;

end
go
------------------------------------------------
create or alter procedure revstat.[Members.Image.Update]
@UserId bigint,
@Id bigint,
@Name nvarchar(255),
@Mime nvarchar(255),
@Stream varbinary(max),
@RetId bigint output
as
begin
	set nocount on;
	declare @rt table(Id bigint );
	insert into revstat.Attachments ([Name],  Mime, Stream)
	output inserted.Id into @rt(Id)
    values (@Name, @Mime, @Stream);

	select top(1) @Id=id from @rt;
  
	select [Name]=@Name, [Id]=@Id, [Mime]=@Mime, [Stream]=@Stream, [Token]=AccessKey	
	from revstat.Attachments
	where Id=@Id;

	--exec revstat.[revstat.Image.Load] @UserId, @RetId;
end
go
------------------------------------------------
--exec revstat.[Members.Image.Load] @UserId = 99, @Id=9;
create or alter procedure revstat.[Members.Image.Load]
@UserId bigint,
@Id bigint 
as
begin
	set nocount on;
	--select [Attachments!TAttachment!Object] = null, [Id!!Id] = Id, A.Name, A.Mime, A.Stream  from revstat.Attachments A, revstat.AttachmentLinks atl where atl.AgentId=atl.ImageId;
	select [Id!!Id]=Id, [Mime], Stream, [Name], [Token]=[AccessKey] from revstat.Attachments  where Id = @Id;
end
go
------------------------------------------------
create or alter procedure revstat.[wrImageId]
@UserId bigint,
@Id bigint,
@ImageId bigint
--@RetId bigint = null output,
--@Member revstat.[Members.TableType] readonly
as
begin
	set nocount on;

	--set transaction isolation level serializable;
	--set xact_abort on;

	--declare @output table(op nvarchar(150), id bigint);
	
	--merge revstat.Members as target
	--using @Member as source
	--on (target.Id = source.Id)
	--when matched then
	--	update set
	--		target.[Image] = source.[ImageId]
	--when not matched by target then
	--insert([Image])
	--values([ImageId])
	--output
	--	$action op,
	--	inserted.Id id
	--into @output(op,id);

	--exec revstat.[Members.Load] @UserId, @RetId;

	--insert into revstat.Members ([Image])
	--select [ImageId] from @Member m, revstat.Members a
	--where m.Id = a.Id;

	--update revstat.Members
	--set
	--	[Image] = [ImageId]
	--from revstat.Members a, @Member m
	--where a.Id = m.Id;

	--exec revstat.[Members.Load] @UserId, @RetId;

	update revstat.Members
	set
		[Image] = @ImageId
	where Id = @Id;
end
go