

create database pizza_project


use pizza_project;

select * from orders
select * from order_details
select * from pizza_types
select * from pizzas

select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

--1 Retrieve the total number of orders placed.

select count(distinct order_id) as Total_number from orders

--2 
-- Calculate the total revenue generated from pizza sales.

select cast(sum(od.quantity * p.price ) as decimal (10,2)) as Total_Revenue
from order_details od join pizzas p on od.pizza_id = p.pizza_id

--3 
-- Identify the highest-priced pizza.
-- using TOP/Limit functions

select top 1 pizza_id, max(price) as Highest_price from pizzas
group by pizza_id
order by Highest_price desc;

--- with join

select top 1 pt.name, cast(max(p.price) as decimal (10,2)) as Higest_price
from pizzas p join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by Higest_price desc;



select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

 
---4---- Identify the most common pizza size ordered.

select top 1 p.size, count(*) as Common_pizza_size
from pizzas p join order_details od  on p.pizza_id = od.pizza_id
group by p.size
order by Common_pizza_size desc;

select  p.size, count(*) as Common_pizza_size,sum(quantity) as total_order
from pizzas p join order_details od  on p.pizza_id = od.pizza_id
group by p.size;

--5-- List the top 5 most ordered pizza types along with their quantities.


--- Required one
select top 5 p.pizza_type_id,sum(od.quantity) as most_ordered_pizza
from pizzas p join order_details od  on p.pizza_id = od.pizza_id
group by p.pizza_type_id
order by most_ordered_pizza desc;

---optional
select top 5 p.pizza_type_id,count(*) as most_ordered_pizza
from pizzas p join order_details od  on p.pizza_id = od.pizza_id
group by p.pizza_type_id
order by most_ordered_pizza desc;

ALTER TABLE order_details
ALTER COLUMN quantity INT;


select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

--6-- Determine the distribution of orders by hour of the day.
select DATEPART(hour,time) as Total_hour , count(*) as orders_d
from orders
group by DATEPART(hour,time) 
order by orders_d desc;

--7-- find the category-wise distribution of pizzas

select category, count(distinct pizza_type_id) as distribution_of_pizzas  from pizza_types
group by category
order by distribution_of_pizzas desc;

---alternative

select category, count(*) as distribution_of_pizzas  from pizza_types
group by category
order by distribution_of_pizzas desc;


select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients


--8-- Calculate the average number of pizzas ordered per day.

with cte as(
select  o.date as date_day, sum(od.quantity) as avg_quantity 
from order_details od join orders o on od.order_id = o.order_id
group by o.date) 
select avg(avg_quantity) as avg_quan from cte;

----alternative

with cte as(
select  o.date as date_day, sum(od.quantity) as avg_quantity 
from order_details od join orders o on od.order_id = o.order_id
group by o.date) 
select avg(avg_quantity) as avg_quan from cte;


--9---- Determine the top 3 most ordered pizza types based on revenue.

select top 3 p.pizza_type_id ,sum(o.quantity * p.price) as most_order_pizza
from pizzas p join order_details o on p.pizza_id  = o.pizza_id
group by p.pizza_type_id
order by most_order_pizza desc;


-- window function--

with cte as (select p.pizza_type_id ,sum(o.quantity * p.price) as most_order_pizza
from pizzas p join order_details o on p.pizza_id  = o.pizza_id
group by p.pizza_type_id),
ranked_us as (select pizza_type_id, most_order_pizza, row_number() over (order by most_order_pizza desc) as Revenue 
from cte)
select pizza_type_id, most_order_pizza from ranked_us where revenue <=3;



---
select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients
select distinct category from pizza_types


--10-- -- Calculate the percentage contribution of each pizza type to total revenues

select pt.category,cast (sum( p.price * o.quantity) as decimal (10,2)) * 100  /
(select sum(o.quantity * p.price) from order_details o join pizzas p on o.pizza_id = p.pizza_id) as Pizza_revenue
from order_details o join pizzas p on o.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.category;

select pt.name, cast (sum( p.price * o.quantity) as decimal (10,2)) * 100  /
(select sum(o.quantity * p.price) from order_details o join pizzas p on o.pizza_id = p.pizza_id) as Pizza_revenue
from order_details o join pizzas p on o.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by pt.name;


select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients
select distinct category from pizza_types

---11- Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)

with cte as
(select o.date, cast(sum(od.quantity * p.price) as decimal (10,2)) as Revenue
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join orders o on od.order_id = o.order_id
group by o.date)
select date, Revenue,sum(Revenue) over (order by date) as Cumulative_Revenue 
from cte group by date, Revenue;





select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients



--12----- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


with cte as(
select top 3 pt.category,pt.name, sum(p.price * od.quantity) as revenue
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category,pt.name),

sdf as (select category, name, revenue, rank() over (partition by category order by revenue desc) as category_revenue 
from cte)
select category,name,revenue from sdf where category_revenue in (1,2,3)
order by category, name, revenue;

with cte as(
select top 3 pt.category,pt.name, sum(p.price * od.quantity) as revenue
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category,pt.name),

sdf as (select category, name, revenue, rank() over (partition by category order by revenue desc) as category_revenue 
from cte)
select category,name,revenue from sdf where category_revenue in (1,2,3)
order by category, name, revenue;





