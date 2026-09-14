/*
===============================================================================
PROJECT: Pizza Sales Data Analysis
DATABASE: SQL Server
===============================================================================

PROJECT OVERVIEW
This project analyzes pizza sales data to answer important business questions
related to orders, revenue, product performance, customer ordering patterns,
and category-wise sales performance.

SKILLS DEMONSTRATED
- SELECT, WHERE, GROUP BY, ORDER BY
- Aggregate Functions (SUM, COUNT, AVG)
- JOINs
- Common Table Expressions (CTEs)
- Subqueries
- Window Functions
- RANK() and PARTITION BY
- DATEPART()
- Cumulative Revenue Analysis

TABLES USED
1. orders         - Order ID, order date, and order time
2. order_details  - Order details, pizza ID, and quantity
3. pizzas         - Pizza size and price
4. pizza_types    - Pizza name, category, and ingredients

===============================================================================
*/

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================

CREATE DATABASE pizza_project;
GO

USE pizza_project;
GO

-- Import the CSV files into the tables before running the analysis queries.


-- ============================================================================
-- DATA EXPLORATION
-- ============================================================================

-- View all columns and records from each table.

SELECT * FROM order_details;  -- order_details_id, order_id, pizza_id, quantity
SELECT * FROM pizzas;         -- pizza_id, pizza_type_id, size, price
SELECT * FROM orders;         -- order_id, date, time
SELECT * FROM pizza_types;    -- pizza_type_id, name, category, ingredients


-- ============================================================================
-- BUSINESS QUESTIONS
-- ============================================================================

/*
BASIC ANALYSIS
1. Retrieve the total number of orders placed.
2. Calculate the total revenue generated from pizza sales.
3. Identify the highest-priced pizza.
4. Identify the most common pizza size ordered.
5. List the top 5 most ordered pizza types along with their quantities.

INTERMEDIATE ANALYSIS
6. Find the total quantity of each pizza category ordered.
7. Determine the distribution of orders by hour of the day.
8. Find the category-wise distribution of pizzas.
9. Calculate the average number of pizzas ordered per day.
10. Determine the top 3 pizza types based on revenue.

ADVANCED ANALYSIS
11. Calculate the percentage contribution of each pizza category to total revenue.
12. Calculate the percentage contribution of each pizza type to total revenue.
13. Analyze the cumulative revenue generated over time.
14. Determine the top 3 revenue-generating pizza types for each category.
*/


-- ============================================================================
-- BASIC ANALYSIS
-- ============================================================================

-- 1. Retrieve the total number of orders placed.

SELECT COUNT(DISTINCT order_id) AS [Total Orders]
FROM orders;


-- 2. Calculate the total revenue generated from pizza sales.

SELECT CAST(SUM(od.quantity * p.price) AS DECIMAL(10, 2)) AS [Total Revenue]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id;


-- 3. Identify the highest-priced pizza.

SELECT TOP 1
    pt.name AS [Pizza Name],
    CAST(p.price AS DECIMAL(10, 2)) AS [Price]
FROM pizzas AS p
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC;


-- Alternative solution using a window function.

WITH HighestPricedPizza AS
(
    SELECT
        pt.name AS [Pizza Name],
        CAST(p.price AS DECIMAL(10, 2)) AS [Price],
        RANK() OVER (ORDER BY p.price DESC) AS rnk
    FROM pizzas AS p
    JOIN pizza_types AS pt
        ON pt.pizza_type_id = p.pizza_type_id
)
SELECT [Pizza Name], [Price]
FROM HighestPricedPizza
WHERE rnk = 1;


-- 4. Identify the most common pizza size ordered.

SELECT
    p.size AS [Pizza Size],
    COUNT(DISTINCT od.order_id) AS [Number of Orders],
    SUM(od.quantity) AS [Total Quantity Ordered]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY [Number of Orders] DESC;


-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    pt.name AS [Pizza Name],
    SUM(od.quantity) AS [Total Quantity Ordered]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY [Total Quantity Ordered] DESC;


-- ============================================================================
-- INTERMEDIATE ANALYSIS
-- ============================================================================

-- 6. Find the total quantity of each pizza category ordered.

SELECT
    pt.category AS [Pizza Category],
    SUM(od.quantity) AS [Total Quantity Ordered]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY [Total Quantity Ordered] DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT
    DATEPART(HOUR, [time]) AS [Hour of the Day],
    COUNT(DISTINCT order_id) AS [Number of Orders]
FROM orders
GROUP BY DATEPART(HOUR, [time])
ORDER BY [Number of Orders] DESC;


-- 8. Find the category-wise distribution of pizza types.

SELECT
    category AS [Pizza Category],
    COUNT(DISTINCT pizza_type_id) AS [Number of Pizza Types]
FROM pizza_types
GROUP BY category
ORDER BY [Number of Pizza Types] DESC;


-- 9. Calculate the average number of pizzas ordered per day.

WITH DailyPizzaOrders AS
(
    SELECT
        o.date AS [Order Date],
        SUM(od.quantity) AS [Total Pizzas Ordered]
    FROM order_details AS od
    JOIN orders AS o
        ON od.order_id = o.order_id
    GROUP BY o.date
)
SELECT CAST(AVG([Total Pizzas Ordered]) AS DECIMAL(10, 2))
    AS [Average Pizzas Ordered Per Day]
FROM DailyPizzaOrders;


-- Alternative solution using a subquery.

SELECT CAST(AVG([Total Pizzas Ordered]) AS DECIMAL(10, 2))
    AS [Average Pizzas Ordered Per Day]
FROM
(
    SELECT
        o.date AS [Order Date],
        SUM(od.quantity) AS [Total Pizzas Ordered]
    FROM order_details AS od
    JOIN orders AS o
        ON od.order_id = o.order_id
    GROUP BY o.date
) AS DailyOrders;


-- 10. Determine the top 3 pizza types based on revenue.

SELECT TOP 3
    pt.name AS [Pizza Name],
    CAST(SUM(od.quantity * p.price) AS DECIMAL(10, 2)) AS [Revenue]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY [Revenue] DESC;


-- ============================================================================
-- ADVANCED ANALYSIS
-- ============================================================================

-- 11. Calculate the percentage contribution of each pizza category to total revenue.

SELECT
    pt.category AS [Pizza Category],
    CAST(
        SUM(od.quantity * p.price) * 100.0 /
        (
            SELECT SUM(od2.quantity * p2.price)
            FROM order_details AS od2
            JOIN pizzas AS p2
                ON p2.pizza_id = od2.pizza_id
        )
        AS DECIMAL(10, 2)
    ) AS [Revenue Contribution Percentage]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY [Revenue Contribution Percentage] DESC;


-- 12. Calculate the percentage contribution of each pizza type to total revenue.

SELECT
    pt.name AS [Pizza Name],
    CAST(
        SUM(od.quantity * p.price) * 100.0 /
        (
            SELECT SUM(od2.quantity * p2.price)
            FROM order_details AS od2
            JOIN pizzas AS p2
                ON p2.pizza_id = od2.pizza_id
        )
        AS DECIMAL(10, 2)
    ) AS [Revenue Contribution Percentage]
FROM order_details AS od
JOIN pizzas AS p
    ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
    ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY [Revenue Contribution Percentage] DESC;


-- 13. Analyze the cumulative revenue generated over time.

WITH DailyRevenue AS
(
    SELECT
        o.date AS [Order Date],
        CAST(SUM(od.quantity * p.price) AS DECIMAL(10, 2)) AS [Daily Revenue]
    FROM order_details AS od
    JOIN orders AS o
        ON od.order_id = o.order_id
    JOIN pizzas AS p
        ON p.pizza_id = od.pizza_id
    GROUP BY o.date
)
SELECT
    [Order Date],
    [Daily Revenue],
    CAST(
        SUM([Daily Revenue]) OVER
        (
            ORDER BY [Order Date]
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
        AS DECIMAL(12, 2)
    ) AS [Cumulative Revenue]
FROM DailyRevenue
ORDER BY [Order Date];


-- 14. Determine the top 3 revenue-generating pizza types for each pizza category.

WITH PizzaRevenue AS
(
    SELECT
        pt.category,
        pt.name,
        CAST(SUM(od.quantity * p.price) AS DECIMAL(10, 2)) AS [Revenue]
    FROM order_details AS od
    JOIN pizzas AS p
        ON p.pizza_id = od.pizza_id
    JOIN pizza_types AS pt
        ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.category, pt.name
),
RankedPizzaRevenue AS
(
    SELECT
        category,
        name,
        [Revenue],
        RANK() OVER
        (
            PARTITION BY category
            ORDER BY [Revenue] DESC
        ) AS rnk
    FROM PizzaRevenue
)
SELECT
    category AS [Pizza Category],
    name AS [Pizza Name],
    [Revenue]
FROM RankedPizzaRevenue
WHERE rnk <= 3
ORDER BY [Pizza Category], [Revenue] DESC;


-- ============================================================================
-- END OF PROJECT
-- ============================================================================
