--�������� �����:
--
--������� 1. �������� ����� ���������� � DBeaver � ���������� �������� ���� ������ dvd-rental
--
--������� 2. ����������� ER-��������� ������ ���� ������ dvd-rental
--
--������� 3. ����������� ��� ������� ���� ������ dvd-rental � ����, ������� �������� ���������� ������� ��� ���� ������. 
--������ ������� � ���� �������: https://ibb.co/3rPxY4z
--
--������� 4. ��������� SQL-������ � ���� ������ dvd-rental "SELECT * FROM country;"
--��������� ��������� �������: https://ibb.co/NLjWX9y
--
--�������������� �����:
--
--������� 1. ��������� �������� �����, ��������� ���� ������ dvd-rental ��������, ��������� ������ PostgreSQL Database Server � ���� 
--� ������ ���� .backup ��� .sql
--
--������� 2. � ������� SQL-������� �������� �������� ����������� ��������� ������. 
--��� ��������� �������� ������� ������ ��������������� information_schema.table_constraints.


SELECT * FROM country;
SELECT * FROM information_schema.table_constraints;
SELECT table_name, constraint_name, constraint_type FROM information_schema.table_constraints where constraint_type = 'PRIMARY KEY';
