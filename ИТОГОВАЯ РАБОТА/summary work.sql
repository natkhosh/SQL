-- select bookings.now() as now;

-----------------------------------------------------------------------
-- 1. В каких городах больше одного аэропорта?

-- Решение: 
-- Группируем таблицу airports по столбцу city. 
-- Фильтруем по условию (having), что количество сгруппированных записей должно быть больше 1.

SELECT a.city,
	COUNT(*) AS airport_count
FROM airports a
GROUP BY a.city
HAVING COUNT(*) > 1
ORDER BY a.city ;

-----------------------------------------------------------------------
-- 2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?

-- Решение: Потребуются таблицы: aircrafts, flights, airports. 
-- С помощью подзапроса находим самолет, у которого дальность перелета максимальна. Для этого сортируем дальность полета "range" 
-- по убыванию и выводим только первую строчку.
-- Далее присоединяем таблицы flights и airports, чтобы получить название аэропорта.
-- * для объединения таблиц (flights и airports), нас устроит и аэропорт прибытия, и аэропорт отправления. Использую оператор ИЛИ в соединении.

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
-- 3. Вывести 10 рейсов с максимальным временем задержки вылета

-- Решение:
-- Задержка вылета это разница между фактическим временем вылета и временем вылета по расписанию 
-- Задержку вылета можно рассчитать только для рейсов, 
-- у которых есть записи фактического времени вылета ('actual_departure' is NOT NULL)
-- Сортируем по убыванию время задержки вылета и выводим первые 10 значений

SELECT flight_no,  (f.actual_departure - f.scheduled_departure) AS departure_delay_time
FROM flights f 
WHERE f.actual_departure is NOT NULL 
ORDER BY departure_delay_time DESC 
LIMIT 10 ;

-----------------------------------------------------------------------
-- 4. Были ли брони, по которым не были получены посадочные талоны?

-- Решение:
-- связываем брони билетов с посадочными талонами через билеты ticket_no.
-- Фильтруем по условию, что посадочные талоны не были получены 'boarding_no' IS NULL. 
-- Т.к. при объединении таблиц boarding_no у броней на чьи билеты не были выписана посадочные талоны, пропишется NULL
-- По условия таблицы boarding_passes, boarding_no не может быть NULL, тем самым мы сможем однозначно определить брони,
-- по которым не были получены посадочные талоны. 

SELECT count(book_ref) 
FROM  bookings
FULL OUTER JOIN tickets USING (book_ref)
FULL OUTER JOIN boarding_passes USING (ticket_no)
WHERE boarding_passes.boarding_no IS NULL ;


-----------------------------------------------------------------------
-- 5. Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
-- Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
-- Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.

-- Решение: Потребуются таблицы: boarding_passes, flights, seats
-- Чтобы найти свободные места для каждого рейса, нужно определить количество посадочных мест в самолете и количество выданных посадочных талонов.
-- Создаем первое CTE в котором считаем количество посадочных мест для каждой модели самолета
-- во втором CTE: обогащаем cte_1 данными из таблиц flights и boarding_passes, для нахождения выданых посадочных талонов
-- Считаем количество свободных мест: общее кол-во мест в самолете - кол-во мест в выданными посадочными талонами.
-- Процент свободных мест: round((cte_1.total_seats - count(bp.seat_no))::NUMERIC / cte_1.total_seats * 100).
-- Создаем оконную функцию для рассчета суммарного накопления количества вывезенных пассажиров из каждого аэропорта на каждый день. 
-- Она суммирует количество занятых мест на рейсе. Группировка производится по departure_airport и actual_departure, 
-- при этом дату приводим к типу date, оставляя только дату без указания времени для возможности подсчета по дням.
-- Сортировка в окне производится по actual_departure (дата с указанием времени).

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
-- 6. Найдите процентное соотношение перелетов по типам самолетов от общего количества.

-- Решение:
-- В подзапросе находим общее количество перелетов в таблице flights.
-- Обогащаем таблицу flights данными из таблицы aircrafts (модель самолета 'model').
-- Группируем по коду самолета (aircraft_code). 
-- Считаем количество перелетов по моделям самолетов и делим на общее количество рейсов, вычисленное в подзапросе. 
-- Для того, чтобы получить из этого числа проценты, умножаем на 100.
-- Сортируем в порядке убывания

SELECT a.model ,
	concat( round( count(f.flight_id):: NUMERIC / 
			(SELECT count(f.flight_id):: NUMERIC
			FROM flights f) * 100, 1), ' %' ) AS percentage_of_flights
FROM flights f 
JOIN aircrafts a USING (aircraft_code)
GROUP BY a.aircraft_code 
ORDER BY count(f.flight_id)::NUMERIC / (SELECT count(f.flight_id) FROM flights f) DESC ;


-----------------------------------------------------------------------
-- 7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?

-- Решение: 
-- Создаем СТЕ "cte_business" для всех перелетов бизнес-классом и СТЕ "cte_economy" для всех перелетов эконом-классом,
-- с идентификаторами рейсов, номера билетов и стоимости перелета. 
-- Объединяем два ОТВ по идентификатору рейса, где стоимость бизнеса не превышает стоимость эконома.
-- Чтобы вывести города, обогащаем таблицами flights и airports
-- Используем оператор DISTINCT для вывода уникальных значений

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
-- 8. Между какими городами нет прямых рейсов?

--Решение:
-- Для того чтобы найти между какими городами нет прямых рейсов: 
-- 1. находим все возможные комбинации городов (прямых рейсов), которые можно получить из таблицы перелетов.  
-- 2. из этих пар городов убираем те, между которыми найдутся связующие рейсы в таблице flights.

-- 1). 
-- Создаем представление flights_d, с парами городов отправления и прибытия. Обогощаем таблицу flights данными города отправления и города прибытия. 
-- Для получения уникальных пар возможных прямых рейсов, делаем группировку по городу отправления и городу прибытия.
CREATE VIEW flights_d AS 
	SELECT a1.city AS dep_city, a2.city AS arr_city
	FROM flights f 
	JOIN airports a1 ON f.departure_airport = a1.airport_code 
	JOIN airports a2 ON  f.arrival_airport = a2.airport_code
	GROUP BY dep_city , arr_city
	ORDER BY dep_city, arr_city ;
	
--2).
--Для получения всех возможных пар городов, находим декартово произведение в предложении from, соотнося города из таблицы airports.
-- (или можно использовать еще и явную операцию соединения – CROSS JOIN)
-- Исключаем пары с одинаковыми городами. 
-- С помощью оператора except исключаем города, между которыми есть прямые рейсы.  
SELECT a1.city AS dep_city , a2.city AS arr_city
FROM airports a1 , airports a2 
WHERE a1.city != a2.city 
EXCEPT 
SELECT fd.dep_city , fd.arr_city 
FROM flights_d fd 
ORDER BY dep_city , arr_city ;

  
-----------------------------------------------------------------------
-- 9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, 
-- обслуживающих эти рейсы *

-- Решение: Потребуются таблицы: flights, airports, aircrafts.
-- Для оптимизации запроса создаем CTE, в котором по формуле вычисляем расстояние между аэропортами, связанными прямыми рейсами.
-- Из таблицы flights получаем коды аэропортов отправления и прибытия на прямых рейсах
-- Обогащаем данными из таблицы airports, координатами аэропортов отправления и прибытия.
-- И из таблицы aircrafts берем код модели самолета, осуществляющего перелет и его допустимую дальность полета.
-- С помощью оператора Case сравниваем вычисленное расстояние с допустимой максимальной дальностью перелетов  в самолетах, 
-- обслуживающих эти рейсы "range". Если расстояние между аэропортами меньше максимальной дальности перелета, то в результат записываем True.
-- Если расстояние больше то записываем False.


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