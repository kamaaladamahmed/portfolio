-- Questions Being Answered:
-- 1. What days and times tend to be the busiest?
-- 2. How many pizzas are we making during peak periods?
-- 3. What are our best and worst selling pizzas?
-- 4. What is our average order value?

SELECT to_char(ordjoin.date, 'Day') AS weekday,
	AVG(SUM(ordjoin.quantity)) OVER (PARTITION BY to_char(ordjoin.date, 'Day')) AS avg_order
FROM (
	SELECT *
	FROM orders ord
	JOIN order_details det ON ord.order_id = det.order_id
	) AS ordjoin
GROUP BY to_char(ordjoin.date, 'Day')

--

SELECT ordjoin.date,
	to_char(ordjoin.date, 'Day') AS weekday,
	EXTRACT(HOUR FROM ordjoin.time) AS hour,
	SUM(ordjoin.quantity) AS quantity
FROM (
	SELECT *
	FROM orders ord
	JOIN order_details det ON ord.order_id = det.order_id
	) AS ordjoin
GROUP BY EXTRACT(HOUR FROM ordjoin.TIME),
	ordjoin.date
ORDER BY ordjoin.date,
	hour

--

SELECT piz_typ.name,
	pizzas.orders
FROM (
	SELECT piz.pizza_type_id,
		SUM(ordjoin.quantity) AS orders
	FROM (
		SELECT *
		FROM orders ord
		JOIN order_details det ON ord.order_id = det.order_id
		) AS ordjoin
	JOIN pizzas piz ON ordjoin.pizza_id = piz.pizza_id
	GROUP BY piz.pizza_type_id
	) AS pizzas
JOIN pizza_types piz_typ ON pizzas.pizza_type_id = piz_typ.pizza_type_id
ORDER BY orders DESC


--

SELECT
SUM(piz.price)/COUNT(ordjoin.order_id) AS avg_order_value
FROM(
	SELECT 
  	ord.order_id,
  	det.pizza_id
	FROM orders ord
	JOIN order_details det
	ON ord.order_id = det.order_id ) AS ordjoin
JOIN pizzas piz
ON ordjoin.pizza_id = piz.pizza_id


