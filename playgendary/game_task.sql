select  * from test.events_data where event_id = '-2376174690499544971'; --активности
select  * from test.prices_data; --продукты и цены
select  * from test.ab_data order by joined; --номер группы АБ-теста, в которую попал игрок (0— контрольная, 1 — тестовая), дата в unix
select  * from test.parameters_data where event_id = '-2376174690499544971';
select name,setting,boot_val,reset_val from pg_settings where name='temp_file_limit';

--__________________________________________________________________
--count
select count(*) from test.events_data; --37 214 636
select count(*) from test.prices_data; --23
select count(*) from test.parameters_data; --62 743 465
select count(*) from test.ab_data; --505 034
--____________________________________________________________________________
--уникальные активности:
select * , max (event_id) meid from test.events_data group by 1,2,3,4;

select max_event_id, date(data_event), user_id, event_name from 
	(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m ;


select date(data_event), count(distinct user_id) from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) meid from test.events_data where LOWER(event_name) like '%session%'  group by 1,2,3,4) m group by 1;

SELECT temp_files AS "Temporary files", temp_bytes AS "Size of temporary files"
FROM test;
--___________________________________________________________________________________
--desribe:
SELECT 
   *
FROM 
   information_schema.columns
WHERE 
   table_name = 'events_data';
--__________________________________________________________________________________
--time
select *, to_timestamp(floor(event_timestamp/1000000)) data_event from test.events_data limit 10;

select max(data_event) from (select *, to_timestamp(event_timestamp/1000000) data_event from test.events_data )m; --2019-04-30 23:59:59
select min(data_event) from (select *, to_timestamp(event_timestamp/1000000) data_event from test.events_data )m; 
--___________________________________________________________________________________________________________________
--на что тратились ( можно подтянуть в event_data)
select distinct param_value_string from (select * from test.parameters_data where param_key = 'product_id')m ;

--_____________________________________________________________________________________________________________________
--уникальность..стохастика..пропуски
select event_id, count(event_id) from (select * , max (event_id) meid from test.events_data group by 1,2,3,4) m group by event_id having count(*)>1;
select * , max (event_id) meid from test.events_data group by 1,2,3,4;
--_________________________________________________
-- убрать null
select distinct param_value_string from test.parameters_data where param_key = 'currency_type'and param_value_string like '___'; --уникальные ( кроме "" and coins = like '___')
select count(param_value_string) from test.parameters_data where param_key = 'currency_amount';--кол-во значений 271 035

select count(*) from (select  event_id, param_key, param_value_string, REGEXP_MATCHES(param_value_string, '^[0-9]*[.,][0-9]+$') as param_value_double
from (select * from test.parameters_data where param_key = 'currency_amount')m )n;
select count(*) from test.parameters_data where param_key = 'currency_amount' and param_value_string like '%.%'; --3 826
select count(*) from test.parameters_data where param_key = 'currency_amount' and param_value_double like '%.%'; --0 
--_________________________________________________________
--Выбрать покупки за период, соединить с заказами и подтянуть их цены 
--перебросить все значения в 1 столбец стринг, затем разделить по колонкам
--заменить пропуски на null

--test.events_data - event_name - in_app_purchase --Внутриигровая покупка
select count(param_value_string) from test.parameters_data where param_key = 'currency_type'and param_value_string like '___'; --4 436 платежные операции

select deistviya.param_value_string, dengi.price from test.parameters_data deistviya 
inner join test.prices_data dengi on deistviya.param_value_string = dengi.product_id where deistviya.param_key = 'product_id' ;
--перекинь в 1 столбец, затем собери test.parameters_data event_id - param_key (product_id + quantity+)

select * from test.parameters_data where event_id = '1052826320857448012';

select distinct param_value_string from test.parameters_data pd where param_key = 'quantity';
--_________________________________________________
--case
-- event_id	  param_key	  param_value_int	param_value_float	param_value_double	param_value_string

select  event_id, param_key, case  
		when NULLIF (param_value_string,'') param_value_string not is null and param_value_string not like '' then param_value_string
		when param_value_string like '' 

from test.parameters_data;
           
select count (param_value_string) from (select NULLIF (param_value_string,'') param_value_string from  test.parameters_data) n where param_value_string is NULL;          
select count (param_value_string) from  test.parameters_data where param_value_string = '';  -- param_value_string 228 872 это вместо null
select count (param_value_int) from  test.parameters_data where param_value_int = '';  -- param_value_int 62 514 591 это вместо null
select count (param_value_float) from  test.parameters_data where param_value_float = ''; --param_value_float 62 743 463 это вместо null
select count (param_value_double) from  test.parameters_data where param_value_double = ''; --param_value_double 62 743 463 это вместо null
--_____________________________________________________
select NULLIF (param_value_double,'') from test.parameters_data where param_value_double like '';

--сессии пользователей с операцией входа (возможно, сессия не была завершена в предыдущем дне)

--uniq_users_everyday = pd.read_sql(
--    """select date(data_event), count(distinct user_id) DAU from 
--    (select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) meid 
--    from test.events_data where LOWER(event_name) like '%session%' group by 1,2,3,4) uniqid 
--    group by 1""",
--    conn)
--________________________________________________
-- все в один столбец

select event_id, param_key, param_value_string, param_value_int, param_value_float, param_value_double, 
coalesce (param_value_string, param_value_int, param_value_float, param_value_double) param_value
					from (select event_id, param_key, NULLIF (param_value_string,'') param_value_string, 
										 NULLIF (param_value_int,'') param_value_int, 
										 NULLIF (param_value_float,'') param_value_float, 
										 NULLIF (param_value_double,'') param_value_double from  test.parameters_data) n
where param_key is not null;
--__________________________________________________________
--разделение

select event_id, param_key, param_value, 
		case when param_value ~ '^[\d ]+$' then cast(param_value AS INTEGER) end param_value_int,
		case when param_value ~ '^[0-9]*[.,][0-9]{3,}$' then cast(param_value AS DOUBLE PRECISION) end param_value_double,
		case when param_value ~ '^\d+(?:\.\d{1,2})$' then cast(param_value AS float) end param_value_float
from
(select event_id, param_key, 
coalesce (param_value_string, param_value_int, param_value_float, param_value_double) param_value
					from (select event_id, param_key, NULLIF (param_value_string,'') param_value_string, 
										 NULLIF (param_value_int,'') param_value_int, 
										 NULLIF (param_value_float,'') param_value_float, 
										 NULLIF (param_value_double,'') param_value_double from  test.parameters_data) n
where param_key is not null) m;
--_______________________________________________________________
--Группировка

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
select 	s.data_event, 
		count (s.user_id)	count_purchases, 
		count (distinct s.user_id) count_uniq_pay_user, 
		sum (s.revenue) total_revenue, 
		total_count.DAU,
		sum(s.revenue)/total_count.DAU ARPU, 
		sum(s.revenue)/count(distinct s.user_id) ARPPU,
		cast(count(distinct s.user_id)as float)/cast(total_count.DAU as float) paying_share,
		(cast(count(s.user_id) as float) / cast (total_count.DAU as float) *100) conversion_rate
from (
		select distinct c1.event_id, 
		c2.param_value as product_id, 
		coalesce (cast(c3.param_value as integer), 1 ) as quantity, 
		c4.param_value as currency, 
		price_game.price,
		events.user_id, events.data_event, events.event_name, 
		cast((price_game.price * coalesce (cast(c3.param_value as integer), 1 ))as double precision) revenue
			from collection c1 
					left join collection c2 on c1.event_id = c2.event_id and c2.param_key = 'product_id'
					left join collection c3 on c1.event_id = c3.event_id and c3.param_key = 'quantity'
					left join collection c4 on c1.event_id = c4.event_id and c4.param_key = 'currency'
				    left join test.prices_data price_game on c2.param_value = price_game.product_id
				    left join (select max_event_id, date(data_event) data_event, user_id, event_name from 
			(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , 
			max (event_id) max_event_id from test.events_data group by 1,2,3,4) m ) events on events.max_event_id = c1.event_id
where c1.param_key = 'product_id') s 
left join (select date(data_event) data_event, count(distinct user_id) DAU from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) max_event_id from test.events_data group by 1,2,3,4) m group by 1) total_count
		on total_count.data_event = s.data_event
group by s.data_event, total_count.dau ;
		   
--_______________________________________________________________________________________________________

select * from (select *, (secon.event_id) searh from test.events_data one left join test.parameters_data secon on one.event_id = secon.event_id)m where searh is null;

select param_key , count(param_key) coe from test.parameters_data group by param_key; having count(*)>1;

select count(*) from test.parameters_data where param_value_int = ''; --пустое поле
select * from test.parameters_data  where param_value_string like '';
select event_id from test.parameters_data group by event_id having count(*)>1;
--_________________________________________________________________________________________________________________________
--определяется путем соотношения брутто-дохода от пользователей к среднему показателю посещаемости в день/неделю/месяц.
--дата - количество посещений - доход

select distinct param_value_string from test.parameters_data where param_key = 'unlock_type';

select  count(*) from test.parameters_data where param_value_string like ''; --228 872

select  count(*) from test.parameters_data where param_value_string is NULL; --2

select  * from test.parameters_data where param_value_string is not null and (param_value_int not like '' or param_value_float not like '' or param_value_double not like '') ;--228872

select  event_id, param_key, param_value_string, REGEXP_MATCHES(param_value_string, '^[0-9]*[.,][0-9]+$') as param_value_double
from (select * from test.parameters_data where param_key = 'currency_amount')m;


select distinct param_value_string from ( select  event_id, param_key, param_value_string from test.parameters_data where param_value_string ~ '^[\d ]+$')n ;


select distinct event_name from  test.events_data where LOWER(event_name) like '%session%' group by event_name ;

--______________________________________________________________________________________________________________________________
--выбраны user_id у кого были сессии и ищу откуда сессии без входа ( возможно, пользователи не выходили с предыдущего дня)
select  event_name , count (event_name) from 
		(select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) meid from test.events_data group by 1,2,3,4) m
	where date(data_event) = '2019-04-17' and user_id not in 
			(select distinct user_id from (select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) meid from test.events_data group by 1,2,3,4) m
			where date(data_event) = '2019-04-17' and LOWER(event_name) like '%session%'
) group by event_name ;

--_____________________________________________



