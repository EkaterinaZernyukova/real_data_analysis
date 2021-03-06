SQL Есть 2 таблицы с информацией о клиентах (customer_info.xlsx) и транзакциях за период с 01.06.2015 по 01.06.2016 (Transactions_info.xlsx). Необходимо выполнить следующие задания: Вывести список клиентов с непрерывной историей за год,
средний чек за период,
средняя сумма покупок за месяц,
количество всех операций по клиенту за период Вывести помесячную информацию: средняя сумма чека в месяц,
среднее количество операций в месяц,
среднее количество клиентов,
которые совершали операции;

Долю от общего количества операций за год и долю в месяц от общей суммы операций;

Вывести % соотношение M / F / NA в каждом месяце с их долей затрат Вывести возрастные группы клиентов с шагом 10 лет и отдельно клиентов,
у которых нет данной информации с параметрами
--Удаление лишних символов из transactions_info."ID_client"
 UPDATE
	transactions_info
SET
	"ID_client" = REPLACE("ID_client", '_x003', '');

UPDATE
	transactions_info
SET
	"ID_client" = REPLACE("ID_client", '_x005F', '');

UPDATE
	transactions_info
SET
	"ID_client" = REPLACE("ID_client", '_', '');
--  Изменение типа данных
 ALTER TABLE transactions_info ALTER COLUMN "ID_client" TYPE integer
	USING ("ID_client"::integer);

ALTER TABLE digital_all ALTER COLUMN "date_new" TYPE timestamp
	USING ("date_new"::timestamp);
--Добавление нового столбца
 ALTER TABLE transactions_info ADD COLUMN "Id_client" integer;

UPDATE
	transactions_info
SET
	"Id_client" = "ID_client";

ALTER TABLE transactions_info DROP COLUMN "ID_client";
--сводная таблица данных
 CREATE TEMPORARY TABLE digital_all("Id_client" int8 NULL, "Total_amount" int8 NULL, "Gender" TEXT NULL, "Age" float8 NULL, "Count_city" int8 NULL, "Response_communcation" int8 NULL, "Communication_3month" int8 NULL, "Tenure" int8 NULL, "date_new" TEXT NULL, "Id_check" int8 NULL, "Count_products" float8 NULL, "Sum_payment" float8 NULL );
--INSERT INTO digital_all
 SELECT
	*
FROM
	customer_info
LEFT JOIN transactions_info
		USING ("Id_client");
	
--1. вывести список клиентов с непрерывной историей за год
 SELECT
	*
FROM
	digital_all
WHERE
	"date_new" >= '01.07.2015';

--2. Средний чек за период
 SELECT
	"Id_client",
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check"))::NUMERIC, 2) AS "average_year_check"
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;

--3. Средняя сумма покупок за месяц 
 SELECT
	"Id_client",
	ROUND((sum("Sum_payment")/ 13)::NUMERIC, 2) AS "average_monthly_purchases"
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;
--4. количество всех операций по клиенту за период
 SELECT
	"Id_client",
	count (DISTINCT "Id_check") AS count_id_check
FROM
	digital_all
GROUP BY
	"Id_client";
--Вывести помесячную информацию:

--5. средняя сумма чека в месяц 
 SELECT
	to_char("date_new", 'YY-Mon') AS year_month,
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check"))::NUMERIC, 2) AS average_summ_monthly_check
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;
--помесячно по клиентам средняя сумма чека в месяц
 SELECT
	"Id_client",
	to_char("date_new", 'YY-Mon') AS year_month,
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check"))::NUMERIC, 2) AS average_monthly_check
FROM
	digital_all
GROUP BY
	1,
	2
ORDER BY
	1;

--6. среднее количество операций в месяц 
--среднее количество операций в месяц через оконную
 CREATE TEMPORARY TABLE digital_chesk("year_month" TEXT NULL, "monthly_check" float8 NULL );
--INSERT INTO digital_chesk
 SELECT
	to_char("date_new", 'YY-Mon') AS year_month,
	count (DISTINCT "Id_check") AS monthly_check
FROM
	digital_all
GROUP BY
	1;

SELECT
	*,
	ROUND(avg("monthly_check") OVER( ) ::NUMERIC, 2) AS average_monthly_check
FROM
	digital_chesk;

--помесячно по клиентам среднее количество операций в месяц
 SELECT
	"Id_client",
	count (DISTINCT "Id_check")/ 13 AS average_count_checks_per_month
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;

--7. среднее количество клиентов, которые совершали операции; 

--(столбец со средним можно добавить через временную таблицу и avg в оконной функции как в задании 6)
 SELECT
	count (DISTINCT "Id_client")/ 13 AS average_count_clients_per_month
FROM
	digital_all;
--количество клиентов, которые совершали операции ежемесячно 
 SELECT
	to_char("date_new", 'YY-Mon') AS year_month,
	count (DISTINCT "Id_client") AS count_clients_per_month
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;

--8.  Долю от общего количества операций за год и долю в месяц от общей суммы операций;
--сводная таблица данных
 CREATE TEMPORARY TABLE digital_share("date_new" TEXT NULL, "count_checks_per_month" float8 NULL, "sum_per_month" float8 NULL );
--INSERT INTO digital_share
 SELECT
	to_char("date_new", 'YY-Mon') AS year_month,
	count (DISTINCT "Id_check") AS count_checks_per_month,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS sum_per_month
FROM
	digital_all
GROUP BY
	1
ORDER BY
	1;

SELECT
	"date_new",
	ROUND((100.0 * count_checks_per_month / sum(count_checks_per_month) OVER ())::NUMERIC, 2) AS percent_check,
	ROUND(( count_checks_per_month / sum(count_checks_per_month) OVER ())::NUMERIC, 2) AS share_check,
	ROUND((100.0 * sum_per_month / sum(sum_per_month) OVER ())::NUMERIC, 2) AS percent_sum,
	ROUND((sum_per_month / sum(sum_per_month) OVER ())::NUMERIC, 2) AS share_sum
FROM
	digital_share;

--9. Вывести % соотношение M / F / NA в каждом месяце с их долей затрат 
--сводная таблица данных
 CREATE TEMPORARY TABLE digital_gender("date_new" TEXT NULL, "Gender" TEXT NULL, "count_gender" int8 NULL, "cost_gender" float8 NULL);
--INSERT INTO digital_gender
 SELECT
	to_char("date_new", 'YY-Mon') AS year_month,
	"Gender",
	count(DISTINCT "Id_client") AS count_gender,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS cost_gender
FROM
	digital_all
GROUP BY
	1,
	2;

SELECT
	*,
	ROUND((100.0 * count_gender / sum(count_gender) OVER (PARTITION BY "date_new"))::NUMERIC, 2) AS percent_gender,
	ROUND((cost_gender / sum(cost_gender) OVER (PARTITION BY "date_new"))::NUMERIC, 2) AS share_cost
FROM
	digital_gender
ORDER BY
	1;

--	10. Вывести возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации 
--с параметрами сумма и количество операций за весь период, и поквартально, средние показатели и %.
--Создать столбец age_step, заполнить возрастными группами 

ALTER TABLE digital_all ADD COLUMN "age_step" integer;

UPDATE
	digital_all
SET
	"age_step" = trunc("Age"/10.0) * 10+10;

---Возрастные группы клиентов с шагом 10 лет с параметрами сумма и количество операций за квартал и средними показателями

select 
 "age_step",
 count (DISTINCT "Id_check") AS quarter_count_checks,
ROUND(sum("Sum_payment")::NUMERIC, 2) AS quarter_sum,
 extract(quarter from "date_new") as quarter,
 extract(year from "date_new") as year,
 count (DISTINCT "Id_check")/ count (DISTINCT "Id_client") AS avg_count_checks_per_id, --(средняя сумма чека в группе в квартал)
ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в группе в квартал)
from 
  digital_all
where
	"age_step" is not NULL
group by 
	1,5,4
order by 
1;
  
--Возрастные группы клиентов с шагом 10 лет с параметрами сумма и количество операций за весь период и средними показателями
  
SELECT
	"age_step",
	count (DISTINCT "Id_check") AS total_count_checks,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS total_sum,
	count (DISTINCT "Id_check")/ count (DISTINCT "Id_client") AS avg_count_checks_per_id, --(среднее количество чеков у клиентов в группе)
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в группе)
FROM
	digital_all
where
	"age_step" is not NULL
GROUP BY
	1;


--Возрастные группы клиентов с шагом 10 лет с параметрами сумма и количество операций за весь период, средними показателями и %
--__________________________________________________________________________________
--сводная таблица данных
 CREATE TEMPORARY TABLE digital_group_age("age_step" int8 NULL, "total_count_checks" float8 NULL, 
"total_sum" float8 NULL, "avg_count_checks_per_id" float8 NULL, "avg_sum_in_check" float8 NULL);

--INSERT INTO digital_group_age
SELECT
	"age_step",
	count (DISTINCT "Id_check") AS total_count_checks,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS total_sum,
	count (DISTINCT "Id_check")/ count (DISTINCT "Id_client") AS avg_count_checks_per_id, --(среднее количество чеков у клиентов в группе)
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в группе)
FROM
	digital_all
GROUP BY
	1;

SELECT
	*, ROUND((100* "total_sum" /sum("total_sum") OVER ())::NUMERIC,1) AS percent_total_sum, --(% суммы от всех возрастных групп)
	ROUND((100* "total_count_checks" /sum("total_count_checks") OVER ())::NUMERIC,1) AS percent_total_check --(% чеков от всех возрастных групп)
FROM
	digital_group_age
where
	"age_step" is not NULL
ORDER BY
	1;
____________________________________________
  
 --Клиенты у которых нет данных о возрасте с параметрами сумма и количество операций за весь период и средними показателями
  SELECT
	"Id_client",
	count (DISTINCT "Id_check") AS total_count_checks,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS total_sum,
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в группе)	
FROM
	digital_all
where
	"age_step" is NULL
GROUP BY
	1;
  

---Клиенты у которых нет данных о возрасте с параметрами сумма и количество операций за квартал и средними показателями

select 
 "Id_client",
 count (DISTINCT "Id_check") AS quarter_count_checks,
ROUND(sum("Sum_payment")::NUMERIC, 2) AS quarter_sum,
 extract(quarter from "date_new") as quarter,
 extract(year from "date_new") as year,
ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в квартал)
from 
  digital_all
where
	"age_step" is NULL
group by 
	1,5,4
order by 
1;


---Клиенты у которых нет данных о возрасте с параметрами сумма и количество операций за весь период, средними показателями и %
--__________________________________________________________________________________
--сводная таблица данных
CREATE TEMPORARY TABLE digital_group_no_age("Id_client" int8 NULL, "age_step" int8 NULL, "total_count_checks" float8 NULL, "total_sum" float8 NULL, 
"avg_sum_in_check" float8 NULL);

--INSERT INTO digital_group_no_age
SELECT
	"Id_client", "age_step",
	count (DISTINCT "Id_check") AS total_count_checks,
	ROUND(sum("Sum_payment")::NUMERIC, 2) AS total_sum,
	ROUND((sum("Sum_payment")/ count (DISTINCT "Id_check") )::NUMERIC, 2) AS avg_sum_in_check --(средняя сумма чека в группе)
FROM
	digital_all
GROUP BY
	1,2;

SELECT
	*, ROUND((100* "total_sum" /sum("total_sum") OVER ())::NUMERIC,1) AS percent_total_sum, --(% суммы от всех клиентов без данных о возрасте)
	ROUND((100* "total_count_checks" /sum("total_count_checks") OVER ())::NUMERIC,1) AS percent_total_check --(% чеков от всех клиентов без данных о возрасте)
FROM
	digital_group_no_age
where
	"age_step" is NULL
ORDER BY
	1;












  