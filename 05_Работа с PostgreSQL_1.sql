--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--	������������ ��� ������� �� 1 �� N �� ����
--	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
--	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
--	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
-- ����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

-- 1.	������������ ��� ������� �� 1 �� N �� ����
--SELECT customer_id, payment_id, payment_date, amount,
--	ROW_NUMBER() OVER (ORDER BY payment_date) AS aa
--FROM payment p
--order BY  customer_id 
--
-- 2.	������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
--SELECT customer_id , payment_id, payment_date, amount, date_trunc('day', payment_date),
--	ROW_NUMBER() OVER (PARTITION BY customer_id  ORDER BY date(payment_date))
--FROM payment p
--
-- 3.	���������� ����������� ������ ����� ���� �������� ��� ������� ����������, 
--���������� ������ ���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������
--SELECT customer_id , payment_id, payment_date, amount,  payment_date,
--	SUM(amount) OVER (PARTITION BY customer_id rows between unbounded preceding and current row) AS s_a
--FROM payment p
--ORDER BY  s_a 
--
-- 4.	������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� ���, 
--����� ������� � ���������� ��������� ����� ���������� �������� ������.
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


--������� �2
-- � ������� ������� ������� �������� ��� ������� ���������� ��������� ������� 
-- � ��������� ������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.
 
SELECT customer_id , payment_id , payment_date, amount,
	LAG (amount, 1, 0.) over (partition by customer_id order by payment_date) AS last_amount 
FROM payment p 


--������� �3
-- � ������� ������� ������� ����������, �� ������� ������ 
-- ��������� ������ ���������� ������ ��� ������ ��������.

SELECT customer_id , payment_id , payment_date, amount,
	amount - LEAD (amount, 1, 0.) over (partition by customer_id order by payment_date) AS difference
FROM payment p 


--������� �4
-- � ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

SELECT DISTINCT (LAST_VALUE (amount)  OVER (PARTITION BY customer_id ORDER BY customer_id) ),
	customer_id 
FROM payment p
ORDER BY customer_id



--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ���� 2007 ����
-- � ����������� ������ �� ������� ���������� � 
-- �� ������ ���� ������� (��� ����� �������) � ����������� �� ����.




--������� �2
--10 ������ 2007 ���� � ��������� ��������� �����: ����������, ����������� ������ 100�� ������
-- ������� �������������� ������ �� ��������� ������.
-- � ������� ������� ������� �������� ���� �����������, ������� � ���� ���������� ����� �������� ������.




--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:
-- 1. ����������, ������������ ���������� ���������� �������
-- 2. ����������, ������������ ������� �� ����� ������� �����
-- 3. ����������, ������� ��������� ��������� �����






