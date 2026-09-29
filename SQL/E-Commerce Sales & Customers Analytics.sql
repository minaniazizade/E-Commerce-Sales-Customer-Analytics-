SHOW TABLES;

---customers

SELECT *
FROM customers
LIMIT 10;

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM orders;

SELECT country,COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;

SELECT loyalty_tier,COUNT(*) AS customer_count
FROM customers
GROUP BY loyalty_tier
ORDER BY customer_count ASC;

SELECT COUNT(*) AS missing_loyalty
FROM customers 
WHERE loyalty_tier IS NULL;

SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) x;


SELECT MIN(signup_date) AS first_signup,MAX(signup_date) AS last_signup 
FROM customers;

---orders

SELECT COUNT(*) AS total_orders 
FROM orders;

SELECT status,COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY order_count ASC;

SELECT channel, COUNT(*) AS order_count
FROM orders
GROUP BY channel
ORDER BY order_count ASC;

SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC;

SELECT customer_id,MAX(ordered_at) AS last_order_date 
FROM orders
GROUP BY customer_id
ORDER BY last_order_date DESC;

WITH order_totals AS(
    SELECT order_id, SUM(amount) AS order_amount
    FROM payments
    WHERE status = 'captured'
    GROUP BY order_id
)
SELECT ROUND(AVG(order_amount),2) AS average_order_vlue
FROM order_totals;

SELECT c.customer_id,
       c.first_name,
       c.last_name,
       c.country,
       c.loyalty_tier,
       COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id,
         c.first_name,
         c.last_name,
         c.country,
         c.loyalty_tier
ORDER BY order_count DESC; 

---money

SELECT status, COUNT(*) AS count 
FROM payments 
GROUP BY status;

SELECT method, SUM(amount) AS total_revenue
FROM payments
WHERE status = 'captured'
GROUP BY method
ORDER BY total_revenue DESC;

SELECT p.product_name,SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 10;

SELECT status , COUNT(*) AS payment_count,SUM(amount) AS total_amount
FROM payments
GROUP BY status;

--- returns

SELECT COUNT(*) AS total_returns
FROM returns;

SELECT reason,COUNT(*) AS return_count
FROM returns
GROUP BY reason
ORDER BY return_count DESC;

SELECT p.product_name,COUNT(r.return_id) AS return_count
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY return_count DESC;

---

SELECT c.customer_id,
       c.first_name,
       c.last_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT AVG(order_count) AS avg_orders_per_customer
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
);

SELECT p.product_name,SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC
LIMIT 10;

SELECT country,COUNT(*) AS customer_count,ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers),2) AS percentage
FROM customers
GROUP BY country
ORDER BY percentage DESC;

SELECT shipping_country,COUNT(*) AS order_count
FROM orders
GROUP BY shipping_country
ORDER BY order_count DESC;

WITH order_revenue AS(
    SELECT order_id , SUM(amount) AS order_amount
    FROM payments
    WHERE status = 'captured'
    GROUP BY order_id
)

SELECT c.loyalty_tier , COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(
           COUNT(DISTINCT o.order_id) * 1.0 / NULLIF(COUNT(DISTINCT c.customer_id),0),2
       ) AS orders_per_customer, COALESCE(SUM(orv.order_amount),0) AS revenue 

FROM customers c 
LEFT JOIN orders o ON c.customer_id = o.customer_id 
LEFT JOIN order_revenue orv ON o.order_id = orv.order_id 
GROUP BY c.loyalty_tier 
ORDER BY orderS_per_customer DESC;

SELECT ROUND(COUNT(DISTINCT r.return_id) * 100 / COUNT(DISTINCT oi.order_item_id), 2) AS return_rate_pct 
FROM order_items oi 
LEFT JOIN returns r ON oi.order_item_id=r.order_item_id;

--------------------------------- end ----------------------------------------