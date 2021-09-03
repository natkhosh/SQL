--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

SELECT concat(c.first_name, ' ', c.last_name) AS "������� � ���"
		, address AS "�����"
		, city AS "�����"
		, country AS "������"
FROM customer c 
JOIN address a USING(address_id) 
JOIN city  USING(city_id)
JOIN country USING(country_id);



--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

SELECT c.store_id AS "ID ��������",
		count(c.store_id) AS "���������� �����������"
FROM store s 
JOIN customer c USING (store_id)
GROUP BY c.store_id; 


--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

SELECT c.store_id AS "ID ��������",
		count(c.store_id) AS "���������� �����������"
FROM store s 
JOIN customer c USING (store_id)
GROUP BY c.store_id 
HAVING count(c.customer_id) > 300;


-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

SELECT s.store_id AS "ID ��������",
		count(c.store_id) AS "���������� �����������",
		city.city AS "����� ��������",
		concat(s2.last_name, ' ', s2.first_name) AS "������� � ��� ��������"
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


--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������

SELECT concat(c.last_name, ' ', c.first_name) AS "������� � ��� ����������", 
		count(r.customer_id) AS "���������� �������"
FROM rental r 
JOIN customer c ON c.customer_id = r.customer_id 
GROUP BY r.customer_id, 
		c.last_name, 
		c.first_name 
order by 2 DESC 
LIMIT 5;


--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������

SELECT concat(c.last_name, ' ', c.first_name) AS "������� � ��� ����������", 
		count(r.customer_id) AS "���������� �������",
		round(sum(p.amount)) AS "����� ��������� ��������",
		min(p.amount) AS "����������� ��������� �������",
		max(p.amount) AS "������������ ��������� �������"
FROM rental r 
JOIN payment p ON p.rental_id = r.rental_id
JOIN customer c ON c.customer_id = r.customer_id 
GROUP BY r.customer_id, c.last_name, 
		c.first_name; 


--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.
 
select t1.name_one, t2.name_two
from city c 
cross join table_two t2

SELECT t1.city, t2.city 
FROM city t1 
CROSS JOIN city t2 
WHERE t1.city < t2.city;



--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.

SELECT customer_id "ID ����������", 
	round(avg((EXTRACT(epoch FROM return_date)/ 86400.00 - EXTRACT(epoch FROM rental_date)/ 86400.00))::numeric, 2) 
	AS "������� ���������� ���� �� �������"
FROM rental r
GROUP BY customer_id 
ORDER BY 1;



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.

SELECT f.title AS "��������",
	f.rating AS "�������",
	c."name" AS "����",
	f.release_year AS "��� �������",
	l."name"  AS "����",
	count(r.rental_id) AS "���������� �����", 
	sum(p.amount) AS "����� ��������� ������"
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



--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

SELECT f.title AS "��������",
	f.rating AS "�������",
	c."name" AS "����",
	f.release_year AS "��� �������",
	l."name"  AS "����",
	count(r.rental_id) AS "���������� �����", 
	sum(p.amount) AS "����� ��������� ������"
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



--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".


SELECT p.staff_id, count(p.rental_id),
	CASE 
		WHEN count(p.rental_id) > 7300 THEN '��'
		ELSE '���'
	END 
FROM payment p 
GROUP BY p.staff_id 




