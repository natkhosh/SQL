--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--	Пронумеруйте все платежи от 1 до N по дате
--	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
-- Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

-- 1.	Пронумеруйте все платежи от 1 до N по дате
--SELECT customer_id, payment_id, payment_date, amount,
--	ROW_NUMBER() OVER (ORDER BY payment_date) AS aa
--FROM payment p
--order BY  customer_id 
--
-- 2.	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--SELECT customer_id , payment_id, payment_date, amount, date_trunc('day', payment_date),
--	ROW_NUMBER() OVER (PARTITION BY customer_id  ORDER BY date(payment_date))
--FROM payment p
--
-- 3.	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, 
--сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--SELECT customer_id , payment_id, payment_date, amount,  payment_date,
--	SUM(amount) OVER (PARTITION BY customer_id rows between unbounded preceding and current row) AS s_a
--FROM payment p
--ORDER BY  s_a 
--
-- 4.	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, 
--чтобы платежи с одинаковым значением имели одинаковое значение номера.
--SELECT customer_id , payment_id, payment_date, payment_date, amount,  
--	DENSE_RANK () OVER (PARTITION BY customer_id  ORDER BY amount DESC)
--FROM payment p
 


SELECT customer_id, payment_id, payment_date, amount,
	ROW_NUMBER() OVER (ORDER BY payment_date) AS column_1,
	ROW_NUMBER() OVER (PARTITION BY customer_id  ORDER BY date(payment_date)) AS column_2,
	SUM(amount) OVER (PARTITION BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS s_a,
	DENSE_RANK () OVER (PARTITION BY customer_id  ORDER BY amount DESC ) AS column_4
FROM payment p
ORDER BY  customer_id , column_4 


--ЗАДАНИЕ №2
-- С помощью оконной функции выведите для каждого покупателя стоимость платежа 
-- и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
 
SELECT customer_id , payment_id , payment_date, amount,
	LAG (amount, 1, 0.) over (partition by customer_id order by payment_date) AS last_amount 
FROM payment p 


--ЗАДАНИЕ №3
-- С помощью оконной функции определите, на сколько каждый 
-- следующий платеж покупателя больше или меньше текущего.

SELECT customer_id , payment_id , payment_date, amount,
	amount - LEAD (amount, 1, 0.) over (partition by customer_id order by payment_date) AS difference
FROM payment p 


--ЗАДАНИЕ №4
-- С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

SELECT DISTINCT (LAST_VALUE (amount)  OVER (PARTITION BY customer_id ORDER BY customer_id) ),
	customer_id 
FROM payment p
ORDER BY customer_id



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за март 2007 года
-- с нарастающим итогом по каждому сотруднику и 
-- по каждой дате продажи (без учёта времени) с сортировкой по дате.




--ЗАДАНИЕ №2
--10 апреля 2007 года в магазинах проходила акция: покупатель, совершивший каждый 100ый платеж
-- получал дополнительную скидку на следующую аренду.
-- С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм






