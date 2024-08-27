create database Pizza_Sales;
create table orders
(order_id int primary key,
order_date date not null,
order_time time not null);

create table order_details
(order_details_id int primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

-- Total number of orders placed --
SELECT 
    COUNT(order_id) as 'Total Orders Placed'
FROM
    orders;

-- Total revenue generated from pizza sales --
SELECT 
    CONCAT((ROUND(SUM(pizzas.price * order_details.quantity)) / 1000),' K') 
    AS 'Total Revenue'
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Highest-priced pizza --
SELECT 
    pizza_types.name, pizzas.size, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
WHERE
    pizzas.price = (SELECT MAX(price) FROM pizzas);

-- Most common pizza size ordered --
SELECT 
    pizzas.size, SUM(order_details.quantity) AS count_of_orders
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY count_of_orders DESC
LIMIT 1;

-- Top 5 most ordered pizza types along with their quantities --
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS count_of_orders
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name 
ORDER BY count_of_orders DESC
LIMIT 5;

-- Total quantity of each pizza category ordered --
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity_ordered DESC;

-- Distribution of orders by hour of the day --
SELECT 
    HOUR(order_time) AS Hour_of_the_day,
    COUNT(order_id) AS 'Number of Orders'
FROM
    orders
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day ASC;

-- Category-wise distribution of pizzas --
SELECT 
    Category, COUNT(name) no_of_pizzas
FROM
    pizza_types
GROUP BY category;

-- Average number of pizzas ordered per day --
SELECT 
    ROUND(AVG(pizzas_ordered)) AS Avg_pizzas_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS pizzas_ordered
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS datewise_qty;


-- Top 3 pizza types based on revenue --
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.Category,
    CONCAT(ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
2),"%") AS Percentage_of_Total_Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Percentage_of_Total_Revenue DESC;

-- Top 3 pizza types based on revenue from each pizza category --
select category, name, round(revenue) as Revenue
from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum(pizzas.price*order_details.quantity) as revenue
from
pizzas join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
join
order_details on order_details.pizza_id=pizzas.pizza_id
join
orders on orders.order_id=order_details.order_id
group by pizza_types.category,pizza_types.name
order by pizza_types.category) as a) as b 
where rn<=3;

-- Cumulative revenue generated over the months.
SELECT 
    month,
    SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM
    (SELECT 
        month(orders.order_date) AS month,
        round(SUM(pizzas.price * order_details.quantity)) AS revenue
    FROM 
        order_details
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = order_details.order_id
    GROUP BY 
        month(orders.order_date)) AS sales
ORDER BY 
    month;