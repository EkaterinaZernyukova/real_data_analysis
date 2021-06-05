select  * from test.events_data where event_id = '-324300537850228907'; --активности
select  * from test.prices_data;                                        --продукты и цены
select  * from test.ab_data order by joined;                            --номер группы АБ-теста, в которую попал игрок (0— контрольная, 1 — тестовая), дата в unix
select  * from test.parameters_data; where event_id = '-9223360765636872211';
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


select date(data_event), count(distinct user_id) from (select *, to_timestamp(floor(event_timestamp/1000000)) data_event , max (event_id) meid from test.events_data group by 1,2,3,4) m group by 1;

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
select distinct param_value_string from test.parameters_data where param_key = 'currency_amount'; --уникальные
select count(param_value_string) from test.parameters_data where param_key = 'currency_amount';--кол-во значений 271 035

select count(*) from (select  event_id, param_key, param_value_string, REGEXP_MATCHES(param_value_string, '^[0-9]*[.,][0-9]+$') as param_value_double
from (select * from test.parameters_data where param_key = 'currency_amount')m )n;
select count(*) from test.parameters_data where param_key = 'currency_amount' and param_value_string like '%.%'; --3 826
select count(*) from test.parameters_data where param_key = 'currency_amount' and param_value_double like '%.%'; --0 


--_________________________________________________


select * from (select *, (secon.event_id) searh from test.events_data one left join test.parameters_data secon on one.event_id = secon.event_id)m where searh is null;

select param_key , count(param_key) coe from test.parameters_data group by param_key; having count(*)>1;

select count(*) from test.parameters_data where param_value_int = ''; --пустое поле
select * from test.parameters_data  where param_value_string like '';
select event_id from test.parameters_data group by event_id having count(*)>1;
--____________________________________________
--определяется путем соотношения брутто-дохода от пользователей к среднему показателю посещаемости в день/неделю/месяц.
--дата - количество посещений - доход

select max (cast(param_value_string AS float))from test.parameters_data where param_key = 'currency_amount';

select  count(*) from test.parameters_data where param_value_string like ''; --228 872

select  count(*) from test.parameters_data where param_value_string is NULL; --2

select  * from test.parameters_data where param_value_string is not null and (param_value_int not like '' or param_value_float not like '' or param_value_double not like '') ;--228872


