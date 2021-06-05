create table lider(
id int,
name_f varchar(38),
id_manager int );

insert into lider values 
(11,'Max', 4),
(12,'Alex',4),
(13,'San', 3),
(14,'Jim', 2),
(15,'Max',2);

with recursive temp1 ( ID,
id_manager,
name_f,
path,
level ) as (
select
	T1.id,
	T1.id_manager,
	T1.name_f,
	cast (T1.id as VARCHAR (50)) as path,
	1
from
	lider T1
where
	T1.id_manager = 0
union
select
	T2.id,
	T2.id_manager,
	T2.name_f,
	cast ( temp1.PATH || '->' || T2.id as VARCHAR(50)) ,
	level + 1
from
	lider T2
inner join temp1 on
	( temp1.id = T2.id_manager) )
select
	*
from
	temp1
order by
	path
limit 100;