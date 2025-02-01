-- B. Runner and Customer Experience


-- 1. How many runner signed up for each 1 week period ? (i.e week starts 2021-01-01)
SELECT WEEK(registration_date, 1) AS week_period,
	   COUNT(*) AS runner_count 
FROM runners
GROUP BY WEEK(registration_date, 1);
-- 2. What was the average time in minutes it took for each runner to arrive at the pizza runner HQ to pickup the order ?
WITH runners_pickup AS (
	SELECT rot.runner_id,
		   cot.order_id,
           cot.order_time,
           rot.pickup_time,
           TIMESTAMPDIFF(MINUTE, cot.order_time, rot.pickup_time) AS pickup_minutes
    FROM customer_orders_temporary AS cot
    JOIN runner_orders_temporary AS rot
    ON cot.order_id = rot.order_id
    WHERE rot.cancellation IS NULL
    GROUP BY rot.runner_id, cot.order_id, cot.order_time, rot.pickup_time
)

SELECT runner_id,
	   ROUND(AVG(pickup_minutes), 0) AS average_minutes
FROM runners_pickup
GROUP BY runner_id
-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare ?
WITH pizza_relationship AS (
	SELECT cot.order_id,
		   cot.order_time,
           rot.pickup_time,
		   TIMESTAMPDIFF(MINUTE, cot.order_time, rot.pickup_time) AS preparation_time,
           COUNT(cot.pizza_id) AS pizza_count
    FROM customer_orders_temporary AS cot
    LEFT JOIN runner_orders_temporary AS rot
    ON cot.order_id = rot.order_id
    WHERE cancellation IS NULL
    GROUP BY cot.order_id, cot.order_time, rot.pickup_time, TIMESTAMPDIFF(MINUTE, cot.order_time, rot.pickup_time)
)

SELECT pizza_count,
	   ROUND(AVG(preparation_time), 0) AS avg_prep
FROM pizza_relationship
GROUP BY pizza_count
-- 4. What was the average distance travelled for each customer ?
SELECT cot.customer_id,
	   ROUND(AVG(rot.distance), 1) AS average_distance
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
GROUP BY cot.customer_id
-- 5. What was the difference between the longest and shortest delivery times for all orders ?
SELECT MAX(duration) - MIN(duration) AS diff_delivery_times
FROM runner_orders_temporary
-- 6. What was the average speed for each runner for each delivery and do you do notice any trend for these values ?
SELECT rot.runner_id,
	   cot.order_id,
       rot.distance,
       rot.duration AS duration_min,
       COUNT(cot.order_id) AS pizza_count,
       ROUND(AVG(rot.distance/rot.duration*60), 2) AS avg_speed
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY rot.runner_id, cot.order_id, rot.distance, rot.duration

-- 7. What is the succesfull delivery percentage for each runner ?
SELECT runner_id,
	   COUNT(distance) AS delivered,
       COUNT(order_id) AS total,
       CONCAT(ROUND((COUNT(distance) / COUNT(order_id) * 100), 0), '%')  AS succesfull_percentage
FROM runner_orders_temporary
GROUP BY runner_id


SELECT * FROM runner_orders_temporary