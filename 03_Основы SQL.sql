--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

SELECT concat(c.first_name, ' ', c.last_name) AS "Фамилия и имя"
		, address AS "Адрес"
		, city AS "Город"
		, country AS "Страна"
FROM customer c 
JOIN address a USING(address_id) 
JOIN city  USING(city_id)
JOIN country USING(country_id);



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

SELECT c.store_id AS "ID магазина",
		count(c.store_id) AS "Количество покупателей"
FROM store s 
JOIN customer c USING (store_id)
GROUP BY c.store_id; 


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

SELECT c.store_id AS "ID магазина",
		count(c.store_id) AS "Количество покупателей"
FROM store s 
JOIN customer c USING (store_id)
GROUP BY c.store_id 
HAVING count(c.customer_id) > 300;


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

SELECT s.store_id AS "ID магазина",
		count(c.store_id) AS "Количество покупателей",
		city.city AS "Город магазина",
		concat(s2.last_name, ' ', s2.first_name) AS "Фамилия и имя продавца"
FROM store s
JOIN address a ON s.address_id = a.address_id 
JOIN city ON a.city_id = city.city_id
JOIN staff s2 ON s2.store_id = s.store_id 
JOIN customer c ON c.store_id = s.store_id 
GROUP BY c.store_id, 
		s.store_id, 
		s2.last_name, 
		s2.first_name, 
		city.city 
HAVING count(c.customer_id) > 300;


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

SELECT concat(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя", 
		count(r.customer_id) AS "Количество фильмов"
FROM rental r 
JOIN customer c ON c.customer_id = r.customer_id 
GROUP BY r.customer_id, 
		c.last_name, 
		c.first_name 
order by 2 DESC 
LIMIT 5;


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

SELECT concat(c.last_name, ' ', c.first_name) AS "Фамилия и имя покупателя", 
		count(r.customer_id) AS "Количество фильмов",
		round(sum(p.amount)) AS "Общая стоимость платежей",
		min(p.amount) AS "Минимальная стоимость платежа",
		max(p.amount) AS "Максимальная стоимость платежа"
FROM rental r 
JOIN payment p ON p.rental_id = r.rental_id
JOIN customer c ON c.customer_id = r.customer_id 
GROUP BY r.customer_id, c.last_name, 
		c.first_name; 


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 
select t1.name_one, t2.name_two
from city c 
cross join table_two t2

SELECT t1.city, t2.city 
FROM city t1 
CROSS JOIN city t2 
WHERE t1.city < t2.city;



--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.

SELECT customer_id "ID покупателя", 
	round(avg((EXTRACT(epoch FROM return_date)/ 86400.00 - EXTRACT(epoch FROM rental_date)/ 86400.00))::numeric, 2) 
	AS "Среднее количество дней на возврат"
FROM rental r
GROUP BY customer_id 
ORDER BY 1;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

SELECT f.title AS "Название",
	f.rating AS "Рейтинг",
	c."name" AS "Жанр",
	f.release_year AS "Год выпуска",
	l."name"  AS "Язык",
	count(r.rental_id) AS "Количество аренд", 
	sum(p.amount) AS "Общая стоимость аренды"
FROM rental r
JOIN payment p ON p.rental_id = r.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f ON f.film_id = i.film_id
JOIN film_category fc ON fc.film_id = f.film_id 
JOIN category c ON c.category_id  = fc.category_id 
JOIN "language" l ON l.language_id = f.language_id 
GROUP BY f.film_id,
	c."name",
	l."name";



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

SELECT f.title AS "Название",
	f.rating AS "Рейтинг",
	c."name" AS "Жанр",
	f.release_year AS "Год выпуска",
	l."name"  AS "Язык",
	count(r.rental_id) AS "Количество аренд", 
	sum(p.amount) AS "Общая стоимость аренды"
FROM film f
LEFT JOIN inventory i ON i.film_id = f.film_id
LEFT JOIN rental r ON r.inventory_id = i.inventory_id
LEFT JOIN payment p ON p.rental_id = r.rental_id
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c ON c.category_id  = fc.category_id 
LEFT JOIN "language" l ON l.language_id = f.language_id 
GROUP BY f.film_id,
	c."name",
	l."name"
HAVING count(r.rental_id) = 0;



--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".


SELECT p.staff_id, count(p.rental_id),
	CASE 
		WHEN count(p.rental_id) > 7300 THEN 'Да'
		ELSE 'Нет'
	END 
FROM payment p 
GROUP BY p.staff_id 




