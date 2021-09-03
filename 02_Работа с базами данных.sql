
--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия регионов из таблицы адресов

--select * from address a;

select distinct district from address
where district is not null ;


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те регионы, 
--названия которых начинаются на "K" и заканчиваются на "a", и названия не содержат пробелов


select distinct district from address
where district like 'K%a'and district not like '% %';


--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 марта 2007 года по 19 марта 2007 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

select amount, payment_date 
from payment
where amount > 1 and payment_date::date between '17-03-2007' and '19-03-2007'
order by payment_date;



--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

select * 
from payment
order by payment_date desc
limit 10;



--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.


select last_name || ' ' || first_name as "ФИО", 
	email as "Эл.почта", 
	character_length(email) as "Кол-во символов",
	last_update::date as "Дата" 
from  customer;


--ЗАДАНИЕ №6
--Выведите одним запросом активных покупателей, имена которых Kelly или Willie.
--Все буквы в фамилии и имени из нижнего регистра должны быть переведены в высокий регистр.


select upper(first_name) as first_name, upper(last_name) as last_name, activebool 
from customer
where first_name = 'Kelly' or first_name = 'Willie';



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.

select *
from film
where (rating = 'R' and rental_rate <= 3) or
		(rating = 'PG-13' and rental_rate >= 4);




--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select film_id , title,  description , character_length(description) as dl
from film  
order by character_length(description) desc 
limit 3;



--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.


select split_part(email::text, '@', 1) as user_name,
	split_part(email::text, '@', 2) as domen_name
from customer customer; 



--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.


select initcap(split_part(email::text, '@', 1)) as user_name ,
	initcap(split_part(email::text, '@', 2)) as domen_name 
from customer customer; 

select customer_id, email,
concat(upper(left(split_part(email, '@', 1), 1)), substring(split_part(email, '@', 1), 2)),
concat(upper(left(split_part(email, '@', 2), 1)), substring(split_part(email, '@', 2), 2))
from customer
