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

