--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� �������� ����� ������� � �������:
--�������_�������, 
--���� ����������� � ���������� ��� ���������� �������, �� �������� ����� ����� � � ��� �������� �������.

CREATE SCHEMA lecture_4_nkhoshina

-- ������������� ���� ������ ��� ��������� ���������:
-- 1. ���� (� ������ ����������, ����������� � ��)
-- 2. ���������� (� ������ �������, ���������� � ��)
-- 3. ������ (� ������ ������, �������� � ��)


--������� ���������:
-- �� ����� ����� ����� �������� ��������� �����������
-- ���� ���������� ����� ������� � ��������� �����
-- ������ ������ ����� �������� �� ���������� �����������

 
--���������� � ��������-������������:
-- ������������� �������� ������ ������������� ���������������
-- ������������ ��������� �� ������ ��������� null �������� � �� ������ ����������� ��������� � ��������� ���������
 
--�������� ������� �����

CREATE TABLE languages(
	language_id serial PRIMARY KEY,
	language_name varchar(100) NOT NULL UNIQUE
);
 

--�������� ������ � ������� �����

INSERT INTO languages (language_id, language_name)
VALUES (1, '�������'), (2, '�����������'), (3, '��������');

--SELECT * FROM languages l; 

--�������� ������� ����������

CREATE TABLE nationality(
	nationality_id serial PRIMARY KEY,
	nationality_name varchar(100) NOT NULL UNIQUE,
	language_id int2 NOT NULL REFERENCES languages (language_id)
);

--�������� ������ � ������� ����������

INSERT INTO nationality (nationality_name, language_id)
VALUES ('�������', 1), ('���������', 1), ('������', 1);

INSERT INTO nationality (nationality_name, language_id)
VALUES ('��������', 2), ('�������', 2), ('���������', 2);

INSERT INTO nationality (nationality_name, language_id)
VALUES ('������', 3);

--SELECT * FROM nationality n ;

--�������� ������� ������

CREATE TABLE country(
	country_id serial PRIMARY KEY,
	country_name varchar(100) NOT NULL UNIQUE,
	nationality_id int2 NOT NULL REFERENCES nationality (nationality_id)
);


--�������� ������ � ������� ������

INSERT INTO country (country_name, nationality_id)
VALUES ('������', 1), ('�������', 1), ('�������', 2), ('�����', 2), ('���������', 2);

INSERT INTO country (country_name, nationality_id)
VALUES ('������', 3);

--SELECT * FROM country c ;

--�������� ������ ������� �� �������

CREATE TABLE language_nationality (
	language_id int2 NOT NULL,
	nationality_id int2 NOT NULL,
	PRIMARY KEY (language_id, nationality_id),
	FOREIGN KEY (language_id) REFERENCES languages (language_id),
	FOREIGN KEY (nationality_id) REFERENCES nationality (nationality_id)
);


SELECT * FROM language_nationality;

--�������� ������ � ������� �� �������

INSERT INTO language_nationality (language_id, nationality_id)
VALUES (1, 1), (1, 2), (1, 3);

INSERT INTO language_nationality (language_id, nationality_id)
VALUES (2, 4), (2, 5), (2, 6);

--�������� ������ ������� �� �������

CREATE TABLE nationality_country (
	nationality_id int2 NOT NULL,
	country_id int2 NOT NULL,
	PRIMARY KEY (nationality_id, country_id),
	FOREIGN KEY (country_id) REFERENCES country(country_id),
	FOREIGN KEY (nationality_id) REFERENCES nationality(nationality_id)
);

--�������� ������ � ������� �� �������

INSERT INTO nationality_country (nationality_id, country_id)
VALUES (1, 1), (4, 3), (7, 3);

--SELECT * FROM nationality_country nc ;

--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

CREATE TABLE  film_new (
	film_id serial PRIMARY KEY,
	film_name varchar(255) NOT NULL,
	film_year integer CHECK (film_year > 0),
	film_rental_rate NUMERIC (4,2) DEFAULT  0.99,
	film_duration integer NOT NULL CHECK (film_duration > 0)
);


--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]

INSERT INTO film_new (film_name, film_year, film_rental_rate, film_duration)
SELECT UNNEST (ARRAY ['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler�s List']),
	UNNEST (ARRAY [1994, 1999, 1985, 1994, 1993]),
	UNNEST (ARRAY [2.99, 0.99, 1.99, 2.99, 3.99]),
	UNNEST (ARRAY [142, 189, 116, 142, 195]);

--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41

UPDATE film_new
SET film_rental_rate = film_rental_rate + 1.41

SELECT * FROM film_new fn ;

--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new

DELETE FROM film_new 
WHERE film_id = 3;

SELECT * FROM film_new fn ;

--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������

INSERT INTO film_new (film_name, film_year, film_duration)
VALUES ('Inception', 2010, 148);


--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������

SELECT *, round(film_duration / 60., 2) AS duration_in_hours
FROM film_new


--������� �7 
--������� ������� film_new

DROP TABLE film_new ;