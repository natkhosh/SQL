
--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� �������� �� ������� �������

--select * from address a;

select distinct district from address
where district is not null ;


--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� �������, 
--�������� ������� ���������� �� "K" � ������������� �� "a", � �������� �� �������� ��������


select distinct district from address
where district like 'K%a'and district not like '% %';


--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ����� 2007 ���� �� 19 ����� 2007 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.

select amount, payment_date 
from payment
where amount > 1 and payment_date::date between '17-03-2007' and '19-03-2007'
order by payment_date;



--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select * 
from payment
order by payment_date desc
limit 10;



--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.


select last_name || ' ' || first_name as "���", 
	email as "��.�����", 
	character_length(email) as "���-�� ��������",
	last_update::date as "����" 
from  customer;


--������� �6
--�������� ����� �������� �������� �����������, ����� ������� Kelly ��� Willie.
--��� ����� � ������� � ����� �� ������� �������� ������ ���� ���������� � ������� �������.


select upper(first_name) as first_name, upper(last_name) as last_name, activebool 
from customer
where first_name = 'Kelly' or first_name = 'Willie';



--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

select *
from film
where (rating = 'R' and rental_rate <= 3) or
		(rating = 'PG-13' and rental_rate >= 4);




--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select film_id , title,  description , character_length(description) as dl
from film  
order by character_length(description) desc 
limit 3;



--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.


select split_part(email::text, '@', 1) as user_name,
	split_part(email::text, '@', 2) as domen_name
from customer customer; 



--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.


select initcap(split_part(email::text, '@', 1)) as user_name ,
	initcap(split_part(email::text, '@', 2)) as domen_name 
from customer customer; 

select customer_id, email,
concat(upper(left(split_part(email, '@', 1), 1)), substring(split_part(email, '@', 1), 2)),
concat(upper(left(split_part(email, '@', 2), 1)), substring(split_part(email, '@', 2), 2))
from customer
