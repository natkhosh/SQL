-- select bookings.now() as now;

-----------------------------------------------------------------------
-- 1. � ����� ������� ������ ������ ���������?

-- �������: 
-- ���������� ������� airports �� ������� city. 
-- ��������� �� ������� (having), ��� ���������� ��������������� ������� ������ ���� ������ 1.

SELECT a.city,
	COUNT(*) AS airport_count
FROM airports a
GROUP BY a.city
HAVING COUNT(*) > 1
ORDER BY a.city ;

-----------------------------------------------------------------------
-- 2. � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?

-- �������: ����������� �������: aircrafts, flights, airports. 
-- � ������� ���������� ������� �������, � �������� ��������� �������� �����������. ��� ����� ��������� ��������� ������ "range" 
-- �� �������� � ������� ������ ������ �������.
-- ����� ������������ ������� flights � airports, ����� �������� �������� ���������.
-- * ��� ����������� ������ (flights � airports), ��� ������� � �������� ��������, � �������� �����������. ��������� �������� ��� � ����������.

SELECT a2.airport_name
FROM 
	(SELECT a.aircraft_code, a.model, a."range"
	FROM aircrafts a 
	ORDER BY a."range" DESC 
	LIMIT 1
	) AS ac
JOIN flights f USING (aircraft_code)
JOIN airports a2 ON f.arrival_airport = a2.airport_code OR f.arrival_airport = a2.airport_code
GROUP BY a2.airport_name ;

-----------------------------------------------------------------------
-- 3. ������� 10 ������ � ������������ �������� �������� ������

-- �������:
-- �������� ������ ��� ������� ����� ����������� �������� ������ � �������� ������ �� ���������� 
-- �������� ������ ����� ���������� ������ ��� ������, 
-- � ������� ���� ������ ������������ ������� ������ ('actual_departure' is NOT NULL)
-- ��������� �� �������� ����� �������� ������ � ������� ������ 10 ��������

SELECT flight_no,  (f.actual_departure - f.scheduled_departure) AS departure_delay_time
FROM flights f 
WHERE f.actual_departure is NOT NULL 
ORDER BY departure_delay_time DESC 
LIMIT 10 ;

-----------------------------------------------------------------------
-- 4. ���� �� �����, �� ������� �� ���� �������� ���������� ������?

-- �������:
-- ��������� ����� ������� � ����������� �������� ����� ������ ticket_no.
-- ��������� �� �������, ��� ���������� ������ �� ���� �������� 'boarding_no' IS NULL. 
-- �.�. ��� ����������� ������ boarding_no � ������ �� ��� ������ �� ���� �������� ���������� ������, ���������� NULL
-- �� ������� ������� boarding_passes, boarding_no �� ����� ���� NULL, ��� ����� �� ������ ���������� ���������� �����,
-- �� ������� �� ���� �������� ���������� ������. 

SELECT count(book_ref) 
FROM  bookings
FULL OUTER JOIN tickets USING (book_ref)
FULL OUTER JOIN boarding_passes USING (ticket_no)
WHERE boarding_passes.boarding_no IS NULL ;


-----------------------------------------------------------------------
-- 5. ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
-- �������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
-- �.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.

-- �������: ����������� �������: boarding_passes, flights, seats
-- ����� ����� ��������� ����� ��� ������� �����, ����� ���������� ���������� ���������� ���� � �������� � ���������� �������� ���������� �������.
-- ������� ������ CTE � ������� ������� ���������� ���������� ���� ��� ������ ������ ��������
-- �� ������ CTE: ��������� cte_1 ������� �� ������ flights � boarding_passes, ��� ���������� ������� ���������� �������
-- ������� ���������� ��������� ����: ����� ���-�� ���� � �������� - ���-�� ���� � ��������� ����������� ��������.
-- ������� ��������� ����: round((cte_1.total_seats - count(bp.seat_no))::NUMERIC / cte_1.total_seats * 100).
-- ������� ������� ������� ��� �������� ���������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
-- ��� ��������� ���������� ������� ���� �� �����. ����������� ������������ �� departure_airport � actual_departure, 
-- ��� ���� ���� �������� � ���� date, �������� ������ ���� ��� �������� ������� ��� ����������� �������� �� ����.
-- ���������� � ���� ������������ �� actual_departure (���� � ��������� �������).

WITH cte_1 AS 
	(
	SELECT s.aircraft_code , count(s.seat_no) AS total_seats
	FROM seats s 
	GROUP BY s.aircraft_code 
	),
cte_2 AS 
	(SELECT f.flight_id , 
			f.departure_airport , 
			f.actual_departure ,
			cte_1.total_seats,
			count(bp.seat_no) AS occupied_seats, 
			cte_1.total_seats - count(bp.seat_no) AS vacant_seats , 
			round((cte_1.total_seats - count(bp.seat_no))::NUMERIC / cte_1.total_seats * 100) || ' %' AS vacant_seats_per
	FROM cte_1
	JOIN flights f ON cte_1.aircraft_code = f.aircraft_code 
	JOIN boarding_passes bp ON f.flight_id = bp.flight_id 
	GROUP BY f.flight_id , cte_1.aircraft_code, cte_1.total_seats
	)
SELECT *, 
	sum(cte_2.occupied_seats) OVER (PARTITION BY cte_2.actual_departure::date, cte_2.departure_airport  ORDER BY cte_2.actual_departure) AS passengers_inc_sum
FROM cte_2 ;


-----------------------------------------------------------------------
-- 6. ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.

-- �������:
-- � ���������� ������� ����� ���������� ��������� � ������� flights.
-- ��������� ������� flights ������� �� ������� aircrafts (������ �������� 'model').
-- ���������� �� ���� �������� (aircraft_code). 
-- ������� ���������� ��������� �� ������� ��������� � ����� �� ����� ���������� ������, ����������� � ����������. 
-- ��� ����, ����� �������� �� ����� ����� ��������, �������� �� 100.
-- ��������� � ������� ��������

SELECT a.model ,
	concat( round( count(f.flight_id):: NUMERIC / 
			(SELECT count(f.flight_id):: NUMERIC
			FROM flights f) * 100, 1), ' %' ) AS percentage_of_flights
FROM flights f 
JOIN aircrafts a USING (aircraft_code)
GROUP BY a.aircraft_code 
ORDER BY count(f.flight_id)::NUMERIC / (SELECT count(f.flight_id) FROM flights f) DESC ;


-----------------------------------------------------------------------
-- 7. ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?

-- �������: 
-- ������� ��� "cte_business" ��� ���� ��������� ������-������� � ��� "cte_economy" ��� ���� ��������� ������-�������,
-- � ���������������� ������, ������ ������� � ��������� ��������. 
-- ���������� ��� ��� �� �������������� �����, ��� ��������� ������� �� ��������� ��������� �������.
-- ����� ������� ������, ��������� ��������� flights � airports
-- ���������� �������� DISTINCT ��� ������ ���������� ��������

WITH cte_business AS (
	SELECT tf.flight_id, 
		tf.ticket_no, 
		tf.amount 
	FROM ticket_flights tf 
	WHERE tf.fare_conditions = 'Business'),
cte_economy AS (
	SELECT  tf.flight_id, 
		tf.ticket_no, 
		tf.amount 
	FROM ticket_flights tf 
	WHERE tf.fare_conditions = 'Economy')
SELECT DISTINCT a.city
FROM cte_business 
JOIN cte_economy ON cte_business.flight_id = cte_economy.flight_id AND cte_economy.amount > cte_business.amount
JOIN flights f ON cte_economy.flight_id = f.flight_id 
JOIN airports a ON f.arrival_airport = a.airport_code ;


-----------------------------------------------------------------------
-- 8. ����� ������ �������� ��� ������ ������?

--�������:
-- ��� ���� ����� ����� ����� ������ �������� ��� ������ ������: 
-- 1. ������� ��� ��������� ���������� ������� (������ ������), ������� ����� �������� �� ������� ���������.  
-- 2. �� ���� ��� ������� ������� ��, ����� �������� �������� ��������� ����� � ������� flights.

-- 1). 
-- ������� ������������� flights_d, � ������ ������� ����������� � ��������. ��������� ������� flights ������� ������ ����������� � ������ ��������. 
-- ��� ��������� ���������� ��� ��������� ������ ������, ������ ����������� �� ������ ����������� � ������ ��������.
CREATE VIEW flights_d AS 
	SELECT a1.city AS dep_city, a2.city AS arr_city
	FROM flights f 
	JOIN airports a1 ON f.departure_airport = a1.airport_code 
	JOIN airports a2 ON  f.arrival_airport = a2.airport_code
	GROUP BY dep_city , arr_city
	ORDER BY dep_city, arr_city ;
	
--2).
--��� ��������� ���� ��������� ��� �������, ������� ��������� ������������ � ����������� from, �������� ������ �� ������� airports.
-- (��� ����� ������������ ��� � ����� �������� ���������� � CROSS JOIN)
-- ��������� ���� � ����������� ��������. 
-- � ������� ��������� except ��������� ������, ����� �������� ���� ������ �����.  
SELECT a1.city AS dep_city , a2.city AS arr_city
FROM airports a1 , airports a2 
WHERE a1.city != a2.city 
EXCEPT 
SELECT fd.dep_city , fd.arr_city 
FROM flights_d fd 
ORDER BY dep_city , arr_city ;

  
-----------------------------------------------------------------------
-- 9. ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, 
-- ������������� ��� ����� *

-- �������: ����������� �������: flights, airports, aircrafts.
-- ��� ����������� ������� ������� CTE, � ������� �� ������� ��������� ���������� ����� �����������, ���������� ������� �������.
-- �� ������� flights �������� ���� ���������� ����������� � �������� �� ������ ������
-- ��������� ������� �� ������� airports, ������������ ���������� ����������� � ��������.
-- � �� ������� aircrafts ����� ��� ������ ��������, ��������������� ������� � ��� ���������� ��������� ������.
-- � ������� ��������� Case ���������� ����������� ���������� � ���������� ������������ ���������� ���������  � ���������, 
-- ������������� ��� ����� "range". ���� ���������� ����� ����������� ������ ������������ ��������� ��������, �� � ��������� ���������� True.
-- ���� ���������� ������ �� ���������� False.


WITH cte1 AS (
		SELECT DISTINCT a1.airport_name AS departure_airport ,
		a2.airport_name AS arrival_airport , 
		a.model ,
		a."range" ,
		round( acos( sin(radians(a1.latitude)) 
			* sin(radians(a2.latitude))
			+ cos(radians(a1.latitude))
			* cos(radians(a2.latitude))
			* cos(radians(a1.longitude - a2.longitude))) * 6371) AS distance
	FROM flights f
	JOIN airports  a1 ON f.departure_airport = a1.airport_code 
	JOIN airports a2 ON f.arrival_airport = a2.airport_code
	JOIN aircrafts a USING (aircraft_code)
	)
SELECT *,
	CASE
		WHEN "range" > distance THEN 'True'
		WHEN "range" < distance THEN 'False'
	END AS distance_compare
FROM cte1
ORDER BY departure_airport ;