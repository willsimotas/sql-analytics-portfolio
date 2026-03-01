/*
Business Objective:
Identify customers with lifetime spend > $1,000
who have also made a purchase in the last 100 days.

Approach:
1. Aggregate lifetime spend per customer.
2. Identify recent purchasers (last 100 days).
3. Join both datasets to isolate high-value active customers.
*/

WITH lifetime AS (
  SELECT
    o.customer_id,
    SUM(op.payment_value) AS lifetime_spend
  FROM orders o
  JOIN order_payments op
    ON op.order_id = o.order_id
  GROUP BY o.customer_id
),
recent AS (
  SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS orders_last_100_days,
    MAX(order_purchase_date) AS last_purchase_date
  FROM orders
  WHERE order_purchase_date >= (SELECT MAX(order_purchase_date) FROM orders) - 100
  GROUP BY customer_id
)
SELECT
  l.customer_id,
  TO_CHAR(l.lifetime_spend, 'FM$999,999,999,999') AS spend,
  r.orders_last_100_days,
  r.last_purchase_date
FROM lifetime l
JOIN recent r
  ON r.customer_id = l.customer_id
WHERE l.lifetime_spend > 1000
ORDER BY spend DESC;