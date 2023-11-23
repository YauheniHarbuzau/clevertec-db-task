--1. Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT a.model, s.fare_conditions, COUNT(s.seat_no) AS seats_count
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
GROUP BY a.model, s.fare_conditions
ORDER BY a.model, s.fare_conditions;


--2. Найти 3 самых вместительных самолета (модель + количество мест).
SELECT a.model, COUNT(s.seat_no) AS seats_count
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
GROUP BY a.model
ORDER BY COUNT(s.seat_no) DESC LIMIT 3;


--3. Найти все рейсы, которые задерживались более 2 часов.
SELECT flight_no
FROM flights f
WHERE actual_departure > scheduled_departure + INTERVAL '2' HOUR;


--4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'),
--с указанием имени пассажира и контактных данных.
/*
  Так как даты покупки билета нет -
  по номеру билета, если следовать логике, что номера билетов идут в порядке продажи.
*/
SELECT tf.ticket_no, t.passenger_name, t.contact_data
FROM ticket_flights tf
INNER JOIN tickets t
    ON tf.ticket_no = t.ticket_no
WHERE fare_conditions = 'Business'
ORDER BY ticket_no DESC LIMIT 10;
/*
  Второй вариант - по дате бронирования.
*/
SELECT tf.ticket_no, t.passenger_name, t.contact_data
FROM ticket_flights tf
INNER JOIN tickets t
    ON tf.ticket_no = t.ticket_no
INNER JOIN bookings b
    ON t.book_ref = b.book_ref
WHERE fare_conditions = 'Business'
ORDER BY book_date DESC LIMIT 10;


--5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business').
SELECT *
FROM flights f
WHERE flight_id NOT IN (
    SELECT flight_id
    FROM ticket_flights tf
    INNER JOIN tickets t
        ON t.ticket_no = tf.ticket_no
    WHERE tf.fare_conditions = 'Business')
ORDER BY flight_id ASC;


--6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой.
SELECT DISTINCT a.airport_name, a.city
FROM airports a
INNER JOIN flights f
    ON a.airport_code = f.departure_airport
WHERE f.status = 'Delayed';


--7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта,
--отсортированный по убыванию количества рейсов.
SELECT a.airport_name, COUNT(f.flight_id)
FROM airports a
INNER JOIN flights f
    ON a.airport_code = f.departure_airport
GROUP BY a.airport_name
ORDER BY COUNT(f.flight_id) DESC;


--8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival)
--было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным.
SELECT *
FROM flights f
WHERE scheduled_arrival != actual_arrival;


--9. Вывести код, модель самолета и места не эконом класса для самолета 'Аэробус A321-200'
--с сортировкой по местам.
SELECT a.aircraft_code, a.model, s.seat_no
FROM aircrafts a
INNER JOIN seats s
    ON a.aircraft_code = s.aircraft_code
WHERE a.model = 'Аэробус A321-200'
    AND s.fare_conditions != 'Economy'
ORDER BY s.seat_no ASC;


--10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город).
SELECT a.airport_code, a.airport_name, a.city
FROM airports a
WHERE a.city IN (SELECT a2.city
                 FROM airports a2
                 GROUP BY a2.city
                 HAVING COUNT(a2.city) > 1);


--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований.
SELECT t.passenger_id, t.passenger_name
FROM tickets t
INNER JOIN bookings b
    ON b.book_ref = t.book_ref
GROUP BY t.passenger_id, t.passenger_name
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM bookings);


--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация.
SELECT f.flight_no
FROM flights f
INNER JOIN airports a
    ON a.airport_code = f.departure_airport
INNER JOIN airports a2
    ON a2.airport_code = f.arrival_airport
WHERE a.city = 'Екатеринбург'
    AND a2.city = 'Москва'
    AND f.status IN ('On Time', 'Delayed');


--13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе).
SELECT 'min ticket cost' AS cost, MIN(tf.amount)
FROM ticket_flights tf
UNION
SELECT 'max ticket cost', MAX(tf2.amount)
FROM ticket_flights tf2;


--14. Написать DDL таблицы Customers, должны быть поля id, firstName, lastName, email, phone.
CREATE TABLE IF NOT EXISTS customers
(
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name  VARCHAR(30),
    email      VARCHAR(40),
    phone      VARCHAR(20)
);
--Добавить ограничения на поля (constraints).
ALTER TABLE customers ALTER COLUMN first_name SET NOT NULL;
ALTER TABLE customers ALTER COLUMN last_name SET NOT NULL;
ALTER TABLE customers ALTER COLUMN email SET NOT NULL;
ALTER TABLE customers ALTER COLUMN phone SET NOT NULL;
ALTER TABLE customers ADD CONSTRAINT unique_customer UNIQUE (first_name, last_name, email, phone);


--15. Написать DDL таблицы Orders, должен быть id, customerId, quantity.
CREATE TABLE IF NOT EXISTS orders
(
    id          SERIAL PRIMARY KEY,
    customer_id BIGINT,
    quantity    INT
);
--Должен быть внешний ключ на таблицу Customers + constraints.
ALTER TABLE orders ALTER COLUMN customer_id SET NOT NULL;
ALTER TABLE orders ALTER COLUMN quantity SET NOT NULL;
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers (id);


--16. Написать 5 INSERT в эти таблицы.
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Иван', 'Иванов', 'ivan@gmail.com', '1111111111'),
       ('Петр', 'Петров', 'petr@gmail.com', '2222222222'),
       ('Сидр', 'Сидоров', 'sidr@gmail.com', '3333333333'),
       ('Гаврюша', 'Гаврилов', 'gavr@gmail.com', '4444444444'),
       ('Александр', 'Александров', 'alex@gmail.com', '5555555555');
INSERT INTO orders (customer_id, quantity)
VALUES (1, 3),
       (2, 5),
       (2, 4),
       (3, 1),
       (4, 22);
/*
  Еще один повторный INSERT для пояснения ограничения unique_customer.
  При повторной попытке добавления того же покупателя, сработает ограничение (ошибка).
*/
INSERT INTO customers (first_name, last_name, email, phone)
VALUES ('Иван', 'Иванов', 'ivan@gmail.com', '1111111111');


--17. Удалить таблицы.
/*
  При наличии зависимостей первой удаляется зависимая таблица.
*/
DROP TABLE orders;
DROP TABLE customers;
/*
  С использованием DROP CASCADE - небезопасно, возможна потеря данных.
*/
DROP TABLE customers CASCADE;
DROP TABLE orders CASCADE;