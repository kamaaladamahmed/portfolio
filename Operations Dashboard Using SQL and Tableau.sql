-- Plato's Pizza Operations Dashboard 
-- https://public.tableau.com/app/profile/adam.ahmed4555/viz/PlatosPizzaOperationsDashboard/

-- Questions to answer:
--	What days and times do we tend to be busiest?
--	How many pizzas are we making during peak periods?
--	What are our best and worst selling pizzas?
--	hat's our average order value?
--	How well are we utilizing our seating capacity? (we have 15 tables and 60 seats)

-- SQL Skills Used: Subqueries, Joins, CTEs, Temp Tables, Aggregate Functions
-- Database Software: PostgreSQL

-- Top Level KPIs

SELECT SUM(piz.price * det.quantity) AS total_rev,
       COUNT(DISTINCT det.order_id) AS total_orders,
       SUM(det.quantity) AS total_pizzas,
       AVG(det.quantity) AS pizza_order,
       AVG(piz.price) AS order_value
FROM order_details AS det
JOIN pizzas AS piz ON det.pizza_id = piz.pizza_id;

-- Customer Traffic Analysis / Heatmap

SELECT to_char(ord.date, 'Day') AS weekday, extract('hour' FROM ord.time) AS hour, COUNT(DISTINCT ord.order_id) AS orders
FROM orders AS ord
JOIN order_details AS det ON ord.order_id = det.order_id
GROUP BY extract('hour' FROM ord.time), ord.date
ORDER BY ord.date, hour;

-- Quadrant Chart (Revenue, Quantity | Type, Size)

SELECT piz.pizza_type_id, concat(piztyp.name, ', ', piz.size), piz.size, SUM(ordjoin.price * ordjoin.quantity) AS revenue, SUM(ordjoin.quantity) AS quantity_sold
FROM (
	SELECT ord.order_id, det.pizza_id, det.quantity, piz.price
	FROM orders AS ord
	JOIN order_details AS det ON ord.order_id = det.order_id
	JOIN pizzas AS piz ON det.pizza_id = piz.pizza_id
) AS ordjoin
JOIN pizzas AS piz ON ordjoin.pizza_id = piz.pizza_id
JOIN pizza_types AS piztyp ON piz.pizza_type_id = piztyp.pizza_type_id
GROUP BY piz.pizza_type_id, piz.size, piztyp.name

--  Order Quantity per Hour per Day of the Week (Capacity Analysis)

WITH hourly_pizzas AS (
	SELECT
		ord.date AS date,
		to_char(ord.date, 'Day') AS weekday,
		extract('hour', ord.time) AS hour,
		COUNT(DISTINCT ord.order_id) AS orders,
		SUM(det.quantity) AS pizzas
	FROM orders AS ord
	JOIN order_details AS det ON ord.order_id = det.order_id
	GROUP BY ord.date, extract('hour', ord.time)
	ORDER BY ord.date, hour
)
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY pizzas)
FROM hourly_pizzas;

-- Pizza Type & Size Popularity (Bar Chart)

DROP TABLE pizza_orders;

CREATE TABLE pizza_orders (
	date DATE,
	name VARCHAR(50),
	pizza_id VARCHAR(50),
	size VARCHAR(50),
	price DECIMAL,
	quantity INT8
);

WITH ordjoin AS (
	SELECT ord.order_id, ord.date, det.pizza_id, det.quantity
	FROM orders AS ord
	JOIN order_details AS det ON ord.order_id = det.order_id
), ordjoin2 AS (
	SELECT ordjoin.date, piz.pizza_id, piz.pizza_type_id, piz.size, piz.price, ordjoin.quantity
	FROM ordjoin
	JOIN pizzas AS piz ON ordjoin.pizza_id = piz.pizza_id
	GROUP BY ordjoin.date, piz.pizza_id, piz.pizza_type_id, piz.size, piz.price, ordjoin.quantity
)
INSERT INTO pizza_orders (date, name, pizza_id, size, price, quantity)
SELECT ordjoin2.date, piz_typ.name, ordjoin2.pizza_id, ordjoin2.size, ordjoin2.price, ordjoin2.quantity
FROM ordjoin2
JOIN pizza_types AS piz_typ ON ordjoin2.pizza_type_id = piz_typ.pizza_type_id
ORDER BY ordjoin2.date ASC;

