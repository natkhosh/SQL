--Основная часть:
--
--Задание 1. Создайте новое соединение в DBeaver и подключите облачную базу данных dvd-rental
--
--Задание 2. Сформируйте ER-диаграмму таблиц базы данных dvd-rental
--
--Задание 3. Перечислите все таблицы базы данных dvd-rental и поля, которые являются первичными ключами для этих таблиц. 
--Формат решения в виде таблицы: https://ibb.co/3rPxY4z
--
--Задание 4. Выполните SQL-запрос к базе данных dvd-rental "SELECT * FROM country;"
--Ожидаемый результат запроса: https://ibb.co/NLjWX9y
--
--Дополнительная часть:
--
--Задание 1. Выполните основную часть, развернув базу данных dvd-rental локально, используя сервер PostgreSQL Database Server и файл 
--с дампом базы .backup или .sql
--
--Задание 2. С помощью SQL-запроса выведите названия ограничений первичных ключей. 
--Для написания простого запроса можете воспользоваться information_schema.table_constraints.


SELECT * FROM country;
SELECT * FROM information_schema.table_constraints;
SELECT table_name, constraint_name, constraint_type FROM information_schema.table_constraints where constraint_type = 'PRIMARY KEY';
