--Задание выполнено для СУБД PostgreSQL 12.4    


--2) В следующих заданиях не требуется (но приветствуется) абсолютно точный результат. Достаточно описать основные подходы к решению.
--Решение необходимо сделать одним запросом без применения процедур.

--    a) Написать запрос выдающий набор цифр от 1 до <больше миллиона> (конечное значение роли не играет, оно должно быть достаточно большим)
--1й вариант решения   
 CREATE TABLE million AS
SELECT
	generate_series(1, 10000001) AS id;
--SELECT * from million where id > 5000000 LIMIT 10;


--2й вариант решения (max = 2^63-1 )
 CREATE SEQUENCE line_number START 1; 


--b) В магазине проходит акция «Каждый третий товар отдается бесплатно». 
--Необходимо выстроить товары в чеке в порядке убывания цены и обнулить цену каждой третьей позиции. 


UPDATE
	bill
SET
	price = 0
WHERE 
	id IN 
	(SELECT
	id
FROM
	(
	SELECT
		price, id, ROW_NUMBER() OVER(
		ORDER BY price DESC) AS count_in_bill
	FROM
		bill) filter_bill
WHERE
	count_in_bill % 3 = 0);





