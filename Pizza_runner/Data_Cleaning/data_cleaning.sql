-- A. Data CLeaning : Pizza Metrics
-- data cleaning : customer_orders_temporary ( create a new temporary table from customer_order )
CREATE TABLE customer_orders_temporary AS
SELECT order_id,
	   customer_id,
       pizza_id,
	CASE WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
		ELSE exclusions END AS exclusions,
    CASE WHEN extras IS NULL OR extras LIKE 'null' THEN ''
		ELSE extras END AS extras,
	  order_time
FROM customer_orders;

SELECT * FROM customer_orders_temporary;


-- data cleaning : runner_orders_temporary ( create a new temporary table from runner_order)
CREATE TABLE runner_orders_temporary AS
SELECT order_id,
	   runner_id,
	CAST(CASE WHEN pickup_time LIKE 'null' THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
    CAST(CASE
			WHEN distance LIKE 'null' THEN NULL
            WHEN distance LIKE '%km' THEN REPLACE(distance, 'km', '')
            ELSE distance END AS FLOAT) AS distance,
	CAST(CASE
			WHEN duration LIKE 'null' THEN NULL
            WHEN duration LIKE '%mins' THEN REPLACE(duration, 'mins', '')
            WHEN duration LIKE '%minute' THEN REPLACE(duration, 'minute', '')
            WHEN duration LIKE '%minutes' THEN REPLACE(duration, 'minutes', '')
            ELSE duration END AS SIGNED) AS duration,
	CASE
		WHEN cancellation IN ('null', 'NaN', '') THEN NULL
        ELSE cancellation END AS cancellation
FROM runner_orders;

SELECT * FROM runner_orders_temporary