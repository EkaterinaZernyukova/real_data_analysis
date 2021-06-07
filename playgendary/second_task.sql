select  * from test.events_data where event_id = '8465776270113871125'; --активности
select  * from test.prices_data; --продукты и цены
select  * from test.ab_data order by joined; --номер группы АБ-теста, в которую попал игрок (0— контрольная, 1 — тестовая), дата в unix
select  * from test.parameters_data where event_id = '-9039216215849973891';
select name,setting,boot_val,reset_val from pg_settings where name='temp_file_limit';


select distinct param_key from test.parameters_data where param_value_string like '%com.playgendary.%';

select event_id, param_value_string, count (param_value_string) from test.parameters_data  where  param_key = 'content_type' group by 1,2;
;

with collection as (
select event_id, param_key, param_value, 
		case when param_value ~ '^[\d ]+$' then cast(param_value AS bigint) end param_value_int,
		case when param_value ~ '^[0-9]*[.,][0-9]{3,}$' then cast(param_value AS DOUBLE PRECISION) end param_value_double,
		case when param_value ~ '^\d+(?:\.\d{1,2})$' then cast(param_value AS float) end param_value_float
from
(select event_id, param_key, 
coalesce (param_value_string, param_value_int, param_value_float, param_value_double) param_value
					from (select event_id, param_key, NULLIF (param_value_string,'') param_value_string, 
										 NULLIF (param_value_int,'') param_value_int, 
										 NULLIF (param_value_float,'') param_value_float, 
										 NULLIF (param_value_double,'') param_value_double from  test.parameters_data) n
where param_key is not null) m) 
		select distinct c1.event_id, 
		c2.param_value as product_id, 
		coalesce (cast(c3.param_value as integer), cast(1 as integer) ) as quantity, 
		c4.param_value as currency, 
		c5.param_value as currency_type, 
		price_game.price,
		events.max_event_id, events.user_id, events.data_event, events.event_name, 
		(price_game.price * cast(c3.param_value as integer)) revenue
			from collection c1 
					left join collection c2 on c1.event_id = c2.event_id and c2.param_key = 'product_id'
					left join collection c3 on c1.event_id = c3.event_id and c3.param_key = 'quantity'
					left join collection c4 on c1.event_id = c4.event_id and c4.param_key = 'currency'
				    left join collection c5 on c1.event_id = c5.event_id and c5.param_key = 'currency_type'
				    left join test.prices_data price_game on c2.param_value = price_game.product_id
				    left join (select max_event_id, date(data_event) data_event, user_id, event_name from 
			(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , 
			max (event_id) max_event_id from test.events_data group by 1,2,3,4) m ) events on events.max_event_id = c1.event_id
where c1.param_key = 'product_id';

--____________________________________________________________________________________________________________________
--покупка оружия)
with guns as (select event_id, param_value_string, count (param_value_string) from test.parameters_data  where  param_key = 'content_type' group by 1,2)
select data_event, event_name, param_value_string, count (user_id) total_use_u, count (distinct event_id) total_use_e, count ( distinct user_id) count_user
from
(select guns.event_id, guns.param_value_string, date(total_count.data_event) data_event, total_count.event_name, total_count.user_id
from guns left join (select *, 
			to_timestamp(floor(event_timestamp/1000000)) data_event, max (event_id) max_event_id from test.events_data group by 1,2,3,4) total_count
		on guns.event_id = total_count.max_event_id)x group by 1,2,3;

--------------------за месяц
	
with guns as (select event_id, param_value_string, count (param_value_string) from test.parameters_data  where  param_key = 'content_type' group by 1,2)
select event_name, param_value_string, count (user_id) total_use_u, count (distinct event_id) total_use_e, count ( distinct user_id) count_user
from
(select guns.event_id, guns.param_value_string, date(total_count.data_event) data_event, total_count.event_name, total_count.user_id
from guns left join (select *, 
			to_timestamp(floor(event_timestamp/1000000)) data_event, max (event_id) max_event_id from test.events_data group by 1,2,3,4) total_count
		on guns.event_id = total_count.max_event_id)x group by 1,2;
--______________________________________________________________________________-
--	группы игроков
select user_id, count(distinct date(data_event)) loyal_day
from 
	(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m group by 1 having count(distinct date(data_event)) > 15;	

select max_event_id, date(data_event) data_event, user_id, event_name
from 
	(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m ;	
	
	

with collection as (
		select event_id, param_key, param_value
		from
		(select event_id, param_key, 
		coalesce (param_value_string, param_value_int, param_value_float, param_value_double) param_value
							from (select event_id, param_key, 
												 NULLIF (param_value_string,'') param_value_string, 
												 NULLIF (param_value_int,'') param_value_int, 
												 NULLIF (param_value_float,'') param_value_float, 
												 NULLIF (param_value_double,'') param_value_double 
								 from  test.parameters_data) n
		where param_key is not null) m) 
select 	 
		s.user_id, 
		sum(s.revenue),
		count (s.user_id) count_purchases,
		count (s.data_event) count_data_event
from (
		select distinct c1.event_id, 
		c2.param_value as product_id, 
		coalesce (cast(c3.param_value as integer), 1 ) as quantity, 
		price_game.price,
		events.user_id, events.data_event, events.event_name, 
		cast((price_game.price * coalesce (cast(c3.param_value as integer), 1 ))as double precision) revenue
			from collection c1 
					left join collection c2 on c1.event_id = c2.event_id and c2.param_key = 'product_id'
					left join collection c3 on c1.event_id = c3.event_id and c3.param_key = 'quantity'
				    left join test.prices_data price_game on c2.param_value = price_game.product_id
				    left join (select max_event_id, date(data_event) data_event, user_id, event_name from 
			(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , 
			max (event_id) max_event_id from test.events_data group by 1,2,3,4) m ) events on events.max_event_id = c1.event_id
where c1.param_key = 'product_id') s 
left join (select date(data_event) data_event, count(distinct user_id) DAU from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m group by 1) total_count
		on total_count.data_event = s.data_event
group by 1;	
	
--___________________________________________________________________________
--сколько дней юзер был в игре непрерывно
(select user_id, date(data_event) data_event, count(max_event_id)  from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m group by 1,2) ;
	
WITH
  dates(date) AS (
    SELECT DISTINCT CAST(data_event AS DATE) AS date
    FROM (select user_id, date(data_event) data_event, count(max_event_id)  from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m group by 1,2) n
    WHERE user_id = 'c614f8aa-53fe-4bd7-85fd-091e2f2f8bf0'
  ),
  groups AS (
    SELECT
      ROW_NUMBER() OVER (ORDER BY date) AS rn,
      dateadd(day, -ROW_NUMBER() OVER (ORDER BY date), date) AS grp,
      date
    FROM dates
  )
SELECT
  COUNT(*) AS consecutiveDates,
  MIN(week) AS minDate,
  MAX(week) AS maxDate
FROM groups
GROUP BY grp
ORDER BY 1 DESC, 2 desc;

with ab_test as (select user_id, ab_group, date(to_timestamp(floor(joined/1000000))) joined_dt from test.ab_data order by joined)
select m.max_event_id, date(m.data_event) data_event, m.user_id, m.event_name , ab_test.ab_group from 
	(select *, date(to_timestamp(floor(event_timestamp/1000000))) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m 
	left join ab_test on m.user_id = ab_test.user_id and m.data_event>= ab_test.joined_dt;

with 
ab_test as (select user_id, ab_group, date(to_timestamp(floor(joined/1000000))) joined_dt from test.ab_data order by joined),
users as (select m.max_event_id, date(m.data_event) data_event, m.user_id, m.event_name , ab_test.ab_group from 
	(select *, date(to_timestamp(floor(event_timestamp/1000000))) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m 
	left join ab_test on m.user_id = ab_test.user_id and m.data_event>= ab_test.joined_dt)
select ab_group, count(distinct user_id) DAU from users group by 1;
	
with 
collection as (
		select event_id, param_key, param_value
		from
		(select event_id, param_key, 
		coalesce (param_value_string, param_value_int, param_value_float, param_value_double) param_value
							from (select event_id, param_key, 
												 NULLIF (param_value_string,'') param_value_string, 
												 NULLIF (param_value_int,'') param_value_int, 
												 NULLIF (param_value_float,'') param_value_float, 
												 NULLIF (param_value_double,'') param_value_double 
								 from  test.parameters_data) n
		where param_key is not null) m),
ab_test as (select user_id, ab_group, date(to_timestamp(floor(joined/1000000))) joined_dt from test.ab_data order by joined),
users as (select m.max_event_id, date(m.data_event) data_event, m.user_id, m.event_name , ab_test.ab_group from 
	(select *, date(to_timestamp(floor(event_timestamp/1000000))) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m 
	left join ab_test on m.user_id = ab_test.user_id and m.data_event>= ab_test.joined_dt),
dau as (select data_event, ab_group, count(distinct user_id) DAU from users group by 1,2),
mau as (select ab_group, count(distinct user_id) MAU from users group by 1)	
select distinct c1.event_id,
		c2.param_value as product_id, 
		coalesce (cast(c3.param_value as integer), 1 ) as quantity,  
		price_game.price,
		events.user_id, 
		events.data_event, 
		events.event_name, 
		cast((price_game.price * coalesce (cast(c3.param_value as integer), 1 ))as double precision) revenue,
		count (events.user_id) over (partition by events.data_event) users_in_day
			from collection c1 
					left join collection c2 on c1.event_id = c2.event_id and c2.param_key = 'product_id'
					left join collection c3 on c1.event_id = c3.event_id and c3.param_key = 'quantity'
				    left join test.prices_data price_game on c2.param_value = price_game.product_id
				    left join (select max_event_id, date(data_event) data_event, user_id, event_name from 
			(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , 
			max (event_id) max_event_id from test.events_data where user_id in (select user_id from (
select user_id, ab_group, date(to_timestamp(floor(joined/1000000))) joined_dt from test.ab_data order by joined) m where ab_group = 1) group by 1,2,3,4) m ) events 
on events.max_event_id = c1.event_id
where c1.param_key = 'product_id';
	
	
	
	
               