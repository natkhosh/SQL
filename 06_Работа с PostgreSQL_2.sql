--=============== ЊЋ„“‹њ 6. POSTGRESQL =======================================
--= ЏЋЊЌ€’…, —’Ћ Ќ…ЋЃ•Ћ„€ЊЋ “‘’ЂЌЋ‚€’њ ‚…ђЌЋ… ‘Ћ…„€Ќ…Ќ€… € ‚›ЃђЂ’њ ‘•…Њ“ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

SELECT  film_id , title , special_features 
FROM film f 
WHERE special_features && ARRAY['Behind the Scenes']
ORDER BY film_id ;



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

SELECT film_id   , title , special_features 
FROM film 
WHERE 'Behind the Scenes' = ANY(special_features)
ORDER BY film_id ;

SELECT  film_id   , title , special_features 
FROM film f 
WHERE array_position(f.special_features, 'Behind the Scenes') IS NOT NULL
ORDER BY film_id ;



--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

WITH cte AS (
	SELECT *, title , special_features 
	FROM film f
	WHERE special_features && ARRAY['Behind the Scenes']
	ORDER BY film_id )
SELECT r.customer_id , count(i.inventory_id) AS film_count
FROM cte 
JOIN inventory i ON i.film_id = cte.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY  r.customer_id
ORDER BY r.customer_id ;



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

SELECT r.customer_id , count(i.inventory_id) AS film_count
FROM (
	SELECT *, title , special_features 
	FROM film f
	WHERE special_features && ARRAY['Behind the Scenes']
	ORDER BY film_id ) t
JOIN inventory i ON i.film_id = t.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY  r.customer_id
ORDER BY r.customer_id ;



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

CREATE MATERIALIZED VIEW task_5 AS
	SELECT r.customer_id , count(i.inventory_id) AS film_count
	FROM (
		SELECT *, title , special_features 
		FROM film f
		WHERE special_features && ARRAY['Behind the Scenes']
		ORDER BY film_id ) t
	JOIN inventory i ON i.film_id = t.film_id
	JOIN rental r ON r.inventory_id = i.inventory_id
	GROUP BY  r.customer_id
	ORDER BY r.customer_id ;

REFRESH MATERIALIZED VIEW task_5;



--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее

EXPLAIN ANALYSE
SELECT  film_id , title , special_features 
FROM film f 
WHERE special_features && ARRAY['Behind the Scenes']
ORDER BY film_id ;
--0.467

EXPLAIN ANALYSE
SELECT film_id   , title , special_features 
FROM film 
WHERE 'Behind the Scenes' = ANY(special_features)
ORDER BY film_id ;
--0.462

EXPLAIN ANALYSE
SELECT  film_id   , title , special_features 
FROM film f 
WHERE array_position (f.special_features, 'Behind the Scenes') IS NOT NULL
ORDER BY film_id ;
--0.418

-- Поиск в массиве быстрее всего происходит при помощи  функции array_position  

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

EXPLAIN ANALYSE
WITH cte AS (
	SELECT *, title , special_features 
	FROM film f
	WHERE special_features && ARRAY['Behind the Scenes']
	ORDER BY film_id )
SELECT r.customer_id , count(i.inventory_id) AS film_count
FROM cte 
JOIN inventory i ON i.film_id = cte.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY  r.customer_id
ORDER BY r.customer_id ;
--5.561

EXPLAIN ANALYSE
SELECT r.customer_id , count(i.inventory_id) AS film_count
FROM (
	SELECT *, title , special_features 
	FROM film f
	WHERE special_features && ARRAY['Behind the Scenes']
	ORDER BY film_id ) t
JOIN inventory i ON i.film_id = t.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY  r.customer_id
ORDER BY r.customer_id ;
--5.529

-- На конкретном компьютере и с данной БД оба варианта работают примерно одиноково, с незначительной разницей.


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

SELECT p.staff_id, 
	f.film_id, 
	f.title, 	
	p.amount, 
	p.payment_date, 
	c.last_name AS customer_last_name, 
	c.first_name AS customer_first_name
FROM (
	SELECT staff_id, payment_id, amount, payment_date, customer_id, rental_id,
	ROW_NUMBER() OVER  (PARTITION BY staff_id ORDER BY payment_date)
	FROM payment) p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
JOIN customer c ON c.customer_id = p.customer_id
WHERE ROW_NUMBER = 1


--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

select t1.store_id, rental_date, count, payment_date, sum
from (
	select i.store_id, rental_date::date, count(i.film_id), 
		row_number() over (partition by i.store_id order by count(i.film_id) desc)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, rental_date::date) t1
join (
	select i.store_id, payment_date::date, sum(amount), 
		row_number() over (partition by i.store_id order by sum(amount))
	from payment p
	join rental r on p.rental_id = r.rental_id
	join inventory i on i.inventory_id = r.inventory_id
	group by i.store_id, payment_date::date) t2 on t1.store_id = t2.store_id
where t1.row_number = 1 and t2.row_number = 1




