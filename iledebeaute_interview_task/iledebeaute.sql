

ALTER TABLE orders RENAME TO A1;

ALTER TABLE A1 RENAME COLUMN TEXT TO VERSIONS;
ALTER TABLE A1 RENAME COLUMN STATUS TO TEXT;

ALTER TABLE a1 ALTER COLUMN text TYPE varchar(255);

ALTER TABLE departments RENAME TO A2;
ALTER TABLE A2 RENAME COLUMN depname TO text;
ALTER TABLE a2 ALTER COLUMN text TYPE varchar(255);
INSERT INTO a VALUES (1, '01.07.2018'), (234, '04.10.2018'), (234, '02.07.2018'), (3, '02.07.2018'), (1, '01.07.2018');
UPDATE A1 SET TEXT = 'ANY' WHERE ID = 9;

--DELETE FROM A1 WHERE TEXT = 'ANY';

--1.Составить запрос, выдающий все строки таблицы A1, id которых есть в таблице A2
SELECT * FROM a1 WHERE id IN (SELECT id FROM a2);

--2.Составить запрос, выдающий все строки таблицы A1, id которых нет в таблице A2
SELECT * FROM a1 WHERE id NOT IN (SELECT id FROM a2);

--3. Составить запрос, выдающий A1.ID, A1.TEXT, A2.TEXT для A1.ID = A2.ID. 
--Если в таблице A2 нет соответствующего ID вместо A2.TEXT вывести слово “НЕТ ”

SELECT
	A1.id AS a1_id,
	A1.TEXT AS a1_text,
	CASE
		WHEN A2.TEXT IS NULL THEN 'НЕТ'
		ELSE A2.text
	END
FROM
	a1
LEFT JOIN a2 ON
	A1.id = A2.id;


--4. Изменить значение TEXT в таблице A1 на значение TEXT из таблицы A2 для A1.ID =  A2.ID

UPDATE
	A1
SET
	text = A2.text
FROM
	A2
WHERE
	A1.id = A2.id;




5.

6. 
INSERT INTO a1 (TEXT) SELECT TEXT FROM a2 WHERE a1.id=a2.id;

--7.Удалить из таблицы A1 те строки, ID которых есть в A2
DELETE FROM A1 WHERE a1.id=a2.id;
