ALTER SYSTEM SET temp_file_limit="10GB";

select name,setting,boot_val,reset_val from pg_settings where name='temp_file_limit';

create table movement(
good_id int,
movement_dt date,
movement_cnt int );

insert into movement values 
(1,'01.11.2019', 1000),
(1,'03.11.2019',-300),
(1,'05.11.2019', 500),
(2,'01.11.2019', 500),
(2,'11.11.2019',-500);

insert into movement values 
(1,'05.11.2019', -450);

select * from movement order by  good_id, movement_dt asc;
          
--добавление промежуточных дат
		select m.good_id,
m.movement_dt,
coalesce(s.movement_cnt, 0) movement_cnt
from
(
select
	good_id,
	n.movement_dt,
	max(good_id)
from
	movement
cross join (
	select
		generate_series(min(movement_dt), max(movement_dt), '1d')::date as movement_dt
	from
		movement)n
group by
	1,
	2
order by
	good_id,
	movement_dt) m
left join movement s on
s.good_id = m.good_id
and s.movement_dt = m.movement_dt;

--Задача 1
--остаток товара на конец дня в каждый день, когда по нему проходили движения:

select good_id,
       movement_dt,
       balance_of_goods,
       sum(movement_cnt) movement_cnt
from 
 (select good_id,
       movement_dt,
       movement_cnt,
sum(movement_cnt) over (partition by good_id order by movement_dt asc) balance_of_goods
from movement) operations 
	group by 1,2,3
	order by good_id, movement_dt asc;
   
-- Задача 2
--остаток товара на конец дня за каждый день, начиная с даты первого движения по этому товару
--(в запросе из первой задачи изменен источник "movement" на внутренний запрос "добавление промежуточных дат")

 select
	good_id,
	movement_dt,
	balance_of_goods,
	sum(movement_cnt) movement_cnt
from
	(
	select
		good_id,
		movement_dt,
		movement_cnt,
		sum(movement_cnt) over (partition by good_id
	order by
		movement_dt asc) balance_of_goods
	from
		(
		select
			m.good_id,
			m.movement_dt,
			coalesce(s.movement_cnt, 0) movement_cnt
		from
			(
			select
				good_id,
				n.movement_dt,
				max(good_id)
			from
				movement
			cross join (
				select
					generate_series(min(movement_dt), max(movement_dt), '1d')::date as movement_dt
				from
					movement)n
			group by
				1,
				2
			order by
				good_id,
				movement_dt) m
		left join movement s on
			s.good_id = m.good_id
			and s.movement_dt = m.movement_dt)t) operations
group by
	1,
	2,
	3
order by
	good_id,
	movement_dt asc;


