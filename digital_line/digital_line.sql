SQL 
Есть 2 таблицы с информацией о клиентах (customer_info.xlsx) и транзакциях за период с 01.06.2015 по 01.06.2016 (Transactions_info.xlsx).
Необходимо выполнить следующие задания:

Вывести список клиентов с непрерывной историей за год, 
средний чек за период, 
средняя сумма покупок за месяц, 
количество всех операций по клиенту за период

 Вывести помесячную информацию: 
средняя сумма чека в месяц, 
среднее количество операций в месяц, 
среднее количество клиентов, которые совершали операции; 

Долю от общего количества операций за год 
и долю в месяц от общей суммы операций; 

Вывести % соотношение M/F/NA в каждом месяце с их долей затрат

Вывести возрастные группы клиентов с шагом 10 лет и отдельно клиентов, 
у которых нет данной информации с параметрами


--Удаление лишних символов из transactions_info."ID_client"

UPDATE 
   transactions_info
SET 
   "ID_client" = REPLACE("ID_client",'_x003', '');

  UPDATE 
   transactions_info
SET 
   "ID_client" = REPLACE("ID_client",'_x005F', '');

UPDATE 
   transactions_info
SET 
   "ID_client" = REPLACE("ID_client",'_','');
  
--  Изменение типа данных
ALTER TABLE transactions_info ALTER COLUMN "ID_client" TYPE integer USING ("ID_client"::integer);
ALTER TABLE digital_all ALTER COLUMN "date_new" TYPE timestamp USING ("date_new"::timestamp);
  
--Добавление нового столбца
ALTER TABLE transactions_info ADD COLUMN "Id_client" integer;  
UPDATE transactions_info SET "Id_client" = "ID_client";

ALTER TABLE transactions_info DROP COLUMN "ID_client"; 

--сводная таблица данных
CREATE TEMPORARY TABLE digital_all("Id_client" int8 NULL,
	"Total_amount" int8 NULL,
	"Gender" text NULL,
	"Age" float8 NULL,
	"Count_city" int8 NULL,
	"Response_communcation" int8 NULL,
	"Communication_3month" int8 NULL,
	"Tenure" int8 NULL,
	"date_new" text NULL,
	"Id_check" int8 NULL,
	"Count_products" float8 NULL,
	"Sum_payment" float8 NULL
);

--INSERT INTO digital_all
SELECT * from customer_info LEFT JOIN transactions_info USING ("Id_client");

--1. вывести список клиентов с непрерывной историей за год
SELECT * from digital_all;

--2. Средний чек за период (сумму оплаты за год делим на количество чеков за год)
SELECT "Id_client", ROUND((sum("Sum_payment")/count (DISTINCT "Id_check"))::numeric,2) as "average_year_check"
from digital_all
GROUP BY 1
ORDER BY 1;

--3. Средняя сумма покупок за месяц
SELECT "Id_client", ROUND((sum("Sum_payment")/12)::numeric,2) as "average_monthly_purchases"
from digital_all
GROUP BY 1
ORDER BY 1;

--4. количество всех операций по клиенту за период
SELECT "Id_client", count (DISTINCT "Id_check") as count_id_check FROM digital_all group by "Id_client";

--Вывести помесячную информацию:
--5. средняя сумма чека в месяц (сумму всех чеков за месяц делим на количество чеков за этот месяц)
SELECT "Id_client", to_char("date_new",'YY-Mon') as year_month, ROUND((sum("Sum_payment")/count (DISTINCT "Id_check"))::numeric,2) as average_monthly_check,
       ROUND(avg("Sum_payment")::numeric,2) as "average_monthly_product_price"
from digital_all
group by 1,2
ORDER BY 1;

--6. среднее количество операций в месяц (количество чеков за год делить на 12)
SELECT "Id_client", count (DISTINCT "Id_check")/12 as average_count_checks
from digital_all
group by 1
ORDER BY 1;

--7. среднее количество клиентов, которые совершали операции; (в месяц)


	