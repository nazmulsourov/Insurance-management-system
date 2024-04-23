use insurancedb

create clustered index Indexpolicypaymentsinfo
on policypaymentsinfo(policyid )
---join query---
select customerinfo.customername,policy_name.policyid,customerinfo.customerid,policytype.policytypeid
From customerpolicyinfo join customerinfo
on  customerinfo.customerid=customerpolicyinfo.customerid
join policy_name
on  policy_name.policyid=customerpolicyinfo.policyid
join policytype
on policytype. policytypeid=customerpolicyinfo.policytypeid
where policydescription='caraccident'
order by customerpolicyinfo.customerid
---sub query---
select customerpolicyinfo.customerid,policytypeid
From customerpolicyinfo
join policy_name
on policy_name.policyid = customerpolicyinfo.policyid
where customerid in(select customerid from customerinfo)
group by customerpolicyinfo.customerid,policytypeid
---trigger---
create trigger Tr_Instead
on policy_name
instead of delete
as
begin
declare policyid int
select policyid = DELETED.policyid   
from DELETED
if policyid = 2
begin
raiserror('ID 2 record cannot be deleted',16 ,1)
rollback
insert into policy_name
values(policyid, 'Record cannot be deleted.')
end
else
begin
delete from policy_name
where policyid  = policyid 
insert into policy_name
values(policyid, 'Instead Of Delete')
end
end
---create view encryption---
create view vw_enccryption
with encryption
as
select policyid 
from policy_name
select * from vw_enccryption
---create view Schemabinding---
create view vw_schemabinding
with schemabinding
as
select policyid 
from dbo.policy_name
select * from vw_schemabinding
---table value function---
create function fnpolicy_name
()
returns table
return
(select * from policy_name)
select * from dbo.policy_name()
---Scalar value function ---
create function fn_policy_name
()
returns int
begin
declare @c int;
select @c = count(*) from policy_name;
return @c;
end;
select dbo.policy_name();
---multi statement function---
create function fn_policypaymentsinfo
()
returns @outtable table(policyid int,
amount decimal(18,2), amount_extent 
decimal(18,2))
begin
insert into @outTable(policyid,amount,amount_extent )
select policyid,amount,amount = amount+200
from policypaymentsinfo;
return;
end;


----stored procedure select-insert-update-delete---
create procedure sp_policyall
(@policyid int,
@policyname varchar(100),    
@statementtype nvarchar(20) = '')
as
if @statementtype = 'select'
begin
select* from policy_name
end

if @statementtype = 'insert'
begin
insert into policy_name(policyid,policyname)
values (@policyid, @policyname)
end

if @statementtype = 'update'
begin
update policy_name
set policyname = @policyname
where policyid = @policyid
end

if @statementtype = 'delete'
begin
delete policy_name
where policyid = @policyid
end
----test procedure---
execute sp_policyall 6,'property-insurance','insert'
execute sp_policyall 6,'general-insurance','update'
execute sp_policyall 6,'property-insurance','delete'
select * from policy_name

-- procedure in parameter---
go
create proc sp_in
@policyid int,
@policyname varchar(100)
as
insert into policy_name values(@policyid,@policyname)
go
exec sp_in 6,'property-insurance'
---output---
go
create proc sp_out
@policyid int output
as
select count(*) from policy_name
exec sp_out 6

-- procedure with return statement---
go
drop proc sp_return
go
create procedure sp_return
(@policyid int )
as
Select policyid, policyname from policy_name where policyid=@policyid
go
declare @return_value int
exec @return_value =sp_return
@policyid=6
select 'return value'=@return_value






