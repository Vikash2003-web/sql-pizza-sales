-- Retrieve the total number of orders placed.
select count(order_id)as total_orders from orders;


-- Calculate the total revenue generated from pizza sales.

select
ROUND(SUM(order_detail.quantity * pizzas.price),2)AS total_sales

from order_detail join pizzas
on pizzas.pizza_id = order_detail.pizza_id

-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

-- Identify the most common pizza size ordered.

select pizzas.size, count(order_detail.order_details_id) AS order_count
from pizzas join order_detail
on pizzas.pizza_id = order_detail.pizza_id
group by pizzas.size order by order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name AS pizza_type,
    SUM(od.quantity) AS total_quantity
FROM order_detail od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    SUM(od.quantity) AS total_quantity
FROM order_detail od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    EXTRACT(HOUR FROM order_time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;


-- Join relevant tables to find the category-wise distribution of pizzas.


SELECT 
    pt.category,
    COUNT(od.pizza_id) AS total_orders,
    SUM(od.quantity) AS total_quantity
FROM order_detail od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(daily_pizzas) AS avg_pizzas_per_day
FROM (
    SELECT 
        o.order_date,
        SUM(od.quantity) AS daily_pizzas
    FROM orders o
    JOIN order_detail od
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_orders;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name AS pizza_type,
    SUM(od.quantity * p.price) AS total_revenue
FROM order_detail od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.name AS pizza_type,
    ROUND(
        SUM(od.quantity * p.price) * 100.0 /
        SUM(SUM(od.quantity * p.price)) OVER (),
        2
    ) AS revenue_percentage
FROM order_detail od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue_percentage DESC;

-- Analyze the cumulative revenue generated over time.

SELECT
    o.order_date,
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) 
        OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_detail od
    ON o.order_id = od.order_id
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category,
    pizza_type,
    total_revenue
FROM (
    SELECT 
        pt.category,
        pt.name AS pizza_type,
        SUM(od.quantity * p.price) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY pt.category 
            ORDER BY SUM(od.quantity * p.price) DESC
        ) AS rank_in_category
    FROM order_detail od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, total_revenue DESC;

