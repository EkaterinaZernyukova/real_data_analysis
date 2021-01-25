SQL 
Есть 2 таблицы с информацией о клиентах (customer_info.xlsx) и транзакциях за период с 01.06.2015 по 01.06.2016 (Transactions_info.xlsx).
Необходимо выполнить следующие задания:

1. вывести список клиентов с непрерывной историей за год, 
средний чек за период, 
средняя сумма покупок за месяц, 
количество всех операций по клиенту за период

2. Вывести помесячную информацию: 
средняя сумма чека в месяц, 
среднее количество операций в месяц, 
среднее количество клиентов, которые совершали операции; 

4. Долю от общего количества операций за год 
и долю в месяц от общей суммы операций; 

5. Вывести % соотношение M/F/NA в каждом месяце с их долей затрат

6. Вывести возрастные группы клиентов с шагом 10 лет и отдельно клиентов, 
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
  
--Добавление нового столбца
ALTER TABLE transactions_info ADD COLUMN "Id_client" integer;  
UPDATE transactions_info SET "Id_client" = "ID_client";

ALTER TABLE transactions_info DROP COLUMN "ID_client"; 
  
--1. вывести список клиентов с непрерывной историей за год, 
--средний чек за период, 
--средняя сумма покупок за месяц, 
--количество всех операций по клиенту за период


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

--количество всех операций по клиенту за период
SELECT "Id_client", count (DISTINCT "Id_check") as count_id_check FROM digital_all group by "Id_client";

--средняя сумма покупок за месяц

ALTER TABLE digital_all ALTER COLUMN "date_new" TYPE timestamp USING ("date_new"::timestamp)

SELECT "date_new", avg("Sum_payment") as monthly_sum
     FROM digital_all
 GROUP BY "date_new"('month');


select "date_new"('DD-MM-YYYY') as year_month from digital_all;


 
	