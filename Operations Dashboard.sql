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

SELECT sum(piz.price) AS total_rev,
       count(DISTINCT det.order_id) AS total_orders,
       sum(det.quantity) AS total_pizzas,
       sum(CAST(det.quantity AS DECIMAL)) / count(DISTINCT det.order_id) AS pizza_order,
       sum(piz.price) / count(DISTINCT det.order_id) AS order_value
  FROM order_details AS det JOIN pizzas AS piz ON det.pizza_id = piz.pizza_id;

-- Customer Traffic Analysis / Heatmap

SELECT
	to_char(ordjoin.date, 'Day') AS weekday,
	extract('hour', ordjoin.time) AS hour,
	count(DISTINCT ordjoin.order_id) AS orders
FROM
	(SELECT det.order_id, ord.date, ord.time FROM orders AS ord JOIN order_details AS det ON ord.order_id = det.order_id)
		AS ordjoin
GROUP BY
	extract('hour', ordjoin.time), ordjoin.date
ORDER BY
	ordjoin.date, hour;


-- Quadrant Chart (Revenue, Quantity | Type, Size)

SELECT
	pizza.pizza_type_id, concat(piztyp.name, ', ', pizza.size), pizza.size, pizza.revenue, pizza.quantity_sold
FROM
	(
		SELECT
			piz.pizza_id, piz.pizza_type_id, piz.size, sum(piz.price) AS revenue, sum(ordjoin.quantity) AS quantity_sold
		FROM
			(
				SELECT
					ord.order_id, det.pizza_id, sum(det.quantity) AS quantity
				FROM
					orders AS ord JOIN order_details AS det ON ord.order_id = det.order_id
				GROUP BY
					ord.order_id, det.pizza_id
			)
				AS ordjoin
			JOIN pizzas AS piz ON ordjoin.pizza_id = piz.pizza_id
		GROUP BY
			piz.pizza_id, piz.pizza_type_id, piz.size
	)
		AS pizza
	JOIN pizza_types AS piztyp ON pizza.pizza_type_id = piztyp.pizza_type_id;

--  Order Quantity per Hour per Day of the Week (Capacity Analysis)

WITH
	hourly_pizzas
		AS (
			SELECT
				ordjoin.date AS date,
				to_char(ordjoin.date, 'Day') AS weekday,
				extract('hour', ordjoin.time) AS hour,
				count(DISTINCT ordjoin.order_id) AS orders,
				sum(ordjoin.quantity) AS pizzas
			FROM
				(
					SELECT
						det.order_id, ord.date, ord.time, det.quantity
					FROM
						orders AS ord JOIN order_details AS det ON ord.order_id = det.order_id
				)
					AS ordjoin
			GROUP BY
				ordjoin.date, extract('hour', ordjoin.time)
			ORDER BY
				ordjoin.date, hour
		)
SELECT
	percentile_cont(0.5)WITHIN GROUP (ORDER BY pizzas)
FROM
	hourly_pizzas;

-- Pizza Type & Size Popularity (Bar Chart)

DROP TABLE pizza_orders;

CREATE TABLE pizza_orders (
	date DATE, name VARCHAR(50), pizza_id VARCHAR(50), size VARCHAR(50), price DECIMAL, quantity INT8
);

INSERT
INTO
	pizza_orders2
SELECT
	ordjoin2.date, piz_typ.name, ordjoin2.pizza_id, ordjoin2.size, ordjoin2.price, ordjoin2.quantity
FROM
	(
		SELECT
			ordjoin.date, piz.pizza_id, piz.pizza_type_id, piz.size, piz.price, ordjoin.quantity
		FROM
			(SELECT * FROM orders AS ord JOIN order_details AS det ON ord.order_id = det.order_id) AS ordjoin
			JOIN pizzas AS piz ON ordjoin.pizza_id = piz.pizza_id
		GROUP BY
			ordjoin.date, piz.pizza_id, piz.pizza_type_id, piz.size, piz.price, ordjoin.quantity
	)
		AS ordjoin2
	JOIN pizza_types AS piz_typ ON ordjoin2.pizza_type_id = piz_typ.pizza_type_id
ORDER BY
	ordjoin2.date ASC;