--=============== ЊЋ„“‹њ 4. “ѓ‹“Ѓ‹…Ќ€… ‚ SQL =======================================
--= ЏЋЊЌ€’…, —’Ћ Ќ…ЋЃ•Ћ„€ЊЋ “‘’ЂЌЋ‚€’њ ‚…ђЌЋ… ‘Ћ…„€Ќ…Ќ€… € ‚›ЃђЂ’њ ‘•…Њ“ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.

CREATE SCHEMA lecture_4_nkhoshina

-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ

CREATE TABLE languages(
	language_id serial PRIMARY KEY,
	language_name varchar(100) NOT NULL UNIQUE
);
 

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ

INSERT INTO languages (language_id, language_name)
VALUES (1, 'Русский'), (2, 'Французский'), (3, 'Японский');

--SELECT * FROM languages l; 

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

CREATE TABLE nationality(
	nationality_id serial PRIMARY KEY,
	nationality_name varchar(100) NOT NULL UNIQUE,
	language_id int2 NOT NULL REFERENCES languages (language_id)
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ

INSERT INTO nationality (nationality_name, language_id)
VALUES ('русские', 1), ('белоруссы', 1), ('чуваши', 1);

INSERT INTO nationality (nationality_name, language_id)
VALUES ('французы', 2), ('канадцы', 2), ('бельгийцы', 2);

INSERT INTO nationality (nationality_name, language_id)
VALUES ('японцы', 3);

--SELECT * FROM nationality n ;

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ

CREATE TABLE country(
	country_id serial PRIMARY KEY,
	country_name varchar(100) NOT NULL UNIQUE,
	nationality_id int2 NOT NULL REFERENCES nationality (nationality_id)
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ

INSERT INTO country (country_name, nationality_id)
VALUES ('Россия', 1), ('Украина', 1), ('Франция', 2), ('Алжир', 2), ('Швейцария', 2);

INSERT INTO country (country_name, nationality_id)
VALUES ('Япония', 3);

--SELECT * FROM country c ;

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

CREATE TABLE language_nationality (
	language_id int2 NOT NULL,
	nationality_id int2 NOT NULL,
	PRIMARY KEY (language_id, nationality_id),
	FOREIGN KEY (language_id) REFERENCES languages (language_id),
	FOREIGN KEY (nationality_id) REFERENCES nationality (nationality_id)
);


SELECT * FROM language_nationality;

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

INSERT INTO language_nationality (language_id, nationality_id)
VALUES (1, 1), (1, 2), (1, 3);

INSERT INTO language_nationality (language_id, nationality_id)
VALUES (2, 4), (2, 5), (2, 6);

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

CREATE TABLE nationality_country (
	nationality_id int2 NOT NULL,
	country_id int2 NOT NULL,
	PRIMARY KEY (nationality_id, country_id),
	FOREIGN KEY (country_id) REFERENCES country(country_id),
	FOREIGN KEY (nationality_id) REFERENCES nationality(nationality_id)
);

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

INSERT INTO nationality_country (nationality_id, country_id)
VALUES (1, 1), (4, 3), (7, 3);

--SELECT * FROM nationality_country nc ;

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

CREATE TABLE  film_new (
	film_id serial PRIMARY KEY,
	film_name varchar(255) NOT NULL,
	film_year integer CHECK (film_year > 0),
	film_rental_rate NUMERIC (4,2) DEFAULT  0.99,
	film_duration integer NOT NULL CHECK (film_duration > 0)
);


--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]

INSERT INTO film_new (film_name, film_year, film_rental_rate, film_duration)
SELECT UNNEST (ARRAY ['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
	UNNEST (ARRAY [1994, 1999, 1985, 1994, 1993]),
	UNNEST (ARRAY [2.99, 0.99, 1.99, 2.99, 3.99]),
	UNNEST (ARRAY [142, 189, 116, 142, 195]);

--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41

UPDATE film_new
SET film_rental_rate = film_rental_rate + 1.41

SELECT * FROM film_new fn ;

--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

DELETE FROM film_new 
WHERE film_id = 3;

SELECT * FROM film_new fn ;

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме

INSERT INTO film_new (film_name, film_year, film_duration)
VALUES ('Inception', 2010, 148);


--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых

SELECT *, round(film_duration / 60., 2) AS duration_in_hours
FROM film_new


--ЗАДАНИЕ №7 
--Удалите таблицу film_new

DROP TABLE film_new ;