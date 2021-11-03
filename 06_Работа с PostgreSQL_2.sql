--=============== ������ 6. POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� SQL-������, ������� ������� ��� ���������� � ������� 
--�� ����������� ��������� "Behind the Scenes".

SELECT  film_id , title , special_features 
FROM film f 
WHERE special_features && ARRAY['Behind the Scenes']
ORDER BY film_id ;



--������� �2
--�������� ��� 2 �������� ������ ������� � ��������� "Behind the Scenes",
--��������� ������ ������� ��� ��������� ����� SQL ��� ������ �������� � �������.

SELECT film_id   , title , special_features 
FROM film 
WHERE 'Behind the Scenes' = ANY(special_features)
ORDER BY film_id ;

SELECT  film_id   , title , special_features 
FROM film f 
WHERE array_position(f.special_features, 'Behind the Scenes') IS NOT NULL
ORDER BY film_id ;



--������� �3
--��� ������� ���������� ���������� ������� �� ���� � ������ ������� 
--�� ����������� ��������� "Behind the Scenes.

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1, 
--���������� � CTE. CTE ���������� ������������ ��� ������� �������.

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



--������� �4
--��� ������� ���������� ���������� ������� �� ���� � ������ �������
-- �� ����������� ��������� "Behind the Scenes".

--������������ ������� ��� ���������� �������: ����������� ������ �� ������� 1,
--���������� � ���������, ������� ���������� ������������ ��� ������� �������.

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



--������� �5
--�������� ����������������� ������������� � �������� �� ����������� �������
--� �������� ������ ��� ���������� ������������������ �������������

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



--������� �6
--� ������� explain analyze ��������� ������ �������� ���������� ��������
-- �� ���������� ������� � �������� �� �������:

--1. ����� ���������� ��� �������� ����� SQL, ������������ ��� ���������� ��������� �������, 
--   ����� �������� � ������� ���������� �������

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

-- ����� � ������� ������� ����� ���������� ��� ������  ������� array_position  

--2. ����� ������� ���������� �������� �������: 
--   � �������������� CTE ��� � �������������� ����������

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

-- �� ���������� ���������� � � ������ �� ��� �������� �������� �������� ���������, � �������������� ��������.


--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� � ����� ������ �� ����� ���������

--������� �2
--��������� ������� ������� �������� ��� ������� ����������
--�������� � ����� ������ ������� ����� ����������.

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


--������� �3
--��� ������� �������� ���������� � �������� ����� SQL-�������� ��������� ������������� ����������:
-- 1. ����, � ������� ���������� ������ ����� ������� (���� � ������� ���-�����-����)
-- 2. ���������� ������� ������ � ������ � ���� ����
-- 3. ����, � ������� ������� ������� �� ���������� ����� (���� � ������� ���-�����-����)
-- 4. ����� ������� � ���� ����

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




