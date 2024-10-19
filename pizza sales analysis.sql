-- Q1.Analyze the cumulative revenue generated over time.

SELECT o.order_date,
       SUM(p.price*od.quantity) AS daily_revenue,
       SUM(SUM(p.price*od.quantity)) OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN pizzas p ON p.pizza_id = od.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Q2.Calculate the percentage contribution of each pizza type to total revenue.

WITH pizza_sales AS(
	SELECT p.pizza_id, SUM(p.price) AS total_sales
	FROM pizzas p
	LEFT JOIN order_details od ON p.pizza_id = od.pizza_id
	GROUP BY p.pizza_id
	), 
	total_revenue AS(
	SELECT SUM(total_sales) AS total_revenue
	FROM pizza_sales
)

SELECT ps.pizza_id, ROUND(ps.total_sales) AS total_sales,
	ROUND((ps.total_sales / tr.total_revenue) * 100) AS percentage_contribution
FROM pizza_sales ps
CROSS JOIN total_revenue tr
ORDER BY percentage_contribution DESC;

-- Q3.Join the necessary tables to find the total quantity of each pizza category ordered

SELECT pt.category, SUM(od.quantity) AS total_sale
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_sale DESC;

-- Q4. Calculating Total Pizza Order Quantity and Applying Dynamic Discounts Based on Order Value.

WITH sale_by_id AS (
    SELECT od.order_id, SUM(od.quantity) AS total_quantity, ROUND(SUM(p.price)) AS total_price
    FROM pizzas p
    RIGHT JOIN order_details od ON p.pizza_id = od.pizza_id
    GROUP BY od.order_id
)

SELECT order_id, total_quantity, total_price,
	CASE 
        WHEN total_price > 200 THEN total_price * 0.10
        WHEN total_price BETWEEN 100 AND 200 THEN total_price * 0.05
        ELSE 0
    END AS discount_price
FROM sale_by_id
ORDER BY discount_price DESC;

-- Q5. Determine the distribution of orders by hour of the day

SELECT EXTRACT(HOUR FROM order_time) AS order_hour,
COUNT(order_id) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;