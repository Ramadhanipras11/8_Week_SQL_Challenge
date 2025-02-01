# 🍕 Pizza Runner

<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image" width="500" height="550">

## 📘 content
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- Solution
  - [Data Cleaning and Transformation](#data-cleaning-and-transformation)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)

Kindly be advised that all details related to the case study have been obtained from the following link: [here](https://8weeksqlchallenge.com/case-study-2/)

## Business Task
Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.
## Entity Relationship Diagram
<img width="611" alt="Image" src="https://github.com/user-attachments/assets/f2bdcd13-7325-4766-b87b-3eb238170ab1" />

## 🚿 Data Cleaning and Transformation
#### 📃 Table : customer_orders
in the `customer_orders` table, we can see there are
- in the `exclusion` columns, there are missing/blank spaces such as  ' '  and null values
- in the `extras` column, there are missing/blank spaces such as  ' '  and null values
<img width="539" alt="Image" src="https://github.com/user-attachments/assets/2f2677a5-03c4-40ad-bbe6-e884f184573a" /> 

our course of action to clean the table :
- Create a temporary table with all the columns
- Remove null values in `exlusions` and `extras` columns and replace with blank space ' '.
````sql
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
````
This is how the customer_orders_temporary table looks like after being cleaned and we can use this for query processing.
<img src="https://github.com/user-attachments/assets/de56bf64-2b94-4941-9521-c27c07c100d7" alt="Deskripsi Gambar" width="600">

#### 📃 Table : runner_orders
in the `runner_orders` table, we can see there are
- in the `pickup_time` columns, there are null values
- in the `distance` column, there are null values
- in the `duration` column, there are null values
- in the `cancellation` column, there are missing values and null values
<img width="766" alt="Image" src="https://github.com/user-attachments/assets/37b5cc59-9eba-4ca8-afc9-ef20a7afa32c" />

our course of action to clean the table
- create a temporary table with all the column
- remove null values in `pickup_time`, `distance`, `duration`, and `cancellation`. And replace with blank space
- remove 'km' in `distance` columns
- remove 'mins', 'minute', 'minutes' in `duration` columns
````sql
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
````
This is how the runner_orders_temporary table looks like after being cleaned and we can use this for query processing.
<img src="https://github.com/user-attachments/assets/d4eca337-1ecc-44d9-b449-e84a60b03413" alt="Deskripsi Gambar" width="600">
## A. Pizza Metrics
### 1. How many pizzas were ordered ?
````sql
SELECT COUNT(*) AS pizza_order 
FROM customer_orders_temporary;
````
**Answer**

<img width="80" alt="Image" src="https://github.com/user-attachments/assets/02ecea1f-8580-4cae-ad92-8cc6d72bc462" />

- The total pizza ordered was 14 pizzas.

### 2. How many unique customer orders were made ?
````sql
SELECT COUNT(DISTINCT order_id) AS order_count 
FROM customer_orders_temporary;
````
**Answer**

<img width="80" alt="Image" src="https://github.com/user-attachments/assets/b8cb4c98-e201-4bd9-95a1-749e2282d0b6" />

- There are 10 unique customer order
### 3. How many succesful orders were delivered by each runner ?
````sql
SELECT rot.runner_id,
	   COUNT(cot.order_id) AS success_order
FROM customer_orders_temporary AS cot
JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY rot.runner_id;
````
**Answer**

<img width="133" alt="Image" src="https://github.com/user-attachments/assets/1e4617b9-b633-4565-9f40-f6c3a298611e" />

- Runner 1 has succesfully delivered 4 orders
- Runner 2 has succesfully delivered 3 orders
- Runner 3 has succesfully delivered 1 orders
### 4. How many of each type of pizza was delivered ?
````sql
SELECT p.pizza_name,
	   COUNT(cot.order_id) AS pizza_order
FROM customer_orders_temporary AS cot
LEFT JOIN pizza_names AS p
ON cot.pizza_id = p.pizza_id
WHERE cot.order_id IN (SELECT order_id FROM runner_orders_temporary WHERE cancellation IS NULL)
GROUP BY p.pizza_name;
````
**Answer**

<img width="132" alt="Image" src="https://github.com/user-attachments/assets/cfd7f55d-15e0-4e1f-8ad0-1ecf62378440" />

- A total of 9 Meatlovers pizzas and 3 Vegetarian pizzas have been delivered.
### 5. How many Vegetarian and Meatlovers were ordered by each customer ?
````sql
SELECT customer_id,
	   SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS MeatLovers,
       SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders_temporary
GROUP BY customer_id;
````
**Answer**

<img width="185" alt="Image" src="https://github.com/user-attachments/assets/97ba251e-5902-417c-ba21-8ad7fcb74014" />

- Customer 101 ordered two Meatlovers pizzas and one Vegetarian pizza.
- Customer 102 ordered two Meatlovers pizzas and two Vegetarian pizzas.
- Customer 103 ordered three Meatlovers pizzas and one Vegetarian pizza.
- Customer 104 ordered one Meatlovers pizza.
- Customer 105 ordered one Vegetarian pizza.
### 6. What was the maximum number of pizzas delivered in a single order ?
````sql
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
````
**Answer**

<img width="130" alt="Image" src="https://github.com/user-attachments/assets/68633b58-22e1-4c8a-8e44-b530faad468a" />

- The highest number of pizzas delivered in a single order is 3
### 7. for each customer, how many delivered pizzas had at least 1 change and how many had no change ?
````sql
SELECT cot.customer_id,
	   SUM(CASE WHEN cot.exclusions <> '' OR cot.extras <> '' THEN 1 ELSE 0 END) AS had_change,
       SUM(CASE WHEN cot.exclusions = '' OR cot.extras = '' THEN 1 ELSE 0 END) AS no_change
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL
GROUP BY cot.customer_id;
````
**Answer**

<img width="187" alt="Image" src="https://github.com/user-attachments/assets/4a317f3d-3c9f-4552-8f6b-ae1fe36de562" />

- Customers 101 and 102 prefer their pizzas as per the original recipe.
- Customers 103, 104, and 105 have their own topping preferences and requested at least one modification (addition or removal of toppings) on their pizzas.
### 8. How many pizzas were delivered that had both exclusions and extras ?
````sql
SELECT SUM(CASE WHEN cot.exclusions <> '' AND cot.extras <> '' THEN 1 ELSE 0 END) AS change_both
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
WHERE rot.cancellation IS NULL;
````
**Answer**

<img width="84" alt="Image" src="https://github.com/user-attachments/assets/21114a26-faf0-4009-bb69-5eedc57ca7d1" />

- Only one delivered pizza included both extra and excluded toppings—now that’s a picky customer!
### 9. What was the total volume of pizzas ordered for each hour of the day ?
````sql
SELECT HOUR(order_time) AS hour_of_day,
	   COUNT(order_id) AS pizza_order
FROM customer_orders_temporary
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;
````
**Answer**

<img width="137" alt="Image" src="https://github.com/user-attachments/assets/6c8da6c5-5094-4d8f-9702-12dce930968d" />

- The highest number of pizzas ordered was at 1:00 PM (13), 6:00 PM (18), and 9:00 PM (21).
- The lowest number of pizzas ordered was at 11:00 AM (11), 7:00 PM (19), and 11:00 PM (23).
### 10. What was the volume of orders for each day of the week ?
````sql
SELECT DAYNAME(order_time) AS day_of_week,
	   COUNT(order_id) AS pizza_order
FROM customer_orders_temporary
GROUP BY DAYNAME(order_time)
ORDER BY day_of_week;
````
**Answer**

<img width="139" alt="Image" src="https://github.com/user-attachments/assets/525dc794-2513-4128-8ac6-a23adbfb6180" />

- A total of 5 pizzas were ordered on both Friday and Monday.
- On Saturday, 3 pizzas were ordered.
- On Sunday, only 1 pizza was ordered.
## B. Runner and Customer Experience
###  1. How many runner signed up for each 1 week period ? (i.e. week starts 2021-01-01)
````sql
SELECT WEEK(registration_date, 1) AS week_period,
	     COUNT(*) AS runner_count 
FROM runners
GROUP BY WEEK(registration_date, 1);
````
**Answer**

<img width="143" alt="Image" src="https://github.com/user-attachments/assets/e2ade417-8cdb-412b-aaec-2d262c99d042" />

- In the first week of January 2021, two new runners signed up.  
- In the second and third weeks of January 2021, one new runner signed up each week.
###  2. What was the average time in minutes it took for each runner to arrive at the pizza runner HQ to pickup the order ?
````sql
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
GROUP BY runner_id;
````
**Answer**

<img width="146" alt="Image" src="https://github.com/user-attachments/assets/55cda137-3248-4645-bebd-d5a41ce448dd" />

- The average time taken by runners to reach Pizza Runner HQ for order pickup is 15 minutes.
###  3. Is there any relationship between the number of pizzas and how long the order takes to prepare ?
````sql
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
GROUP BY pizza_count;
````
**Answer**

<img width="124" alt="Image" src="https://github.com/user-attachments/assets/29f44bb5-73f4-4eee-8de2-dcb089cdd7ca" />

- On average, a single pizza order takes 12 minutes to prepare.  
- An order with 3 pizzas takes 30 minutes, averaging 10 minutes per pizza.  
- It takes 16 minutes to prepare an order with 2 pizzas, which is 8 minutes per pizza — making two pizzas in a single order the most efficient preparation rate.
###  4. What was the average distance travelled for each customer ?
````sql
SELECT cot.customer_id,
	   ROUND(AVG(rot.distance), 1) AS average_distance
FROM customer_orders_temporary AS cot
LEFT JOIN runner_orders_temporary AS rot
ON cot.order_id = rot.order_id
GROUP BY cot.customer_id;
````
**Answer**

<img width="161" alt="Image" src="https://github.com/user-attachments/assets/2144d9ee-1e2c-425e-83c3-1bceba9d677f" />

- Customer 104 lives the closest to Pizza Runner HQ, with an average distance of 10 km, while Customer 105 is the furthest, located 25 km away.
###  5. What was the difference between the longest and shortest delivery times for all orders ?
````sql
SELECT MAX(duration) - MIN(duration) AS diff_delivery_times
FROM runner_orders_temporary;
````
**Answer**

<img width="106" alt="Image" src="https://github.com/user-attachments/assets/6b70b106-ddb9-4171-8ca4-a8b554f98849" />

- The difference between the longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes.
###  6. What was the average speed for each runner for each delivery and do you do notice any trend for these values ?
````sql
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
GROUP BY rot.runner_id, cot.order_id, rot.distance, rot.duration;
````
**Answer**

<img width="320" alt="Image" src="https://github.com/user-attachments/assets/4af7cdc8-1f33-48dc-a0f4-98fcf46b90c7" />

- Runner 1’s average speed ranges from 37.5 km/h to 60 km/h.  
- Runner 2’s average speed ranges from 35.1 km/h to 93.6 km/h. Danny should investigate Runner 2, as the average speed shows a 300% fluctuation rate!  
- Runner 3’s average speed is 40 km/h.
###  7. What is the succesfull delivery percentage for each runner ?
````sql
SELECT runner_id,
	   COUNT(distance) AS delivered,
       COUNT(order_id) AS total,
       CONCAT(ROUND((COUNT(distance) / COUNT(order_id) * 100), 0), '%')  AS succesfull_percentage
FROM runner_orders_temporary
GROUP BY runner_id;
````
**Answer**

<img width="235" alt="Image" src="https://github.com/user-attachments/assets/3cb89835-e8d8-4de9-a9ff-bd93d884f2e9" />

- Runner 1 has a 100% successful delivery rate.  
- Runner 2 has a 75% successful delivery rate.  
- Runner 3 has a 50% successful delivery rate.
