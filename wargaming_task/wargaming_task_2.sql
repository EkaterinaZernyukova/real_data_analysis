--Задание выполнено для СУБД PostgreSQL 12.4 

--Вводные данные: 
--В период с 08.01.18 по 09.01.18 был проведен A/B тест. Тестовой группе был предложен товар со скидкой.

--Задача:
--Оцените эффект данной скидки с точки зрения изменения дохода для пользователей RU региона.
--Оформить в виде выводов с визуализацией, кратко пояснить методологию расчетов. 
--Написать SQL запрос.

--Данные необходимо забрать с помощью SQL запроса:
--Имеются 2 таблицы с данными. 
--В первой таблице «Users» содержатся идентификационный номер пользователей «SPA_ID», регион «Realm» и тип группы «Type_of_group». 
--Во второй таблице «Revenue» содержатся идентификационный номер пользователей «SPA_ID», дата «DT» и «Revenue» (запись отсутствует, если пользователь не платил). 


--Создание временной таблицы
CREATE TEMPORARY TABLE wargaming_all("SPA_ID" int8 NULL,
	"Realm" text NULL,
	"Type_of_group" text NULL,
	"dt" text NULL,
	"Revenue" float8 NULL
);

--Вставка во временную таблицу результата JOIN
INSERT INTO wargaming_all
SELECT
	* 
FROM
	wargaming 
left JOIN wargaming_second
USING ("SPA_ID")
--ON wargaming."SPA_ID" = wargaming_second."SPA_ID"
WHERE 
	wargaming."Realm" = 'RU'
and
	(wargaming_second."dt" = '1/8/2018' 
	OR wargaming_second."dt" = '1/9/2018')
ORDER BY
	wargaming."SPA_ID";

--Агрегирование выручки по группам Type_of_group

--средняя выручка, общая выручка и количество операций в группах (wargaming_agg)
CREATE TEMPORARY TABLE wargaming_agg("Type_of_group" text NULL,
	"summ" float8 NULL,
	"avg_revenue" float8 NULL,
	"count_transaction" int8 NULL
);

--INSERT INTO wargaming_agg
 SELECT
	DISTINCT "Type_of_group",
	sum (wargaming_all."Revenue") OVER (PARTITION BY wargaming_all."Type_of_group") AS summ,
	avg(wargaming_all."Revenue") OVER (PARTITION BY wargaming_all."Type_of_group") as avg_revenue,
	count(wargaming_all."Revenue") OVER (PARTITION BY wargaming_all."Type_of_group") AS count_transaction
FROM
	wargaming_all;


--количество уникальных id в группах (wargaming_uniq_id_pay), пользователей, которые платили
CREATE TEMPORARY TABLE wargaming_uniq_id_pay("Type_of_group" text NULL,
	"count_id_pay" int8 NULL
);

--INSERT INTO wargaming_uniq_id_pay
SELECT "Type_of_group", count (DISTINCT "SPA_ID") as count_id_pay FROM wargaming_all group by "Type_of_group";

--количество уникальных id в группах (wargaming_uniq_id_group)

CREATE TEMPORARY TABLE wargaming_uniq_id_group("Type_of_group" text NULL,
	"count_id_max" int8 NULL
);

--INSERT INTO wargaming_uniq_id_group
SELECT "Type_of_group", count (DISTINCT "SPA_ID") as count_id_max FROM wargaming group by "Type_of_group";

-- сводная таблица агрегированных значений по группам
CREATE TEMPORARY TABLE wargaming_total("Type_of_group" text NULL,
	"summ" float8 NULL,
	"avg_revenue" float8 NULL,
	"count_transaction" int8 NULL,
	"count_id_pay" int8 NULL,
	"count_id_max" int8 NULL
);


--INSERT INTO wargaming_total
SELECT * from wargaming_agg LEFT JOIN wargaming_uniq_id_pay USING ("Type_of_group")
LEFT JOIN wargaming_uniq_id_group USING ("Type_of_group")

--Итог
Select*from wargaming_total

