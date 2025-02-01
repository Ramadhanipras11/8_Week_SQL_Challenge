-- A. Pizza Metrics --

-- 1. How many pizzas were ordered ?
SELECT COUNT(*) AS pizza_order 
FROM customer_orders_temporary;

-- 2. How many unique customer orders were made ?
SELECT COUNT(DISTINCT order_id) AS order_count 
FROM customer_orders_temporary;

-- 3. How many succesful orders were delivered by each runner ?
SELECT rot.runner_id,
	   COUNT(cot.order_id) AS success_order
FROM customer_orders_temporary AS cot
JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY rot.runner_id;

-- 4. How many of each type of pizza was delivered ?
SELECT p.pizza_name,
	   COUNT(cot.order_id) AS pizza_order
FROM customer_orders_temporary AS cot
LEFT JOIN pizza_names AS p
ON cot.pizza_id = p.pizza_id
WHERE cot.order_id IN (SELECT order_id FROM runner_orders_temporary WHERE cancellation IS NULL)
GROUP BY p.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer ?
SELECT customer_id,
	   SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS MeatLovers,
       SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders_temporary
GROUP BY customer_id;

-- 6. What was the maximum number of pizzas delivered in single order ?
WITH single_order AS (
SELECT cot.order_id,
	   COUNT(cot.pizza_id) AS pizza_count
FROM customer_orders_temporary  AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY cot.order_id)

SELECT MAX(pizza_count) AS maximum_pizza_delivered
FROM single_order
GROUP BY order_id
ORDER BY MAX(pizza_count) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no change
SELECT cot.customer_id,
	   SUM(CASE WHEN cot.exclusions <> '' OR cot.extras <> '' THEN 1 ELSE 0 END) AS had_change,
       SUM(CASE WHEN cot.exclusions = '' OR cot.extras = '' THEN 1 ELSE 0 END) AS no_change
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY cot.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras ?
SELECT SUM(CASE WHEN cot.exclusions <> '' AND cot.extras <> '' THEN 1 ELSE 0 END) AS change_both
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day ?
SELECT HOUR(order_time) AS hour_of_day,
	   COUNT(order_id) AS pizza_order
FROM customer_orders_temporary
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;

-- 10. What was the volume of orders for each day of the week ?
SELECT DAYNAME(order_time) AS day_of_week,
	   COUNT(order_id) AS pizza_order
FROM customer_orders_temporary
GROUP BY DAYNAME(order_time)
ORDER BY day_of_week;