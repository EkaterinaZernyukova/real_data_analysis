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



