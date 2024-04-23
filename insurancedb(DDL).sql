drop database insurancedb
create database insurancedb
 use insurancedb
 create table policy_name
 (policyid int primary key,
 policyname varchar(50));

 insert into policy_name(policyid,policyname)
 values(1,'life-insurance'),(2,'health-insurance'),(3,'vehicle-insurance'),(4,'fire-insurance'),(5,'liability-insurance')

create table addressdetails
 (addressid int primary key,
 houseno varchar(20),
 city varchar(20),
 statename varchar(50),
 zipcode varchar(50));

insert into addressdetails(addressid,houseno,city,statename,zipcode)
values(1,136,'dhaka','tejgaon',1215),(2,138,'dhaka','gulshan',1214),(3,139,'dhaka','mohakhali',1212),(4,140,'dhaka','demra',1216),(5,142,'dhaka','hatirjheel',1217),
      (6,144,'dhaka','nakhalpara',1215),(7,145,'dhaka','tejkunipara',1215),(8,148,'dhaka','monipuripara',1218)

 create table customerinfo
 (customerid int primary key,
 customername varchar(50),
 email varchar(50),
 mobileno varchar(50),
 addressid int references addressdetails(addressid));

 insert into customerinfo(customerid,customername,email,mobileno,addressid)
 values(1,'sohan','sohan001@gmail.com',01721267307,1),(2,'sobuj','sobuj002@gmail.com',01815245622,2),(3,'tasfia','tasfi003@gmail.com',01814865982,3),(4,'arafat','araf457@gmail.com',01678465982,4),
 (5,'meherun','meher456@gmail.com',01643698521,5),(6,'kamal','kamrul784@gmail.com',01984785961,6),(7,'sifat','sifat635@gmail.com',01456987412,7),(8,'fahim','fahim124@gmail.com',01367456894,8)

 create table policytype
(policytypeid int primary key,
 policyid int references policy_name(policyid),
 policydescription varchar(50),
 yearofpayment money,
 insurancepremiumamount money,
 meturityperiod int,
 meturityamount money);

 insert into policytype(policytypeid,policyid,policydescription,yearofpayment,insurancepremiumamount,meturityperiod,meturityamount)
 values(1,1,'accident',24000,2000,10,240000),(2,2,'healthsurokkha',6000,500,8,48000),(3,3,'caraccident',6000,500,10,60000),(4,4,'firedamage',12000,1000,10,120000),
 (5,5,'thief',24000,2000,10,240000)

 create table customerpolicyinfo
 (customerid int references customerinfo(customerid),
 policyid int references policy_name(policyid),
 policytypeid int references policytype(policytypeid),
 policyregisterdate date);

 insert into customerpolicyinfo(customerid,policyid,policytypeid,policyregisterdate)
 values(1,1,1,'2020-10-01'),(2,2,2,'2021-05-22'),(3,3,3,'2023-02-05'),(4,4,4,'2019-03-12'),(5,5,5,'2021-08-15')


 create table policypaymentsinfo
 (receiptno int primary key,
 customerid int references customerinfo(customerid),
 policyid int references policy_name(policyid),
 paymentdate date,
 amount money);

 insert into policypaymentsinfo(receiptno,customerid,policyid,paymentdate,amount)
 values(001,1,1,'2020/11/20',2000),(002,2,2,'2021/06/21',500),(003,3,3,'2023/03/25',500),(004,4,4,'2019/04/26',1000),(005,5,5,'2021/09/20',2000)

 create table claimtypes
 (claimid int primary key,
 claimdeascription varchar(50),
 customerid int references customerinfo(customerid));

 insert into claimtypes(claimid,claimdeascription,customerid)
 values(01,'bikeaccident',1),(02,'cancer',2),(03,'accidentdamage',3),(04,'firing',4),(05,'businessthief',5)


 ---1---
 select * from policytype
where meturityamount=insurancepremiumamount*meturityperiod
order by policytypeid desc
offset 0 rows
fetch first 5 rows only

----2----
select* from policypaymentsinfo
Where paymentdate>'2021/06/21'or amount>500
---3//no
select statename , paymentdate
from addressdetails a
join policypaymentsinfo p
on a.addressid=p.customerid
where statename in ('na','te','gu') and paymentdate>'2023/03/25'
----4---
select receiptno,customerid,policyid,paymentdate,amount 
from policypaymentsinfo
where paymentdate BETWEEN '2019/04/01' AND '2019/04/30'  
----5----
select customerid,customername
from customerinfo
where email  LIKE '[me,ka,si]%'
----6----
select customername
from customerinfo
where customername like '[m,k,s]%'
----7---//no
select customername, email, mobileno from customerinfo
where customername like 's[a-j]'
---8---//no
select customername, email, mobileno from customerinfo
where customername like 's[^a-j]'
---9
select* from addressdetails
order by city
OFFSET 2 rows
fetch first 5 rows ONLY
--10
select customerid, avg(amount) as averageamount
from policypaymentsinfo
group by customerid
having avg(amount)>300 
order by averageamount desc;
--11
select customername, email
from customerinfo
where  customername IN ('fahim')
group by customername, email with cube 
order by customername desc 
---12--
select statename, city,count(*) as qtycustomer
from addressdetails 
where statename IN ('gulshan')
group by statename, city with rollup 
order by statename desc, city desc;
---13--
select statename, city,count(*) as qtycustomer
from addressdetails 
where statename IN ('tejkunipara')
group by grouping sets(statename, city) 
order by statename DESC
---14---
select receiptno, paymentdate, amount, 
sum (amount) over(order by paymentdate) as sumTotal 
from policypaymentsinfo
---15---
select distinct customername,
receiptno as newreciept,
paymentdate,amount
from customerinfo c
join policypaymentsinfo p on p.customerid = c.customerid
where  paymentdate in
(select distinct min( paymentdate)
from policypaymentsinfo p
join customerinfo c on p.customerid = c.customerid
group by c.customername)
order by paymentdate
---16---
select  receiptno, amount as totalamount
from policypaymentsinfo join customerinfo on policypaymentsinfo.customerid = customerinfo.customerid
where amount<any
(select amount
from policypaymentsinfo
where customerid = 2);
---17---
select  receiptno, amount as totalamount
from policypaymentsinfo join customerinfo on policypaymentsinfo.customerid = customerinfo.customerid
where amount<all
(select amount
from policypaymentsinfo
where customerid = 3);
---18---
select  receiptno, amount as totalamount
from policypaymentsinfo join customerinfo on policypaymentsinfo.customerid = customerinfo.customerid
where amount<some
(select amount
from policypaymentsinfo
where customerid = 2);
----19---
insert into addressdetails(addressid,houseno,city,statename,zipcode)
values(9,150,'chittagong','lakshmipur',3701)
---20---
with CTE_Samary as
(select distinct customername,
receiptno as newreciept,
paymentdate,amount
from customerinfo c
join policypaymentsinfo p on p.customerid = c.customerid
where  paymentdate in
(select distinct min( paymentdate)
from policypaymentsinfo p
join customerinfo c on p.customerid = c.customerid
group by c.customername)
)
select * from CTE_Samary
---21---
delete from addressdetails where addressid = 9